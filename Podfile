source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

pod 'AFNetworking', '~> 3.1.0'
pod 'JSONModel', '~> 1.0.1'
pod 'XCDYouTubeKit', '~> 2.3.1'
pod 'SDWebImage', '~> 3.7.0'
pod 'TSMessages', :git => 'https://github.com/KrauseFx/TSMessages.git'
pod 'Google/Analytics', '~> 1.0.0'
pod 'DZNEmptyDataSet'
pod 'Cartography', :git => "git@github.com:robb/Cartography.git", :branch => "swift-2.0"
pod 'AsyncSwift'
pod 'Siren'

target :LolTubeTests do
  pod 'OCMock', '~> 3.1.1'
  pod 'OHHTTPStubs', '~>3.1.5'
  use_frameworks!
  pod 'Quick'
  pod 'Nimble'
end

target :VideoWidget, :exclusive => true do
  pod 'AFNetworking', '~> 3.1.0'
  pod 'SDWebImage', '~> 3.7.0'
  pod 'JSONModel', '~> 1.0.1'
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    puts "taret=#{target.name}"
    if target.name == "AFNetworking" || target.name == "JSONModel" || target.name == "SDWebImage"
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      end
    end
  end
end