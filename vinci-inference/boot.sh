#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(dirname "$SCRIPT_DIR")

# 加载环境变量文件
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
elif [ -f "$ROOT_DIR/.env" ]; then
    source "$ROOT_DIR/.env"
else
    echo "WARN: .env file not found in $SCRIPT_DIR or $ROOT_DIR, use built-in defaults."
fi

# Conda 环境名称
CONDA_ENV=vinci
CONDA_BASE_DEFAULT="/opt/anaconda3"
PYTHON_BIN_DEFAULT="$CONDA_BASE_DEFAULT/envs/$CONDA_ENV/bin/python"

# 默认的 CUDA 设备
DEFAULT_CUDA_VISIBLE_DEVICES="0"
DEFAULT_DEVICE="auto"
DEFAULT_RUNNING_LANGUAGE='chn'
DEFAULT_VERSION="v1"

# Python 启动命令（优先使用 vinci 环境解释器）
PYTHON_BIN="$PYTHON_BIN_DEFAULT"
COMMAND=""
LOG_FILE="$SCRIPT_DIR/vinci_inference.log"
PID_FILE="/tmp/.vinci/vinci_inference.pid"

# 确保目录存在
mkdir -p "$(dirname "$PID_FILE")"

# 函数：启动服务
start_service() {
    export CUDA_VISIBLE_DEVICES="$1"
    export VINCI_DEVICE="$2"
    export RUNNING_LANGUAGE="$3"
    export VERSION="$4"

    export VINCI_HOST="${VINCI_HOST:-0.0.0.0}"
    export VINCI_PORT="${VINCI_PORT:-8010}"
    export VINCI_PRELOAD_MODELS="${VINCI_PRELOAD_MODELS:-true}"
    export VINCI_LOCAL_ONLY="${VINCI_LOCAL_ONLY:-true}"
    export VINCI_MODEL_PATH="${VINCI_MODEL_PATH:-$ROOT_DIR/Vinci-8B-base}"
    export VINCI_CKPT_PATH="${VINCI_CKPT_PATH:-$ROOT_DIR/Vinci-8B-ckpt}"

    local conda_base="$CONDA_BASE_DEFAULT"
    if command -v conda >/dev/null 2>&1; then
        conda_base="$(conda info --base 2>/dev/null || echo "$CONDA_BASE_DEFAULT")"
    fi

    if [ -f "$conda_base/etc/profile.d/conda.sh" ]; then
        echo "Activating conda environment: $CONDA_ENV"
        source "$conda_base/etc/profile.d/conda.sh"
        conda activate "$CONDA_ENV" >/dev/null 2>&1 || echo "WARN: conda activate failed, fallback to direct python path."
    else
        echo "WARN: conda.sh not found under $conda_base, fallback to direct python path."
    fi

    if [ -x "$conda_base/envs/$CONDA_ENV/bin/python" ]; then
        PYTHON_BIN="$conda_base/envs/$CONDA_ENV/bin/python"
    fi
    COMMAND="\"$PYTHON_BIN\" \"$SCRIPT_DIR/app/main.py\""

    echo "Starting service with VINCI_DEVICE=$VINCI_DEVICE, CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES, VINCI_PORT=$VINCI_PORT..."
    echo "Using python: $PYTHON_BIN"
    nohup bash -c "$COMMAND" >> "$LOG_FILE" 2>&1 &
    echo $! > $PID_FILE
    echo "Service started with PID $(cat $PID_FILE)"
}

# 函数：停止服务
stop_service() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        echo "Stopping service with PID $PID..."
        kill $PID >/dev/null 2>&1 || true
        rm -f $PID_FILE
        echo "Service stopped."
    else
        echo "Service is not running."
    fi
}

# 函数：重启服务
restart_service() {
    echo "Restarting service..."
    stop_service
    start_service "$1" "$2" "$3" "$4"
    echo "Service restarted."
}

# 主逻辑
CUDA_VISIBLE_DEVICES=$DEFAULT_CUDA_VISIBLE_DEVICES
DEVICE=$DEFAULT_DEVICE
RUNNING_LANGUAGE=$DEFAULT_RUNNING_LANGUAGE
VERSION=$DEFAULT_VERSION

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cuda) CUDA_VISIBLE_DEVICES="$2"; shift ;;
        --device) DEVICE="$2"; shift ;;
        --version) VERSION="$2"; shift ;;
        --language) RUNNING_LANGUAGE="$2"; shift ;;
        start) COMMAND_ACTION="start" ;;
        stop) COMMAND_ACTION="stop" ;;
        restart) COMMAND_ACTION="restart" ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

case "$COMMAND_ACTION" in
    start)
        start_service "$CUDA_VISIBLE_DEVICES" "$DEVICE" "$RUNNING_LANGUAGE" "$VERSION"
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service "$CUDA_VISIBLE_DEVICES" "$DEVICE" "$RUNNING_LANGUAGE" "$VERSION"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart} [--device auto|cuda|mps|cpu] [--cuda <CUDA_VISIBLE_DEVICES>] [--language chn|eng] [--version v0|v1]"
        exit 1
        ;;
esac

exit 0
