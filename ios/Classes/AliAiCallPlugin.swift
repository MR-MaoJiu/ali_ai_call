import Flutter
import UIKit
import ARTCAICallKit

/// 阿里云 AI 通话 Flutter 插件（iOS 端）
/// 对齐官方文档：https://help.aliyun.com/zh/ims/user-guide/integration-overview-1
@objc public class AliAiCallPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var engine: ARTCAICallEngineInterface?
    /// 当前通话状态标志
    private var isInCall: Bool = false
    private var isJoining: Bool = false
    /// 保存初始化时传入的本地用户ID
    private var localUserId: String = ""
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ali_ai_call", binaryMessenger: registrar.messenger())
        let instance = AliAiCallPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if engine == nil && call.method != "initEngine" {
            result(FlutterError(code: "NOT_INITIALIZED",
                              message: "AI Call Engine not initialized",
                              details: nil))
            return
        }
        
        switch call.method {
        case "initEngine":
            guard let args = call.arguments as? [String: Any],
                  let userId = args["userId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing or invalid userId",
                                  details: nil))
                return
            }
            initEngine(userId: userId, result: result)
            
        case "call":
            guard let args = call.arguments as? [String: Any],
                  let rtcToken = args["rtcToken"] as? String,
                  let aiAgentInstanceId = args["aiAgentInstanceId"] as? String,
                  let aiAgentUserId = args["aiAgentUserId"] as? String,
                  let channelId = args["channelId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing or invalid call parameters",
                                  details: nil))
                return
            }
            // 智能体模板ID（控制台创建）优先使用传入值，兜底使用实例ID
            let aiAgentId = (args["aiAgentId"] as? String) ?? aiAgentInstanceId
            // 当前用户ID，优先使用传入值，兜底使用 initEngine 时保存的 ID
            let userId = (args["userId"] as? String) ?? localUserId
            startCall(
                rtcToken: rtcToken,
                aiAgentId: aiAgentId,
                aiAgentInstanceId: aiAgentInstanceId,
                aiAgentUserId: aiAgentUserId,
                channelId: channelId,
                userId: userId,
                result: result
            )
            
        case "hangup":
            hangup(result: result)
            
        case "switchMicrophone":
            guard let args = call.arguments as? [String: Any],
                  let on = args["on"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing or invalid microphone state",
                                  details: nil))
                return
            }
            switchMicrophone(on: on, result: result)
            
        case "enableSpeaker":
            guard let args = call.arguments as? [String: Any],
                  let enable = args["enable"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing or invalid speaker state",
                                  details: nil))
                return
            }
            enableSpeaker(enable: enable, result: result)
            
        case "interruptSpeaking":
            interruptSpeaking(result: result)
            
        case "enableVoiceInterrupt":
            guard let args = call.arguments as? [String: Any],
                  let enable = args["enable"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing or invalid voice interrupt state",
                                  details: nil))
                return
            }
            enableVoiceInterrupt(enable: enable, result: result)
            
        case "switchRobotVoice":
            guard let args = call.arguments as? [String: Any],
                  let voiceId = args["voiceId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Missing or invalid voiceId",
                                  details: nil))
                return
            }
            switchRobotVoice(voiceId: voiceId, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// 步骤二：创建并初始化引擎
    private func initEngine(userId: String, result: @escaping FlutterResult) {
        localUserId = userId
        engine = ARTCAICallEngineFactory.createEngine()
        // 步骤三：设置回调代理
        engine?.delegate = self
        result(nil)
    }
    
    /// 步骤五：发起智能体呼叫（call[1/2] - 服务端托管模式）
    /// 使用服务端已启动好的智能体实例信息加入通话
    private func startCall(
        rtcToken: String,
        aiAgentId: String,
        aiAgentInstanceId: String,
        aiAgentUserId: String,
        channelId: String,
        userId: String,
        result: @escaping FlutterResult
    ) {
        if isInCall || isJoining {
            result(FlutterError(code: "CALL_ERROR",
                              message: "Already in a call or joining",
                              details: "Please end current call before starting a new one"))
            return
        }
        
        isJoining = true
        
        // 按官方文档构造 ARTCAICallAgentInfo
        // agentId:      智能体模板ID（控制台配置的 Agent ID）
        // agentType:    智能体类型，当前使用纯语音模式
        // channelId:    RTC 频道ID
        // uid:          智能体在频道中的用户ID
        // instanceId:   智能体运行实例ID（服务端启动后返回）
        let agentInfo = ARTCAICallAgentInfo(
            agentId: aiAgentId,
            agentType: ARTCAICallAgentType.VoiceAgent,
            channelId: channelId,
            uid: aiAgentUserId,
            instanceId: aiAgentInstanceId
        )
        
        // call[1/2]：服务端已呼叫智能体，端侧使用此接口加入
        // userId：当前登录用户的ID（非智能体ID）
        engine?.call(userId: userId, token: rtcToken, agentInfo: agentInfo) { [weak self] error in
            guard let self = self else { return }
            self.isJoining = false
            
            if let error = error {
                result(FlutterError(code: "CALL_ERROR",
                                  message: "Failed to start call",
                                  details: error.localizedDescription))
            } else {
                self.isInCall = true
                result(nil)
            }
        }
    }
    
    /// 步骤七：挂断通话
    private func hangup(result: @escaping FlutterResult) {
        // 参数 true 表示同时结束当前智能体任务
        engine?.handup(true)
        isInCall = false
        isJoining = false
        result(nil)
    }
    
    /// 静音/取消静音麦克风
    private func switchMicrophone(on: Bool, result: @escaping FlutterResult) {
        let success = engine?.muteMicrophone(mute: !on) ?? false
        result(success)
    }
    
    /// 开启/关闭扬声器
    private func enableSpeaker(enable: Bool, result: @escaping FlutterResult) {
        let success = engine?.enableSpeaker(enable: enable) ?? false
        result(success)
    }
    
    /// 打断智能体讲话
    private func interruptSpeaking(result: @escaping FlutterResult) {
        let success = engine?.interruptSpeaking() ?? false
        result(success)
    }
    
    /// 开启/关闭智能语音打断
    private func enableVoiceInterrupt(enable: Bool, result: @escaping FlutterResult) {
        let success = engine?.enableVoiceInterrupt(enable: enable) ?? false
        result(success)
    }
    
    /// 切换智能体音色
    private func switchRobotVoice(voiceId: String, result: @escaping FlutterResult) {
        let success = engine?.switchVoiceId(voiceId: voiceId) ?? false
        result(success)
    }
    
    /// 将 ARTCAICallAgentState 转换为与 Android 对齐的字符串描述
    private func agentStateToString(_ state: ARTCAICallAgentState) -> String {
        switch state {
        case .Listening: return "Listening"
        case .Thinking:  return "Thinking"
        case .Speaking:  return "Speaking"
        default:         return "\(state.rawValue)"
        }
    }
    
    /// 将 ARTCAICallNetworkQuality 转换为整数序数（与 Android ordinal() 对齐）
    private func networkQualityToInt(_ quality: ARTCAICallNetworkQuality) -> Int {
        switch quality {
        case .Excellent:    return 0
        case .Good:         return 1
        case .Poor:         return 2
        case .Bad:          return 3
        case .VeryBad:      return 4
        case .Disconnect:   return 5
        default:            return 6
        }
    }
}

