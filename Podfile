source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

def commonPods
    pod 'Alamofire', '4.9.1'
    pod 'JSONModel', '~> 1.0.1'
    pod 'SDWebImage', '~> 3.7.0'
    pod 'RxSwift', '5.0'
end

target :LolTube do
    commonPods
    pod 'XCDYouTubeKit', '~> 2.3.1'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'Google/Analytics', '~> 1.0.0'
    pod 'DZNEmptyDataSet'
    pod 'Cartography', '4.0.0'
    pod 'AsyncSwift', :git => 'https://github.com/duemunk/Async'
    pod 'Siren', '5.2.3'
    
    
    pod 'RxGesture', '3.0.0'
    pod 'NSObject+Rx', '5.0.0'
    pod 'RxSwiftExt', '5.0.0'
end


target :LolTubeTests do
  pod 'JSONModel', '~> 1.0.1'
  pod 'Google/Analytics', '~> 1.0.0'
  pod 'OCMock', '~> 3.1.1'
  pod 'OHHTTPStubs', '~>3.1.5'
  pod 'Quick', '~>1.1.0'
  pod 'Nimble'
end

target :VideoWidget do
  commonPods
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '5.0'
      end
      
    puts "taret=#{target.name}"
    if target.name == "AFNetworking" || target.name == "JSONModel" || target.name == "SDWebImage"
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      end
    end
  end
end
