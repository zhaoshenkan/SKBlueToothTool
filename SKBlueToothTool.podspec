#
# Be sure to run `pod lib lint SKBlueToothTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SKBlueToothTool'
  s.version          = '0.1.0'
  s.summary          = '一个蓝牙工具类'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '赵申侃的蓝牙工具类,切是一个组件化私有库设置'
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zhaoshenkan/SKBlueToothTool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhaoshenkan' => '1045322866@qq.com' }
  s.source           = { :git => 'https://github.com/zhaoshenkan/SKBlueToothTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SKBlueToothTool/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SKBlueToothTool' => ['SKBlueToothTool/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
