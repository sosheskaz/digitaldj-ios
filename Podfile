platform :ios, "10.0"
workspace 'DDJiOS'
use_frameworks!

target 'DDJiOS' do
	platform :ios, '10.0'
        pod 'Alamofire', '~> 4.0'
	pod 'BlueSocket', '~> 0.12.35'
	pod 'Spotify-iOS-SDK', '~> 0.25.0'
	pod 'SwiftyBeaver'
end

target 'DDJiOSTests' do
	pod 'Alamofire', '~> 4.0'
        pod 'BlueSocket', '~> 0.12.35'
        pod 'Spotify-iOS-SDK', '~> 0.25.0'
end

target 'DDJiOSUITests' do
	pod 'Alamofire', '~> 4.0'
        pod 'BlueSocket', '~> 0.12.35'
        pod 'Spotify-iOS-SDK', '~> 0.25.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
    end
  end
end
