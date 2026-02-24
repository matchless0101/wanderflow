source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '16.0'
use_frameworks!

target 'WanderFlow' do
  # 移除 MapKit 依赖，引入高德 SDK
  pod 'AMapSearch', '9.7.4'
  pod 'AMapNavi', '10.1.600'
  # AMapLocation 版本体系独立，通常为 2.x，不与其他 SDK 共享 9.x 版本号
  pod 'AMapLocation', '~> 2.9'
end
