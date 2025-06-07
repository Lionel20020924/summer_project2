import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../config/elevenlabs_config.dart';

class ElevenLabsService {
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  
  /// 文本转语音
  static Future<String?> textToSpeech(String text) async {
    try {
      print('🎤 开始文本转语音: ${text.length > 50 ? text.substring(0, 50) + "..." : text}');
      
      // 检查配置
      if (!ElevenLabsConfig.isConfigured) {
        print('❌ ElevenLabs API 密钥未配置');
        return null;
      }
      
      // 清理文本内容，移除emoji和特殊字符
      final cleanText = _cleanTextForTTS(text);
      if (cleanText.isEmpty) {
        print('⚠️ 清理后的文本为空，跳过语音合成');
        return null;
      }
      
      // 准备请求数据
      final requestData = {
        'text': cleanText,
        'model_id': ElevenLabsConfig.model,
        'voice_settings': {
          'stability': ElevenLabsConfig.stability,
          'similarity_boost': ElevenLabsConfig.similarityBoost,
          'style': ElevenLabsConfig.style,
          'use_speaker_boost': ElevenLabsConfig.useSpeakerBoost,
        }
      };
      
      print('🔄 调用 ElevenLabs TTS API...');
      print('🗣️ Voice ID: ${ElevenLabsConfig.voiceId}');
      print('🎛️ 模型: ${ElevenLabsConfig.model}');
      print('📝 处理后文本: $cleanText');
      
      // 发送请求
      final response = await http.post(
        Uri.parse('$baseUrl/text-to-speech/${ElevenLabsConfig.voiceId}'),
        headers: {
          'Content-Type': 'application/json',
          'xi-api-key': ElevenLabsConfig.apiKey,
        },
        body: json.encode(requestData),
      );
      
      if (response.statusCode == 200) {
        // 保存音频文件
        final audioData = response.bodyBytes;
        final filePath = await _saveAudioFile(audioData);
        
        print('✅ 语音合成成功');
        print('📁 音频文件路径: $filePath');
        print('📊 文件大小: ${(audioData.length / 1024).toStringAsFixed(2)} KB');
        return filePath;
      } else {
        print('❌ ElevenLabs API 错误: ${response.statusCode}');
        print('📄 响应内容: ${response.body}');
        return null;
      }
      
    } catch (e) {
      print('❌ 文本转语音失败: $e');
      return null;
    }
  }
  
  /// 清理文本，去除不适合TTS的内容
  static String _cleanTextForTTS(String text) {
    // 移除emoji
    String cleaned = text.replaceAll(RegExp(r'[\u{1f300}-\u{1f6ff}]', unicode: true), '');
    
    // 移除特殊符号和提示信息
    cleaned = cleaned.replaceAll(RegExp(r'[💡🔑📝❌⚠️⏰💳✅🤖📁📊🎤🔄🗣️🎛️]'), '');
    
    // 移除网址
    cleaned = cleaned.replaceAll(RegExp(r'https?://\S+'), '');
    
    // 移除多余的换行和空格
    cleaned = cleaned.replaceAll(RegExp(r'\n+'), '。 ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // 移除以特定前缀开头的技术信息行
    final lines = cleaned.split('。');
    final filteredLines = lines.where((line) {
      final trimmed = line.trim();
      return !trimmed.startsWith('•') && 
             !trimmed.startsWith('如果遇到') &&
             !trimmed.startsWith('请在') &&
             !trimmed.contains('网络诊断') &&
             !trimmed.contains('API') &&
             !trimmed.contains('密钥') &&
             trimmed.isNotEmpty;
    }).toList();
    
    cleaned = filteredLines.join('。 ').trim();
    
    // 限制长度（ElevenLabs有字符限制）
    if (cleaned.length > 500) {
      cleaned = cleaned.substring(0, 500) + '...';
    }
    
    return cleaned;
  }
  
  /// 保存音频文件到本地
  static Future<String> _saveAudioFile(Uint8List audioData) async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${directory.path}/audio');
    
    // 确保音频目录存在
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    // 生成唯一文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${audioDir.path}/speech_$timestamp.mp3';
    
    // 写入文件
    final file = File(filePath);
    await file.writeAsBytes(audioData);
    
    return filePath;
  }
  
  /// 获取可用声音列表
  static Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      print('🎭 获取可用声音列表...');
      
      if (!ElevenLabsConfig.isConfigured) {
        return [];
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/voices'),
        headers: {
          'xi-api-key': ElevenLabsConfig.apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final voices = data['voices'] as List;
        
        print('✅ 获取到 ${voices.length} 个声音');
        return voices.cast<Map<String, dynamic>>();
      } else {
        print('❌ 获取声音列表失败: ${response.statusCode}');
        return [];
      }
      
    } catch (e) {
      print('❌ 获取声音列表异常: $e');
      return [];
    }
  }
  
  /// 测试API连接
  static Future<bool> testConnection() async {
    try {
      print('🧪 测试 ElevenLabs API 连接...');
      
      if (!ElevenLabsConfig.isConfigured) {
        print('❌ API 密钥未配置');
        return false;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'xi-api-key': ElevenLabsConfig.apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        print('✅ ElevenLabs API 连接测试成功');
        final userData = json.decode(response.body);
        print('👤 用户信息: ${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}');
        return true;
      } else {
        print('❌ 连接测试失败: ${response.statusCode}');
        print('📄 错误信息: ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ 连接测试异常: $e');
      return false;
    }
  }
  
  /// 获取用户信息和配额
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      if (!ElevenLabsConfig.isConfigured) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'xi-api-key': ElevenLabsConfig.apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('📊 用户配额信息: ${userData['subscription']}');
        return userData;
      }
      
      return null;
    } catch (e) {
      print('❌ 获取用户信息失败: $e');
      return null;
    }
  }
  
  /// 删除本地音频文件
  static Future<void> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ 音频文件已删除: $filePath');
      }
    } catch (e) {
      print('❌ 删除音频文件失败: $e');
    }
  }
  
  /// 清理所有本地音频文件
  static Future<void> clearAllAudioFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${directory.path}/audio');
      
      if (await audioDir.exists()) {
        final files = await audioDir.list().toList();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
        print('🗑️ 所有音频文件已清理，共删除 ${files.length} 个文件');
      }
    } catch (e) {
      print('❌ 清理音频文件失败: $e');
    }
  }
  
  /// 获取服务状态信息
  static String getServiceStatus() {
    return '''
🎤 ElevenLabs 服务状态:
${ElevenLabsConfig.configSummary}

📋 支持的功能:
• 文本转语音 (TTS)
• 多语言支持 (中文/英文)
• 音频文件管理
• 声音列表获取
• 用户配额查询
''';
  }
} 