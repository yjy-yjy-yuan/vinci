# Vinci Inference

代码放置在`egodemo`根目录下，启停操作均在根目录下，日志在`inference.log`。

## 配置

修改.env文件，设置环境变量，包括OSS秘钥等配置。

## 依赖

不包括模型依赖。

```
pip install -r requirements/app.txt
pip install -r requirements/client.txt
```

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
