platform :tvos, '9.0'
use_frameworks!

target 'TVoxx' do
    pod 'Alamofire', '~> 4.0'
    pod 'AlamofireImage', '~> 3.1'
    pod 'Cosmos', '~> 7.0'
    pod 'YoutubeSourceParserKit', :git => 'https://github.com/lennet/YoutubeSourceParserKit.git'
    pod 'FontAwesome.swift', '~> 1.0'
end

target 'TVoxxTests' do

end

target 'TVoxxUITests' do

end

target 'TVoxxTopShelf' do
    pod 'Alamofire', '~> 4.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
