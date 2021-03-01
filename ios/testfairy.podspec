#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'testfairy'
  s.version          = '2.0.10'
  s.summary          = 'TestFairy integration for Flutter, bundles with the native iOS SDK'
  s.description      = <<-DESC
TestFairy flutter plugin.
                       DESC
  s.homepage         = 'https://testfairy.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TestFairy' => 'support@testfairy.com' }
  s.source           = { :path => '.' }
  s.source_files = ['Classes/**/*', 'TestFairy.xcframework/**/*.h']
  s.public_header_files = ['Classes/**/*.h', 'TestFairy.xcframework/**/*.h']
  s.dependency 'Flutter'
  s.static_framework = true

  s.ios.deployment_target = '9.0'

# We no longer need this since we embed the xcframework inside the plugin.
# Keeping this here to indicate which SDK version we use
#  s.dependency 'TestFairy', '1.27.4'

  s.preserve_paths = 'TestFairy.xcframework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TestFairy' }
  s.vendored_frameworks = 'TestFairy.xcframework'

end

