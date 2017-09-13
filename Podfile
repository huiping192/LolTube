source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

def commonPods
    pod 'AFNetworking', '~> 2.0'
    pod 'JSONModel', '~> 1.0.1'
    pod 'SDWebImage', '~> 3.7.0'
end

target :LolTube do
    commonPods
    pod 'XCDYouTubeKit', '~> 2.3.1'
    pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
    pod 'Google/Analytics', '~> 1.0.0'
    pod 'DZNEmptyDataSet'
    pod 'Cartography', '~> 1.0.0'
    pod 'AsyncSwift', '~> 2.0.1'
    pod 'Siren', '~> 2.0.8' 
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
          config.build_settings['SWIFT_VERSION'] = '3.0'
      end
      
    puts "taret=#{target.name}"
    if target.name == "AFNetworking" || target.name == "JSONModel" || target.name == "SDWebImage"
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      end
    end
  end
end
