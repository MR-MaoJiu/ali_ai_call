#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ali_ai_call.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ali_ai_call'
  s.version          = '1.0.0'
  s.summary          = 'Ali AI Call Plugin'
  s.description      = <<-DESC
A Flutter plugin for Ali AI Call Kit.
                       DESC
  s.homepage         = 'http://pintheworld.cn'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Abandon' => 'lovemaojiu@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.platform = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  # 修改 Flutter 依赖配置
  s.dependency 'Flutter'
  s.dependency 'ARTCAICallKit', '~> 1.2.0'
  s.dependency 'AliVCSDK_ARTC', '~> 6.11.3'

  # 确保包含 Flutter.framework
  s.ios.framework = ['Flutter']
  s.preserve_paths = 'Flutter.framework'

  s.xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => [
      '$(PODS_ROOT)/ARTCAICallKit',
      '$(PODS_ROOT)/AliVCSDK_ARTC',
      '"${PODS_ROOT}/../.symlinks/flutter/ios"',  # 添加 Flutter framework 路径
      '"${PODS_CONFIGURATION_BUILD_DIR}/Flutter"'  # 添加 Flutter build 路径
    ].join(' ')
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  s.swift_version = '5.0'
  s.static_framework = true

  s.info_plist = {
    'NSMicrophoneUsageDescription' => 'App需要访问麦克风进行AI通话',
    'NSCameraUsageDescription' => 'App需要访问相机进行视频通话'
  }
end