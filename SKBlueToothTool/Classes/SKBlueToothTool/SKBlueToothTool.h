//
//  SKBlueToothTool.h
//  test11
//
//  Created by zsk on 2017/6/2.
//  Copyright © 2017年 zsk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^blueToothCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic);
typedef void(^blueToothServiceBlock)(CBPeripheral *peripheral,CBService *service);
typedef void(^blueToothPeripheralBlock)(CBCentralManager *manager,CBPeripheral *peripheral,NSMutableArray *peripherals);
typedef void(^scanServiceBlock)();
typedef void(^disConnectPeripheralBlock)(CBPeripheral *peripheral,NSError *error);


@interface SKBlueToothTool : NSObject

//+ (instancetype)shareBabyBluetooth;

@property (nonatomic, strong) CBCentralManager *manager;

/**
 搜索到蓝牙的时候
 */
@property (nonatomic, copy) blueToothPeripheralBlock didDiscoverPeripheralBlock;

/**
 搜索到服务特征值
 */
@property (nonatomic, copy) blueToothServiceBlock didDiscoverCharacteristicsForServiceBlock;

/**
 获取characterist的值
 */
@property (nonatomic, copy) blueToothCharacteristicBlock didUpdateValueForCharacteristicBlock;


/**
 断开连接
 */
@property (nonatomic, copy) disConnectPeripheralBlock disConnectPeripheralBlock;


/**
 搜索设备
 */
@property (nonatomic, copy) scanServiceBlock scanServiceBlock;

/**
 搜索设备
 */
- (void)scanService;

/**
 停止搜索设备
 */
- (void)stopScanService;

/**
 退出设备
 */
- (void)cancelService;

+ (NSString *)CBUUIDToString:(CBUUID *)inUUID;


//在swift 方便使用
/**
 搜索到蓝牙的时候
 */
- (void)returnDidDiscoverPeripheralBlock:(blueToothPeripheralBlock)didDiscoverPeripheralBlock;

/**
 搜索到服务特征值
 */
- (void)returnDidDiscoverCharacteristicsForServiceBlock:(blueToothServiceBlock)didDiscoverCharacteristicsForServiceBlock;

/**
 获取characterist的值
 */
- (void)returnDidUpdateValueForCharacteristicBlock:(blueToothCharacteristicBlock)didUpdateValueForCharacteristicBlock;


/**
 断开连接
 */
- (void)returndisConnectPeripheralBlock:(disConnectPeripheralBlock)disConnectPeripheralBlock;


/**

 @param scanServiceBlock 搜索设备
 */
- (void)returnscanServiceBlock:(scanServiceBlock)scanServiceBlock;


@end
