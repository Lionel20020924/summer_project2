# ElevenLabs 语音合成配置说明

## 概述
本项目集成了 ElevenLabs 的文本转语音(TTS)功能，为 AI 聊天回复提供高质量的语音输出。

## 功能特性
- 🎤 高质量语音合成
- 🌍 多语言支持（中文/英文）
- 🎛️ 可配置的声音参数
- 📱 实时音频播放控制
- 🔊 自动文本清理和优化

## 配置步骤

### 1. 获取 ElevenLabs API Key
1. 访问 [ElevenLabs 官网](https://elevenlabs.io/)
2. 注册账户（免费账户每月有 10,000 字符额度）
3. 登录后进入个人资料页面
4. 生成并复制您的 API Key

### 2. 配置环境变量
在项目根目录创建或编辑 `.env` 文件：

```bash
# ElevenLabs 配置
ELEVENLABS_API_KEY=your_actual_api_key_here
ELEVENLABS_VOICE_ID=pNInz6obpgDQGcFmaJgB
ELEVENLABS_MODEL=eleven_multilingual_v2
ELEVENLABS_STABILITY=0.5
ELEVENLABS_SIMILARITY_BOOST=0.8
ELEVENLABS_STYLE=0.0
ELEVENLABS_USE_SPEAKER_BOOST=false

# OpenAI 配置 (已存在)
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. 声音配置说明

#### 可用声音 ID
- `pNInz6obpgDQGcFmaJgB` - Adam (默认，英文男声)
- `EXAVITQu4vr4xnSDxMaL` - Bella (英文女声)
- `VR6AewLTigWG4xSOukaG` - Arnold (英文男声)
- 更多声音可通过 ElevenLabs 网站查看

#### 参数调节
- **Stability** (0.0-1.0): 语音稳定性，值越高越稳定
- **Similarity Boost** (0.0-1.0): 声音相似度增强
- **Style** (0.0-1.0): 语音风格强度
- **Speaker Boost**: 声音增强开关

## 使用方法

### 在聊天中使用
1. 发送消息给 AI 助手
2. 等待 AI 回复
3. 点击消息下方的语音按钮
4. 系统会自动生成并播放语音

### 音频控制
- 🎵 播放/暂停音频
- ⏱️ 查看播放进度
- 🔄 重播已生成的语音
- ⚡ 实时播放状态显示

### 配置检查
在聊天界面：
1. 点击右上角"更多"按钮
2. 选择"ElevenLabs 配置"
3. 查看配置状态和测试功能

## 技术细节

### 文本预处理
系统会自动清理文本内容：
- 移除 emoji 表情
- 过滤技术信息和错误提示
- 限制文本长度（500字符以内）
- 优化标点符号和换行

### 音频文件管理
- 音频文件保存在应用文档目录
- 支持自动清理功能
- MP3 格式，高音质输出

### 错误处理
- API 连接测试
- 用户配额检查
- 友好的错误提示

## 故障排除

### 常见问题
1. **"语音生成失败"** - 检查 API Key 是否正确配置
2. **"音频播放失败"** - 检查设备音频权限
3. **"API 密钥未配置"** - 确认 .env 文件中的配置

### 调试信息
查看控制台输出获取详细的调试信息：
- 🎤 TTS 请求状态
- 📁 音频文件路径
- ✅ 播放成功/失败信息

## 费用说明
- 免费账户：每月 10,000 字符
- 付费计划：更高的使用限额和更多声音选择
- 字符计费：按实际转换的字符数计算

## 注意事项
1. 请妥善保管您的 API Key，不要提交到代码仓库
2. 监控您的使用量，避免超出限额
3. 测试不同的声音参数以获得最佳效果
4. 网络连接不稳定可能影响语音生成速度

## 更新日志
- v1.0.0 - 基础 TTS 功能集成
- v1.1.0 - 添加音频播放控制
- v1.2.0 - 优化文本预处理和错误处理 