import Flutter
import UIKit
import ARTCAICallKit

@objc public class AliAiCallPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var engine: ARTCAICallEngineInterface?
    private var isInCall: Bool = false
    private var isJoining: Bool = false
    
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
            startCall(rtcToken: rtcToken, 
                     aiAgentInstanceId: aiAgentInstanceId,
                     aiAgentUserId: aiAgentUserId, 
                     channelId: channelId, 
                     result: result)
            
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
    
    private func initEngine(userId: String, result: @escaping FlutterResult) {
        engine = ARTCAICallEngineFactory.createEngine()
        setupEngineCallback()
        result(nil)
    }
    
    private func startCall(rtcToken: String, aiAgentInstanceId: String, 
                          aiAgentUserId: String, channelId: String, 
                          result: @escaping FlutterResult) {
        if isInCall || isJoining {
            result(FlutterError(code: "CALL_ERROR",
                              message: "Already in a call or joining",
                              details: "Please end current call before starting a new one"))
            return
        }
        
        isJoining = true
        
        let agentInfo = ARTCAICallAgentInfo(agentType: ARTCAICallAgentType.VoiceAgent,
                                          channelId: channelId,
                                          uid: aiAgentUserId,
                                          instanceId: aiAgentInstanceId)
        
        engine?.call(userId: aiAgentUserId, token: rtcToken, agentInfo: agentInfo) { [weak self] error in
            self?.isJoining = false
            
            if let error = error {
                result(FlutterError(code: "CALL_ERROR",
                                  message: "Failed to start call",
                                  details: error.localizedDescription))
            } else {
                self?.isInCall = true
                result(nil)
            }
        }
    }
    
    private func hangup(result: @escaping FlutterResult) {
        engine?.handup(true)
        isInCall = false
        isJoining = false
        result(nil)
    }
    
    private func switchMicrophone(on: Bool, result: @escaping FlutterResult) {
        if let success = engine?.muteMicrophone(mute: !on) {
            result(success)
        } else {
            result(false)
        }
    }
    
    private func enableSpeaker(enable: Bool, result: @escaping FlutterResult) {
        if let success = engine?.enableSpeaker(enable: enable) {
            result(success)
        } else {
            result(false)
        }
    }
    
    private func interruptSpeaking(result: @escaping FlutterResult) {
        let success = engine?.interruptSpeaking() ?? false
        result(success)
    }
    
    private func enableVoiceInterrupt(enable: Bool, result: @escaping FlutterResult) {
        let success = engine?.enableVoiceInterrupt(enable: enable) ?? false
        result(success)
    }
    
    private func switchRobotVoice(voiceId: String, result: @escaping FlutterResult) {
        let success = engine?.switchVoiceId(voiceId: voiceId) ?? false
        result(success)
    }
    
    private func setupEngineCallback() {
        engine?.delegate = self
    }
}

// MARK: - ARTCAICallEngineDelegate
extension AliAiCallPlugin: ARTCAICallEngineDelegate {
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        if code.rawValue >= 1000 {
            isInCall = false
            isJoining = false
        }
        channel?.invokeMethod("onError", arguments: code.rawValue)
    }
    
    public func onCallBegin() {
        isInCall = true
        isJoining = false
        channel?.invokeMethod("onCallBegin", arguments: nil)
    }
    
    public func onCallEnd() {
        isInCall = false
        isJoining = false
        channel?.invokeMethod("onCallEnd", arguments: nil)
    }
    
    public func onAgentStateChanged(state: ARTCAICallAgentState) {
        channel?.invokeMethod("onRobotStateChanged", arguments: state.rawValue)
    }
    
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int ,voicePrintStatus: ARTCAICallVoiceprintResult) {
        let arguments: [String: Any] = [
            "text": text,
            "isSentenceEnd": isSentenceEnd,
            "sentenceId": sentenceId,
            "voicePrintStatus": voicePrintStatus.rawValue
        ]
        channel?.invokeMethod("onUserAsrSubtitleNotify", arguments: arguments)
    }
    
    public func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        let arguments: [String: Any] = [
            "text": text,
            "isSentenceEnd": isSentenceEnd,
            "userAsrSentenceId": userAsrSentenceId
        ]
        channel?.invokeMethod("onAIAgentSubtitleNotify", arguments: arguments)
    }
    
    public func onVoiceIdChanged(voiceId: String) {
        channel?.invokeMethod("onVoiceIdChanged", arguments: voiceId)
    }
    
    public func onVoiceInterrupted(enable: Bool) {
        channel?.invokeMethod("onVoiceInterrupted", arguments: enable)
    }
    
    public func onAgentVideoAvailable(available: Bool) {
        channel?.invokeMethod("onAgentVideoAvailable", arguments: available)
    }
    
    public func onAgentAudioAvailable(available: Bool) {
        channel?.invokeMethod("onAgentAudioAvailable", arguments: available)
    }
    
    public func onAgentAvatarFirstFrameDrawn() {
        channel?.invokeMethod("onAgentAvatarFirstFrameDrawn", arguments: nil)
    }
    
    public func onVoiceVolumeChanged(uid: String, volume: Int32) {
        let arguments: [String: Any] = [
            "uid": uid,
            "volume": volume
        ]
        channel?.invokeMethod("onVolumeChanged", arguments: arguments)
    }
}
