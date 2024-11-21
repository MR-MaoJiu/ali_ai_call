#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ali_ai_call.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ali_ai_call'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'ENABLE_BITCODE' => 'NO',
    # 添加以下配置以支持静态库
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'VALID_ARCHS' => 'arm64 x86_64',
    'IPHONEOS_DEPLOYMENT_TARGET' => '12.0'
  }
  s.swift_version = '5.0'

  # 添加 ARTCAICallKit 依赖
  s.dependency 'ARTCAICallKit', '~> 1.2.0'
  s.dependency 'AliVCSDK_ARTC', '~> 6.11.3'

  # 添加隐私权限描述
  s.info_plist = {
    'NSMicrophoneUsageDescription' => 'App需要访问麦克风进行AI通话',
    'NSCameraUsageDescription' => 'App需要访问相机进行视频通话'
  }

  # 静态库支持
  s.static_framework = true
end
