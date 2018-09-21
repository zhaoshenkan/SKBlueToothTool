//
//  SKBlueToothTool.m
//  test11
//
//  Created by zsk on 2017/6/2.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import "SKBlueToothTool.h"


@interface SKBlueToothTool ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, copy) NSMutableArray *peripherals;


@end

@implementation SKBlueToothTool

- (id)init
{
    if (self = [super init]) {
        //初始化对象
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        _peripherals = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)scanService
{
    [_manager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScanService
{
    [_manager stopScan];
}

- (void)cancelService
{
    for (CBPeripheral *peripheral in _peripherals) {
        [self disconnectPeripheral:_manager peripheral:peripheral];
    }
}

#pragma mark - 蓝牙代理方法
//扫描外设（discover），扫描外设的方法我们放在centralManager成/Users/zsk/Desktop/working/weiKit/weiKit功打开的委托中，因为只有设备成功打开，才能开始扫描，否则会报错。
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            [self.peripherals removeAllObjects];
            break;
        case CBManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            [self scanService];
            if (self.scanServiceBlock) {
                self.scanServiceBlock();
            }
            break;
        default:
            break;
    }
}

//连接外设(connect)
//扫描到设备会进入方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"当扫描到设备:%@",peripheral.name);
    
    NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString *aStr= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSString *mac = [NSStringTool convertToNSStringWithNSData:data];
    aStr = [aStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"________aStr:%@",aStr);
    NSLog(@"_______advertisementData:%@",advertisementData);
    
    if (self.didDiscoverPeripheralBlock) {
        self.didDiscoverPeripheralBlock(_manager,peripheral,self.peripherals);
    }
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@">>>外设连接断开连接 %@: %@\n", [peripheral name], [error localizedDescription]);
    if (self.disConnectPeripheralBlock) {
        self.disConnectPeripheralBlock(peripheral,error);
    }
}

//扫描到Services
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //  NSLog(@">>>扫描到服务：%@",peripheral.services);
    if (error)
    {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

//扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"******service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
    }
    
    for (CBCharacteristic *characteristic in service.characteristics){
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
    
    if (self.didDiscoverCharacteristicsForServiceBlock) {
        self.didDiscoverCharacteristicsForServiceBlock(peripheral,service);
    }
}

//获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
//    NSLog(@"------characteristic uuid:%@  value:%@ ",characteristic.UUID,characteristic.value);
    if (self.didUpdateValueForCharacteristicBlock) {
        self.didUpdateValueForCharacteristicBlock(peripheral, characteristic);
    }
}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
    
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
//    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic value:(NSData *)value{
    
    NSLog(@"%lu", (unsigned long)characteristic.properties);
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }else{
        NSLog(@"该字段不可写！");
    }
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic{
    NSLog(@"取消通知");
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}



+ (NSString *)CBUUIDToString:(CBUUID *)inUUID
{
    unsigned char i[16];
    [inUUID.data getBytes:i length:inUUID.data.length];
    if (inUUID.data.length == 2) {
        return [NSString stringWithFormat:@"%02hhx%02hhx",i[0],i[1]];
    }
    else {
        uint32_t g1 = ((i[0] << 24) | (i[1] << 16) | (i[2] << 8) | i[3]);
        uint16_t g2 = ((i[4] << 8) | (i[5]));
        uint16_t g3 = ((i[6] << 8) | (i[7]));
        uint16_t g4 = ((i[8] << 8) | (i[9]));
        uint16_t g5 = ((i[10] << 8) | (i[11]));
        uint32_t g6 = ((i[12] << 24) | (i[13] << 16) | (i[14] << 8) | i[15]);
        return [NSString stringWithFormat:@"%08x-%04hx-%04hx-%04hx-%04hx%08x",g1,g2,g3,g4,g5,g6];
    }
    return nil;
}

- (void)returnDidDiscoverPeripheralBlock:(blueToothPeripheralBlock)didDiscoverPeripheralBlock
{
    self.didDiscoverPeripheralBlock = didDiscoverPeripheralBlock;
    
}

/**
 搜索到服务特征值
 */
- (void)returnDidDiscoverCharacteristicsForServiceBlock:(blueToothServiceBlock)didDiscoverCharacteristicsForServiceBlock
{
    if (self.didDiscoverCharacteristicsForServiceBlock) {
        self.didDiscoverCharacteristicsForServiceBlock = didDiscoverCharacteristicsForServiceBlock;
    }
}

/**
 获取characterist的值
 */
- (void)returnDidUpdateValueForCharacteristicBlock:(blueToothCharacteristicBlock)didUpdateValueForCharacteristicBlock
{
    if (self.didUpdateValueForCharacteristicBlock) {
        self.didUpdateValueForCharacteristicBlock = didUpdateValueForCharacteristicBlock;
    }
}


/**
 断开连接
 */
- (void)returndisConnectPeripheralBlock:(disConnectPeripheralBlock)disConnectPeripheralBlock
{
    if (self.disConnectPeripheralBlock) {
        self.disConnectPeripheralBlock = disConnectPeripheralBlock;
    }
}


/**
 
 @param scanServiceBlock 搜索设备
 */
- (void)returnscanServiceBlock:(scanServiceBlock)scanServiceBlock
{
    if (self.scanServiceBlock) {
        self.scanServiceBlock = scanServiceBlock;
    }
}

@end
