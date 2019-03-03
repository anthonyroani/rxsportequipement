# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'RxSportLyon' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for RxSportLyon
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'RxMapKit'    
    pod 'SwinjectStoryboard'
    pod 'SwiftLint'
    pod 'SwinjectAutoregistration', '2.5.0'
    pod 'Swinject', '~> 2.5.0'

    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['LD_NO_PIE'] = 'NO'
        end
      end
    end

   target 'RxSportLyonTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