// MARK: - ARTCAICallEngineDelegate（步骤三：实现回调）
extension AliAiCallPlugin: ARTCAICallEngineDelegate {
    
    /// 发生了错误
    /// 注意：发送 String 类型与 Android 侧 errorCode.toString() 保持一致
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        // 错误码 >= 1000 视为致命错误，重置通话状态
        if code.rawValue >= 1000 {
            isInCall = false
            isJoining = false
        }
        channel?.invokeMethod("onError", arguments: "\(code.rawValue)")
    }
    
    /// 通话开始
    public func onCallBegin() {
        isInCall = true
        isJoining = false
        channel?.invokeMethod("onCallBegin", arguments: nil)
    }
    
    /// 通话结束
    public func onCallEnd() {
        isInCall = false
        isJoining = false
        channel?.invokeMethod("onCallEnd", arguments: nil)
    }
    
    /// 智能体状态改变（聆听中/思考中/讲话中）
    /// 发送 String 类型与 Android 侧 newState.toString() 保持一致
    public func onAgentStateChanged(state: ARTCAICallAgentState) {
        channel?.invokeMethod("onAIAgentStateChanged", arguments: agentStateToString(state))
    }
    
    /// 网络状态改变
    /// 发送整数序数与 Android 侧 quality.ordinal() 保持一致
    public func onNetworkStatusChanged(uid: String, quality: ARTCAICallNetworkQuality) {
        channel?.invokeMethod("onNetworkQuality", arguments: networkQualityToInt(quality))
    }
    
    /// 用户提问被智能体识别结果的通知（ASR 字幕）
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int) {
        let arguments: [String: Any] = [
            "text": text,
            "isSentenceEnd": isSentenceEnd,
            "sentenceId": sentenceId,
            // iOS 当前 SDK 版本无声纹状态，统一返回 disable 与 Android 对齐
            "voicePrintStatus": "disable"
        ]
        channel?.invokeMethod("onUserAsrSubtitleNotify", arguments: arguments)
    }
    
    /// 智能体回答结果通知（TTS 字幕）
    public func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        let arguments: [String: Any] = [
            "text": text,
            "isSentenceEnd": isSentenceEnd,
            "userAsrSentenceId": userAsrSentenceId
        ]
        channel?.invokeMethod("onAIAgentSubtitleNotify", arguments: arguments)
    }
    
    /// 音色变化通知
    public func onVoiceIdChanged(voiceId: String) {
        channel?.invokeMethod("onVoiceIdChanged", arguments: voiceId)
    }
    
    /// 语音打断开关状态变化
    public func onVoiceInterrupted(enable: Bool) {
        channel?.invokeMethod("onVoiceInterrupted", arguments: enable)
    }
    
    /// 智能体视频流是否可用
    public func onAgentVideoAvailable(available: Bool) {
        channel?.invokeMethod("onAgentVideoAvailable", arguments: available)
    }
    
    /// 智能体音频流是否可用
    public func onAgentAudioAvailable(available: Bool) {
        channel?.invokeMethod("onAgentAudioAvailable", arguments: available)
    }
    
    /// 数字人首帧渲染完成
    public func onAgentAvatarFirstFrameDrawn() {
        channel?.invokeMethod("onAgentAvatarFirstFrameDrawn", arguments: nil)
    }
    
    /// 音量变化通知
    public func onVoiceVolumeChanged(uid: String, volume: Int32) {
        let arguments: [String: Any] = [
            "uid": uid,
            "volume": volume
        ]
        channel?.invokeMethod("onVolumeChanged", arguments: arguments)
    }
}
