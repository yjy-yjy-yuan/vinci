# Vinci - 在线第一视角视频语言助手

<a href="https://arxiv.org/abs/2503.04250"><img src="https://img.shields.io/badge/cs.CV-2412.21080-b31b1b?logo=arxiv&logoColor=red"></a>
<a href="https://huggingface.co/hyf015/Vinci-8B-ckpt"><img src="https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-blue"></a>

> **Vinci: 基于第一视角视觉语言模型的实时具身智能助手**<br>
> Arxiv, 2024

## 快速了解

Vinci 是一个可以实时处理的具身智能助手，专为智能手机和可穿戴摄像头设计。它能够：
- 📱 **便携设备运行**：在手机和可穿戴摄像头上"始终在线"运行
- 🎤 **免手交互**：通过自然语音对话提问，获取语音回复
- 🎬 **实时视频处理**：处理长视频流，回答关于当前和历史观察的问题
- 🧭 **任务规划与指导**：基于历史对话进行任务规划，生成视觉任务演示

## 演示视频

[演示视频1](https://github.com/user-attachments/assets/ab019895-a7fe-4a1c-aa91-5a1e06dd4f2b)

[演示视频2](https://github.com/user-attachments/assets/6be2aa5c-81bb-4a85-b1cf-f08e30d97903)

---

## 完整安装指南

### 第一步：克隆代码库

打开终端，执行以下命令：

```bash
git clone https://github.com/OpenGVLab/vinci.git
cd vinci
```

### 第二步：创建 conda 环境

**对于 macOS 用户（Apple Silicon）：**

```bash
conda env create -f environment.macos.yml
conda activate vinci
```

**对于 Linux + NVIDIA CUDA 用户：**

```bash
conda env create -f environment.linux-cuda.yml
conda activate vinci
```

**对于其他情况：**

```bash
conda env create -f environment.yml
conda activate vinci
```

### 第三步：下载模型权重

**方式一：完整下载（包含视频生成功能，>100GB）**

```bash
bash download.sh
```

这将下载所有模型，包括：
- `Vinci-8B-base` - 核心对话/问答模型
- `Vinci-8B-ckpt` - 检查点模型
- `seine_weights` - 视频生成模型（用于未来视频预测）

**方式二：最小化下载（仅对话/问答功能，节省约 20GB+）**

如果你不需要"生成未来视频"功能，可以节省大量存储空间：

```bash
bash download_minimal.sh
```

这只会下载：
- `Vinci-8B-base` - 核心对话/问答模型
- `Vinci-8B-ckpt` - 检查点模型

**没有 `seine_weights` 时系统仍可正常运行**，只是视频生成功能会被禁用。后续如需添加：

```bash
git clone https://huggingface.co/hyf015/seine_weights
```

下载完成后，你的目录结构应该包含模型文件。

---

## 使用方式一：在线视频流演示

这个方式适合实时摄像头推流和语音交互。

### 第一步：启动服务

在项目根目录下运行：

```bash
./boot.sh start
```

**可选参数说明：**

| 参数 | 选项 | 说明 | 默认值 |
|------|------|------|--------|
| `--device` | `auto` / `cuda` / `mps` / `cpu` | 运行设备选择 | `auto` |
| `--cuda` | `0` / `0,1` 等 | CUDA 显卡索引 | - |
| `--language` | `chn` / `eng` | 演示语言 | `chn` |
| `--version` | `v0` / `v1` | 模型版本 | `v1` |

**示例：**

```bash
# 使用默认设置
./boot.sh start

# 指定使用 CUDA，显卡 0
./boot.sh start --device cuda --cuda 0

# 使用 macOS MPS，英文界面
./boot.sh start --device mps --language eng
```

**设备选择说明：**
- `auto`：自动选择 `cuda -> mps -> cpu`
- `cuda`：Linux + NVIDIA GPU 推荐
- `mps`：macOS (Apple Silicon) 推荐
- `cpu`：通用 CPU 运行（较慢）

**模型版本说明：**
- `v0`：专为第一视角视频优化
- `v1`：通用模型，支持第一视角和第三视角视频

### 第二步：访问前端页面

在浏览器中打开：

```
http://YOUR_IP_ADDRESS:19333
```

例如：`http://192.168.1.100:19333` 或 `http://localhost:19333`

### 第三步：推送视频流

**方式一：使用手机或 GoPro/DJI 相机**

推流地址：`rtmp://YOUR_IP_ADDRESS/vinci/livestream`

**方式二：使用 Linux 摄像头**

```bash
ffmpeg -f video4linux2 -framerate 30 -video_size 1280x720 \
  -i /dev/video1 -f alsa -i default \
  -vcodec libx264 -preset ultrafast -pix_fmt yuv420p \
  -video_size 1280x720 -c:a aac -threads 0 \
  -f flv rtmp://YOUR_IP_ADDRESS:1935/vinci/livestream
```

注意：`/dev/video1` 可能需要根据你的设备调整为 `/dev/video0`

**方式三：使用 macOS 摄像头**

```bash
ffmpeg -f avfoundation -framerate 30 -video_size 1280x720 \
  -i "0:0" -vcodec libx264 -preset ultrafast \
  -pix_fmt yuv420p -c:a aac \
  -f flv rtmp://YOUR_IP_ADDRESS:1935/vinci/livestream
```

### 第四步：与 Vinci 交互

1. **唤醒模型**：说 "你好望舒 (Ni hao wang shu)" 来唤醒模型（目前只支持中文唤醒词）

2. **开始对话**：唤醒后，你可以用语音与 Vinci 对话，模型会以文字和语音回复

   *提示：说话清晰，语速适中，体验最佳。*

3. **生成可视化动作预测**：在命令中包含关键词 "可视化 (Ke shi hua)"，模型会生成动作预测可视化

### 停止服务

```bash
./boot.sh stop
```

重启服务：

```bash
./boot.sh restart
```

---

## 使用方式二：Gradio 本地演示（上传视频）

这个方式适合分析本地视频文件。

### 第一步：启动演示

```bash
python demovl.py
```

**可选参数：**

| 参数 | 选项 | 说明 | 默认值 |
|------|------|------|--------|
| `--device` | `auto` / `cuda` / `mps` / `cpu` | 运行设备选择 | `auto` |
| `--language` | `chn` / `eng` | 演示语言 | `chn` |
| `--version` | `v0` / `v1` | 模型版本 | `v1` |

**示例：**

```bash
# 默认设置
python demovl.py

# 使用 MPS，英文界面
python demovl.py --device mps --language eng
```

### 第二步：使用界面

启动后会自动在浏览器中打开 Gradio 界面，按照以下步骤操作：

1. **上传本地视频文件**
   - 点击 "Upload" 按钮选择视频文件

2. **点击 "Upload & Start Chat" 按钮**
   - 开始会话

3. **点击播放按钮**
   - 开始播放视频

4. **调整 Memory Stride（记忆步长）**
   - 控制模型记忆的粒度
   - 步长越小，记忆越详细

5. **实时交互**
   - 在聊天框中输入问题
   - 模型会基于当前帧和历史上下文回答

**支持的功能示例：**

| 功能 | 示例问题 |
|------|----------|
| 描述当前动作 | "我现在在做什么？" |
| 检索历史信息 | "我刚才看到了什么？" |
| 总结之前的行为 | "总结一下我刚才做了什么" |
| 场景理解 | "这里是什么地方？" |
| 时序定位 | "什么时候我拿起了杯子？" |
| 预测未来动作 | "我接下来会做什么？" |

6. **生成未来视频**
   - 基于当前帧和历史上下文，生成短时未来视频

---

## 系统要求

| 项目 | 要求 |
|------|------|
| Python | 3.9 及以上 |
| PyTorch | 2.0 及以上（推荐） |
| 操作系统 | macOS (Apple Silicon) / Linux |
| 运行设备 | macOS: `mps` 或 `cpu`；Linux GPU: `cuda` |
| 部署要求 | Docker（视频流演示） / Gradio（本地演示） |
| 磁盘空间 | >100GB（模型权重） |

---

## 故障排查

### 问题 1：conda 环境创建失败

**解决方案：** 确保已安装 Anaconda 或 Miniconda，并更新到最新版本

```bash
conda update conda
```

### 问题 2：模型下载失败

**解决方案：** 检查网络连接，可能需要配置代理或使用镜像源

### 问题 3：ffmpeg 推流失败

**解决方案：**
- 确认 ffmpeg 已安装：`ffmpeg -version`
- 检查摄像头设备路径：Linux 上用 `ls /dev/video*`
- macOS 上用 `ffmpeg -f avfoundation -list_devices true -i ""` 查看可用设备

### 问题 4：CUDA 不可用

**解决方案：**
- 确认 NVIDIA 驱动已安装：`nvidia-smi`
- 检查 CUDA 版本：`nvcc --version`
- 确保 PyTorch 安装了 CUDA 版本

### 问题 5：MPS 在 macOS 上不可用

**解决方案：**
- 确认使用的是 Apple Silicon 芯片（M1/M2/M3）
- 更新 macOS 到最新版本
- 使用 `--device cpu` 作为备选方案

---

## 项目名称的含义

**Vinci** 这个名字蕴含了多层含义：

- 受文艺复兴大师 Leonardo da **Vinci** 启发，象征知识与洞察力，暗示该助手能提供卓越的服务
- "Vinci" 源自拉丁语 "vincere"，意为"征服"或"克服"，寓意帮助用户克服各种困难和挑战
- 发音上接近 "Vision"，突出了助手基于视觉信息分析和响应的核心功能
- 代表优雅、智慧与创新的融合，与第一视角摄像设备的高科技特性相得益彰

**望舒** —— 出自《楚辞·离骚》："前望舒使先驱兮，后飞廉使奔属。"

望舒是神话传说中替月亮驾车的天神，象征着引导和指引的意义。

---

## 引用

如果这项工作对你的研究有帮助，请考虑引用我们：

```bibtex
@article{vinci,
  title={Vinci: A Real-time Embodied Smart Assistant based on Egocentric Vision-Language Model},
  author={Huang, Yifei and Xu, Jilan and Pei, Baoqi and He, Yuping and Chen, Guo and Yang, Lijin and Chen, Xinyuan and Wang, Yaohui and Nie, Zheng and Liu, Jinyao and Fan, Guoshun and Lin, Dechen and Fang, Fang and Li, Kunpeng and Yuan, Chang and Wang, Yali and Qiao, Yu and Wang, Limin},
  journal={arXiv preprint arXiv:2412.21080},
  year={2024}
}
```

相关工作：

```bibtex
@article{pei2024egovideo,
  title={EgoVideo: Exploring Egocentric Foundation Model and Downstream Adaptation},
  author={Pei, Baoqi and Chen, Guo and Xu, Jilan and He, Yuping and Liu, Yicheng and Pan, Kanghua and Huang, Yifei and Wang, Yali and Lu, Tong and Wang, Limin and Qiao, Yu},
  journal={arXiv preprint arXiv:2406.18070},
  year={2024}
}
```

```bibtex
@inproceedings{xu2024retrieval,
  title={Retrieval-augmented egocentric video captioning},
  author={Xu, Jilan and Huang, Yifei and Hou, Junlin and Chen, Guo and Zhang, Yuejie and Feng, Rui and Xie, Weidi},
  booktitle={Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition},
  pages={13525--13536},
  year={2024}
}
```

```bibtex
@InProceedings{huang2024egoexolearn,
  title={EgoExoLearn: A Dataset for Bridging Asynchronous Ego- and Exo-centric View of Procedural Activities in Real World},
  author={Huang, Yifei and Chen, Guo and Xu, Jilan and Zhang, Mingfang and Yang, Lijin and Pei, Baoqi and Zhang, Hongjie and Lu, Dong and Wang, Yali and Wang, Limin and Qiao, Yu},
  booktitle={Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition},
  year={2024}
}
```

```bibtex
@inproceedings{chen2023seine,
  title={Seine: Short-to-long video diffusion model for generative transition and prediction},
  author={Chen, Xinyuan and Wang, Yaohui and Zhang, Lingjun and Zhuang, Shaobin and Ma, Xin and Yu, Jiashuo and Wang, Yali and Lin, Dahua and Qiao, Yu and Liu, Ziwei},
  booktitle={The Twelfth International Conference on Learning Representations},
  year={2023}
}
```

```bibtex
@article{wang2024internvideo2,
  title={Internvideo2: Scaling video foundation models for multimodal video understanding},
  author={Wang, Yi and Li, Kunchang and Li, Xinhao and Yu, Jiashuo and He, Yinan and Wang, Chenting and Chen, Guo and Pei, Baoqi and Zheng, Rongkun and Xu, Jilan and Wang, Zun and others},
  journal={arXiv preprint arXiv:2403.15377},
  year={2024}
}
```

---

## 许可证

请参考项目的 LICENSE 文件了解许可证信息。
