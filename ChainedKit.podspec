#
# Be sure to run `pod lib lint ChainedKit.podspec --allow-warnings' to ensure this is a
# valid spec before submitting.
# `pod repo push motorFans ChainedKit.podspec --allow-warnings`
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name             = 'ChainedKit'
  s.version          = '1.0.2'
  s.summary          = 'Chained Tools.'
  s.homepage         = 'https://github.com/xiaohuochai/ChainedKit.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Motor' => 'ChainedKit' }
  s.source           = { :git => 'https://github.com/xiaohuochai/ChainedKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/ChainedKit/*.{swift}'
  s.dependency 'SnapKit', '5.6.0'
  
end
