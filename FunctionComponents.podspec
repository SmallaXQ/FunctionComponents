#
# Be sure to run `pod lib lint FunctionComponents.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FunctionComponents'
  s.version          = '1.0.0'
  s.summary          = '功能组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
功能组件库，包含：SKU过滤器、Reflect映射类、BannerView功能组件等。
                       DESC

  s.homepage         = 'https://github.com/SmallaXQ/FunctionComponents'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SmallaXQ' => 'smallaxq@gmail.com' }
  s.source           = { :git => 'https://github.com/SmallaXQ/FunctionComponents.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_versions = '5.0'

  s.source_files = 'FunctionComponents/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FunctionComponents' => ['FunctionComponents/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'FSPagerView', '~> 0.8.3'
  s.dependency 'Then', '~> 2.7.0'
  s.dependency 'SnapKit', '~> 4.2.0'
  s.dependency 'SDWebImage', '~> 5.8.4'
  s.frameworks = 'UIKit', 'Foundation'
end
