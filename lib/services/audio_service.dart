import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'dart:io';

class AudioService extends GetxController {
  static AudioService get instance => Get.find<AudioService>();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  var isPlaying = false.obs;
  var isPaused = false.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var currentPlayingMessageId = ''.obs;
  var playbackSpeed = 1.0.obs;
  var volume = 1.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _setupAudioPlayer();
    print('🔊 音频服务已初始化');
  }
  
  void _setupAudioPlayer() {
    // 监听播放状态
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlaying.value = state == PlayerState.playing;
      isPaused.value = state == PlayerState.paused;
      
      print('🎵 播放状态变更: $state');
      
      if (state == PlayerState.completed) {
        currentPlayingMessageId.value = '';
        currentPosition.value = Duration.zero;
        print('✅ 音频播放完成');
      }
    });
    
    // 监听播放位置
    _audioPlayer.onPositionChanged.listen((Duration position) {
      currentPosition.value = position;
    });
    
    // 监听总时长
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      totalDuration.value = duration;
      print('⏱️ 音频总时长: ${formatDuration(duration)}');
    });
    
    // 监听播放器错误
    _audioPlayer.onPlayerComplete.listen((event) {
      print('🎵 播放完成事件');
    });
  }
  
  /// 播放音频文件
  Future<bool> playAudio(String filePath, String messageId) async {
    try {
      print('🔊 开始播放音频: $filePath (消息ID: $messageId)');
      
      // 检查文件是否存在
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ 音频文件不存在: $filePath');
        Get.snackbar('错误', '音频文件不存在');
        return false;
      }
      
      // 如果正在播放其他音频，先停止
      if (isPlaying.value && currentPlayingMessageId.value != messageId) {
        print('⏹️ 停止当前播放，切换到新音频');
        await stopAudio();
      }
      
      // 如果是同一个音频
      if (currentPlayingMessageId.value == messageId) {
        if (isPlaying.value) {
          await pauseAudio();
          return true;
        } else if (isPaused.value) {
          await resumeAudio();
          return true;
        }
      }
      
      // 播放新音频
      currentPlayingMessageId.value = messageId;
      
      // 设置音量和播放速度
      await _audioPlayer.setVolume(volume.value);
      await _audioPlayer.setPlaybackRate(playbackSpeed.value);
      
      // 开始播放
      await _audioPlayer.play(DeviceFileSource(filePath));
      
      print('✅ 音频播放开始成功');
      return true;
      
    } catch (e) {
      print('❌ 播放音频失败: $e');
      Get.snackbar('播放错误', '音频播放失败: ${e.toString()}');
      return false;
    }
  }
  
  /// 暂停播放
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      print('⏸️ 音频已暂停');
    } catch (e) {
      print('❌ 暂停音频失败: $e');
    }
  }
  
  /// 恢复播放
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
      print('▶️ 音频已恢复播放');
    } catch (e) {
      print('❌ 恢复音频失败: $e');
    }
  }
  
  /// 停止播放
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      currentPlayingMessageId.value = '';
      currentPosition.value = Duration.zero;
      print('⏹️ 音频已停止');
    } catch (e) {
      print('❌ 停止音频失败: $e');
    }
  }
  
  /// 跳转到指定位置
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      print('🎯 跳转到: ${formatDuration(position)}');
    } catch (e) {
      print('❌ 跳转失败: $e');
    }
  }
  
  /// 设置播放速度
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      playbackSpeed.value = speed;
      await _audioPlayer.setPlaybackRate(speed);
      print('🚀 播放速度设置为: ${speed}x');
      Get.snackbar('播放速度', '已设置为 ${speed}x');
    } catch (e) {
      print('❌ 设置播放速度失败: $e');
    }
  }
  
  /// 设置音量
  Future<void> setVolume(double vol) async {
    try {
      volume.value = vol;
      await _audioPlayer.setVolume(vol);
      print('🔊 音量设置为: ${(vol * 100).toInt()}%');
    } catch (e) {
      print('❌ 设置音量失败: $e');
    }
  }
  
  /// 获取播放进度百分比
  double get playbackProgress {
    if (totalDuration.value.inMilliseconds == 0) return 0.0;
    return currentPosition.value.inMilliseconds / totalDuration.value.inMilliseconds;
  }
  
  /// 格式化时间显示
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// 获取播放状态信息
  String get playbackStatus {
    if (isPlaying.value) {
      return '播放中: ${formatDuration(currentPosition.value)} / ${formatDuration(totalDuration.value)}';
    } else if (isPaused.value) {
      return '已暂停: ${formatDuration(currentPosition.value)} / ${formatDuration(totalDuration.value)}';
    } else {
      return '未播放';
    }
  }
  
  /// 切换播放/暂停状态
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pauseAudio();
    } else if (isPaused.value) {
      await resumeAudio();
    }
  }
  
  /// 检查是否正在播放指定消息的音频
  bool isPlayingMessage(String messageId) {
    return currentPlayingMessageId.value == messageId && isPlaying.value;
  }
  
  /// 检查是否暂停了指定消息的音频
  bool isPausedMessage(String messageId) {
    return currentPlayingMessageId.value == messageId && isPaused.value;
  }
  
  @override
  void onClose() {
    print('🔇 音频服务正在关闭');
    _audioPlayer.dispose();
    super.onClose();
  }
} 