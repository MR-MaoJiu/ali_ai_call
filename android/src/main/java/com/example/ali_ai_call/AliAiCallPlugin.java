package com.example.ali_ai_call;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.Context;
import android.util.Log;

import com.aliyun.auikits.aiagent.ARTCAICallDepositEngineImpl;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;

import java.util.HashMap;
import java.util.Map;

/** AliAiCallPlugin */
public class AliAiCallPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private static final String TAG = "AiCallKit";
  private Context context;
  private ARTCAICallEngine mARTCAICallEngine;
  private boolean isInCall = false;
  private boolean isJoining = false;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ali_ai_call");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (mARTCAICallEngine == null && !call.method.equals("initEngine")) {
      result.error("NOT_INITIALIZED", "AI Call Engine not initialized", null);
      return;
    }

    switch (call.method) {
      case "initEngine":
        String userId = call.argument("userId");
        Log.e(TAG, "initEngine "+"userId:"+userId+"result:"+result);
        initEngine(userId, result);
        break;
      case "call":
        String rtcToken = call.argument("rtcToken");
        String aiAgentInstanceId = call.argument("aiAgentInstanceId");
        String aiAgentUserId = call.argument("aiAgentUserId");
        String channelId = call.argument("channelId");
        Log.e(TAG, "call "+"rtcToken:"+rtcToken+"aiAgentInstanceId:"+aiAgentInstanceId+"aiAgentUserId:"+aiAgentUserId+"channelId:"+channelId+"result:"+result);
        startCall(rtcToken, aiAgentInstanceId, aiAgentUserId, channelId, result);
        break;
      case "hangup":
        Log.e(TAG, "hangup"+"result"+result);
        hangup(result);
        break;
      case "switchMicrophone":
        Boolean on = call.argument("on");
        Log.e(TAG, "switchMicrophone"+"on"+on+"result"+result);
        switchMicrophone(Boolean.TRUE.equals(on), result);
        break;
      case "enableSpeaker":
        Boolean enable = call.argument("enable");
        Log.e(TAG, "enableSpeaker"+"enable"+enable+"result"+result);
        enableSpeaker(Boolean.TRUE.equals(enable), result);
        break;
      case "interruptSpeaking":
        interruptSpeaking(result);
        break;
      case "enableVoiceInterrupt":
        Boolean interruptEnable = call.argument("enable");
        enableVoiceInterrupt(Boolean.TRUE.equals(interruptEnable), result);
        break;
      case "switchRobotVoice":
        String voiceId = call.argument("voiceId");
        Log.e(TAG, "switchRobotVoice"+"voiceId"+voiceId+"result"+result);
        switchRobotVoice(voiceId, result);
        break;
      case "muteLocalCamera":
        Boolean mute = call.argument("mute");
        muteLocalCamera(Boolean.TRUE.equals(mute), result);
        break;
      case "isLocalCameraMute":
        isLocalCameraMute(result);
        break;
      case "switchCamera":
        switchCamera(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void initEngine(String userId, Result result) {
    try {
      mARTCAICallEngine = new ARTCAICallDepositEngineImpl(context, userId);
      setupEngineCallback();
      result.success(null);
    } catch (Exception e) {
      Log.e(TAG, "Failed to initialize engine", e);
      result.error("INIT_ERROR", "Failed to initialize engine", e.getMessage());
    }
  }

  private void startCall(String rtcToken, String aiAgentInstanceId, String aiAgentUserId,
                        String channelId, Result result) {
    // 检查是否已经在通话中
    if (isInCall || isJoining) {
      result.error("CALL_ERROR", "Already in a call or joining", 
                  "Please end current call before starting a new one");
      return;
    }

    try {
      isJoining = true;

      // 设置engine的启动参数
      ARTCAICallEngine.ARTCAICallConfig config = new ARTCAICallEngine.ARTCAICallConfig();
      mARTCAICallEngine.init(config);

      // 指定智能体的类型为纯语音
      mARTCAICallEngine.setAICallAgentType(ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent);

      // 进入频道
      mARTCAICallEngine.call(rtcToken, aiAgentInstanceId, aiAgentUserId, channelId);
      result.success(null);
    } catch (Exception e) {
      isJoining = false;
      Log.e(TAG, "Failed to start call", e);
      result.error("CALL_ERROR", "Failed to start call", e.getMessage());
    }
  }

  private void hangup(Result result) {
    try {
      mARTCAICallEngine.handup();
      isInCall = false;
      isJoining = false;
      result.success(null);
    } catch (Exception e) {
      Log.e(TAG, "Failed to hang up", e);
      result.error("HANGUP_ERROR", "Failed to hang up", e.getMessage());
    }
  }

  private void switchMicrophone(boolean on, Result result) {
    try {
      mARTCAICallEngine.switchMicrophone(on);
      result.success(true);
    } catch (Exception e) {
      Log.e(TAG, "Failed to switch microphone", e);
      result.error("MIC_ERROR", "Failed to switch microphone", e.getMessage());
    }
  }

  private void enableSpeaker(boolean enable, Result result) {
    try {
      boolean success = mARTCAICallEngine.enableSpeaker(enable);
      result.success(success);
    } catch (Exception e) {
      Log.e(TAG, "Failed to switch speaker", e);
      result.error("SPEAKER_ERROR", "Failed to switch speaker", e.getMessage());
    }
  }

  private void interruptSpeaking(Result result) {
    try {
      boolean success = mARTCAICallEngine.interruptSpeaking();
      result.success(success);
    } catch (Exception e) {
      Log.e(TAG, "Failed to interrupt speaking", e);
      result.error("INTERRUPT_ERROR", "Failed to interrupt speaking", e.getMessage());
    }
  }

  private void enableVoiceInterrupt(boolean enable, Result result) {
    try {
      boolean success = mARTCAICallEngine.enableVoiceInterrupt(enable);
      result.success(success);
    } catch (Exception e) {
      Log.e(TAG, "Failed to enable voice interrupt", e);
      result.error("VOICE_INTERRUPT_ERROR", "Failed to enable voice interrupt", e.getMessage());
    }
  }

  private void switchRobotVoice(String voiceId, Result result) {
    try {
      boolean success = mARTCAICallEngine.switchRobotVoice(voiceId);
      result.success(success);
    } catch (Exception e) {
      Log.e(TAG, "Failed to switch robot voice", e);
      result.error("VOICE_SWITCH_ERROR", "Failed to switch robot voice", e.getMessage());
    }
  }

  private void muteLocalCamera(boolean mute, Result result) {
    try {
      boolean success = mARTCAICallEngine.muteLocalCamera(mute);
      result.success(success);
    } catch (Exception e) {
      Log.e(TAG, "Failed to mute local camera", e);
      result.error("CAMERA_ERROR", "Failed to mute local camera", e.getMessage());
    }
  }

  private void isLocalCameraMute(Result result) {
    try {
      boolean isMute = mARTCAICallEngine.isLocalCameraMute();
      result.success(isMute);
    } catch (Exception e) {
      Log.e(TAG, "Failed to get camera mute state", e);
      result.error("CAMERA_ERROR", "Failed to get camera mute state", e.getMessage());
    }
  }

  private void switchCamera(Result result) {
    try {
      boolean success = mARTCAICallEngine.switchCamera();
      result.success(success);
    } catch (Exception e) {
      Log.e(TAG, "Failed to switch camera", e);
      result.error("CAMERA_ERROR", "Failed to switch camera", e.getMessage());
    }
  }

  private void setAICallAgentType(String agentType, Result result) {
    try {
      ARTCAICallEngine.ARTCAICallAgentType type;
      switch (agentType) {
        case "VoiceAgent":
          type = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
          break;
        case "AvatarAgent":
          type = ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
          break;
        case "VisionAgent":
          type = ARTCAICallEngine.ARTCAICallAgentType.VisionAgent;
          break;
        default:
          result.error("INVALID_TYPE", "Invalid agent type", null);
          return;
      }
      mARTCAICallEngine.setAICallAgentType(type);
      result.success(null);
    } catch (Exception e) {
      Log.e(TAG, "Failed to set AI agent type", e);
      result.error("AGENT_TYPE_ERROR", "Failed to set AI agent type", e.getMessage());
    }
  }

  private void setupEngineCallback() {
    mARTCAICallEngine.setEngineCallback(new ARTCAICallEngine.IARTCAICallEngineCallback() {
      @Override
      public void onErrorOccurs(ARTCAICallEngine.AICallErrorCode errorCode) {
          errorCode.ordinal();
          Log.e(TAG, "onError"+errorCode);
        channel.invokeMethod("onError", errorCode.toString());
      }

      @Override
      public void onCallBegin() {
        isInCall = true;
        isJoining = false;
        Log.e(TAG, "onCallBegin");
        channel.invokeMethod("onCallBegin", null);
      }

      @Override
      public void onCallEnd() {
        isInCall = false;
        isJoining = false;
        Log.e(TAG, "onCallEnd");
        channel.invokeMethod("onCallEnd", null);
      }

      @Override
      public void onUserSpeaking(boolean isSpeaking) {
        Log.e(TAG, "onUserSpeaking"+isSpeaking);
        channel.invokeMethod("onUserSpeaking", isSpeaking);
      }

      @Override
      public void onAICallEngineRobotStateChanged(ARTCAICallEngine.ARTCAICallRobotState oldState,
                                                  ARTCAICallEngine.ARTCAICallRobotState newState) {
        Log.e(TAG, "onRobotStateChanged: " + oldState.toString() + " -> " + newState.toString());
        channel.invokeMethod("onRobotStateChanged", newState.toString());
      }

      @Override
      public void onUserAsrSubtitleNotify(String text, boolean isSentenceEnd, int sentenceId) {
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("text", text);
        arguments.put("isSentenceEnd", isSentenceEnd);
        arguments.put("sentenceId", sentenceId);
        channel.invokeMethod("onUserAsrSubtitleNotify", arguments);
      }

      @Override
      public void onAIAgentSubtitleNotify(String text, boolean end, int userAsrSentenceId) {
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("text", text);
        arguments.put("isSentenceEnd", end);
        arguments.put("userAsrSentenceId", userAsrSentenceId);
        channel.invokeMethod("onAIAgentTTSMessage", arguments);
      }

      // 实现其他必要的回调方法...
      @Override
      public void onNetworkStatusChanged(String uid, ARTCAICallEngine.ARTCAICallNetworkQuality quality) {
        Log.e(TAG, "onNetworkStatusChanged: " + uid + " -> " + quality.toString());
        channel.invokeMethod("onNetworkQuality", quality.ordinal());
      }

      @Override
      public void onVoiceVolumeChanged(String uid, int volume) {
        Map<String, Object> arguments = new HashMap<>();
        arguments.put("uid", uid);
        arguments.put("volume", volume);
        channel.invokeMethod("onVolumeChanged", arguments);
      }

      @Override
      public void onVoiceIdChanged(String voiceId) {
        Log.e(TAG, "onVoiceIdChanged: " + voiceId);
        channel.invokeMethod("onVoiceIdChanged", voiceId);
      }

      @Override
      public void onVoiceInterrupted(boolean enable) {
        Log.e(TAG, "onVoiceInterrupted: " + enable);
        channel.invokeMethod("onVoiceInterrupted", enable);
      }

      @Override
      public void onAgentVideoAvailable(boolean available) {
        Log.e(TAG, "onAgentVideoAvailable: " + available);
        channel.invokeMethod("onAgentVideoAvailable", available);
      }

      @Override
      public void onAgentAudioAvailable(boolean available) {
        Log.e(TAG, "onAgentAudioAvailable: " + available);
        channel.invokeMethod("onAgentAudioAvailable", available);
      }

      @Override
      public void onAgentAvatarFirstFrameDrawn() {
        Log.e(TAG, "onAgentAvatarFirstFrameDrawn");
        channel.invokeMethod("onAgentAvatarFirstFrameDrawn", null);
      }

      @Override
      public void onUserOnLine(String uid) {
        Log.e(TAG, "onUserOnLine: " + uid);
        channel.invokeMethod("onUserOnLine", uid);
      }
    });
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (mARTCAICallEngine != null) {
      try {
        if (isInCall || isJoining) {
          mARTCAICallEngine.handup();
        }
      } catch (Exception e) {
        Log.e(TAG, "Error releasing resources", e);
      } finally {
        mARTCAICallEngine = null;
        isInCall = false;
        isJoining = false;
      }
    }
    channel.setMethodCallHandler(null);
    context = null;
  }
}
