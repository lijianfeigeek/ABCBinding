#  pod lib lint --verbose --use-libraries --allow-warnings
#  pod repo push ABCCocoapodsRepos ABCBinding.podspec --verbose --allow-warnings
#  pod package ABCBinding.podspec --force --exclude-deps

Pod::Spec.new do |s|
  s.name             = 'ABCBinding'
  s.version          = '1.0.0'
  s.summary          = 'A short description of ABCBinding.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://git.code.oa.com/ezli/ABCBinding'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lijianfeigeek' => 'me@lijianfei.com' }
  s.source           = { :git => 'http://git.code.oa.com/ezli/ABCBinding.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ABCBinding/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ABCBinding' => ['ABCBinding/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
