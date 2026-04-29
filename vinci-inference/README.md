# Vinci Inference

代码放置在 `vinci` 根目录下，启停操作在 `vinci-inference/boot.sh`，日志文件为
`vinci-inference/vinci_inference.log`。

## 配置

修改.env文件，设置环境变量，包括OSS秘钥等配置。

若没有 `.env`，`boot.sh` 会使用默认值启动（默认端口 `8010`）。
推荐从 `.env.example` 复制生成：

```bash
cp vinci-inference/.env.example vinci-inference/.env
```

关键模型路径配置（建议本地/云端都显式设置）：

- `VINCI_MODEL_PATH`：`Vinci-8B-base` 目录路径
- `VINCI_CKPT_PATH`：`Vinci-8B-ckpt` 目录路径
- `VINCI_LOCAL_ONLY=true`：仅使用本地模型文件；若路径缺失会快速报错，避免前端长时间“正在连接”

推荐同时设置：

- `VINCI_PRELOAD_MODELS=true`：服务启动后后台预热模型
- `VINCI_PORT=8010`：与 EduMind 后端默认对接端口一致

## 依赖

不包括模型依赖。

```
pip install -r requirements/app.txt
pip install -r requirements/client.txt
```

`requirements/app.txt` 已包含运行所需关键包（如 `opencv-python-headless`、`minio`）。

## 操作

### 启动

通过`--device`参数指定运行设备，默认为`auto`（自动选择`cuda -> mps -> cpu`）。

```
./vinci-inference/boot.sh --device auto start
```

Linux + CUDA 可选：
```bash
./vinci-inference/boot.sh --device cuda --cuda 4,5 start
```

### 停止

```
./vinci-inference/boot.sh stop
```

### 重启

```
./vinci-inference/boot.sh --device auto restart
```

## 健康检查

```bash
curl http://127.0.0.1:8010/api/v1/health
```

- `status=ready`：模型已可用
- `status=loading`：模型正在预热
- `status=cold`：尚未触发加载

若返回 `status=cold` 且带 `error` 字段，请先修复模型路径（`VINCI_MODEL_PATH` /
`VINCI_CKPT_PATH`）。

## 2026-04-29 稳定性更新

- 启动脚本优先使用 conda `vinci` 环境解释器，避免误用系统 Python。
- 新增 `GET /api/v1/health` 与 `POST /api/v1/warmup`。
- 模型初始化改为懒加载 + 可观测状态，减少首包阻塞风险。
- 当模型不可用时，`/inference/internvl` 系列接口快速返回 `503`，避免前端长时间卡在连接中。
