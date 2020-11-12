#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'testfairy'
  s.version          = '1.0.27'
  s.summary          = 'TestFairy integration for Flutter, bundles with the native iOS SDK'
  s.description      = <<-DESC
TestFairy flutter plugin.
                       DESC
  s.homepage         = 'https://testfairy.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TestFairy' => 'support@testfairy.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'TestFairy', '1.26.7'
  s.static_framework = true

  s.ios.deployment_target = '9.0'
end

