source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

inhibit_all_warnings!
use_frameworks!


def pods
    pod 'ReactiveSwift'
    pod 'ReactiveCocoa'
    pod 'Alamofire', '~> 4.7'
    pod 'Cartography', '~> 3.0'
    pod 'Kingfisher', '~> 5.0'
    pod 'SwiftLint'
    pod 'RealmSwift', '3.12.0'
    pod 'R.swift'
    pod 'lottie-ios'
    pod 'SwiftyBeaver'
    pod 'DeepDiff'
end


target 'MovieGrid' do

    pods

end


target 'Core' do

    pods

end


target 'Cornerstones' do

    pods

end


post_install do |installer|
    installer.pods_project.targets.each do |target|

        # Disable bitcode.
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end

        # Explicitly set the Swift version for pods that Xcode may complain about.
        if ['ReactiveSwift', 'ReactiveCocoa', 'Result', 'lottie-ios'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '5'
            end
        end

    end
end
