source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

pod 'AFNetworking', '~> 2.0'
pod 'JSONModel', '~> 1.0.1'
pod 'XCDYouTubeKit', '~> 2.0.2'
pod 'SDWebImage', '~> 3.7.0'
pod "TSMessages"
pod 'GoogleAnalytics-iOS-SDK'
pod 'DZNEmptyDataSet'

target :LolTubeTests do
  pod 'OCMock', '~> 3.1.1'
  pod 'OHHTTPStubs', '~>3.1.5'
  use_frameworks!
  pod 'Quick'
  pod 'Nimble'
end

target :VideoWidget, :exclusive => true do
  pod 'AFNetworking', '~> 2.0'
  pod 'SDWebImage', '~> 3.7.0'
  pod 'JSONModel', '~> 1.0.1'
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    puts "taret=#{target.name}"
    if target.name == "Pods-VideoWidget-AFNetworking" || target.name == "Pods-VideoWidget-JSONModel" || target.name == "Pods-VideoWidget-SDWebImage"
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      end
    end
  end
end