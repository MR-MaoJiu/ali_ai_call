/// 声纹状态码
/// 用于标识当前声纹识别的状态
enum VoicePrintStatusCode {
  /// 声纹识别功能已禁用
  disable,

  /// 声纹识别功能已启用但用户未注册声纹
  enableWithoutRegister,

  /// 已成功识别说话人的声纹
  speakerRecognized,

  /// 未能识别说话人的声纹
  speakerNotRecognized,

  /// 未知状态
  unknown;

  /// 从字符串转换为枚举值
  ///
  /// [value] 状态码字符串
  /// 返回对应的 [VoicePrintStatusCode] 枚举值
  static VoicePrintStatusCode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'disable':
        return VoicePrintStatusCode.disable;
      case 'enablewithoutregister':
        return VoicePrintStatusCode.enableWithoutRegister;
      case 'speakerrecognized':
        return VoicePrintStatusCode.speakerRecognized;
      case 'speakernotrecognized':
        return VoicePrintStatusCode.speakerNotRecognized;
      default:
        return VoicePrintStatusCode.unknown;
    }
  }
}
