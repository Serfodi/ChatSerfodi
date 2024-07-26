# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'ChatSerfodi' do
	
  use_frameworks!

  # Pods for ChatSerfodi

  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'SDWebImage', '~> 5.0'
  pod 'lottie-ios'
  pod 'GoogleSignIn'
  pod 'MessageKit'
  pod "TinyConstraints"

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Xcode 14 supports only iOS >= 11.0.
      deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      if !deployment_target.nil? && !deployment_target.empty? && deployment_target.to_f < 11.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end

end