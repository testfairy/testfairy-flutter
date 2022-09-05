#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'testfairy_flutter'
  s.version          = '3.0.0'
  s.summary          = 'TestFairy integration for Flutter, bundles with the native iOS SDK'
  s.description      = <<-DESC
TestFairy flutter plugin.
                       DESC
  s.homepage         = 'https://testfairy.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TestFairy' => 'support@testfairy.com' }
  s.source           = { :path => '.' }
  s.source_files = ['Classes/**/*']
  s.public_header_files = ['Classes/**/*.h']
  s.dependency 'Flutter'
  s.static_framework = true
  s.ios.deployment_target = '9.0'

  s.dependency 'TestFairy', '1.29.9'
end

