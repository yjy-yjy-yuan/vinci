#!/bin/bash

# 最小化下载脚本 - 仅下载核心对话模型（不包含视频生成功能）
# 节省存储空间，适用于不需要"生成未来视频"功能的用户

# Function to install Git LFS
install_git_lfs() {
    echo "Installing Git LFS..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install git-lfs -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git-lfs
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        choco install git-lfs
    else
        echo "Unsupported OS. Please install Git LFS manually."
        exit 1
    fi
    git lfs install
}

# Check if Git LFS is installed
if ! command -v git-lfs &> /dev/null; then
    echo "Git LFS is not installed."
    install_git_lfs
else
    echo "Git LFS is already installed."
fi

echo "======================================"
echo "下载 Vinci 核心模型（最小化版本）"
echo "======================================"
echo ""
echo "此脚本仅下载核心对话/问答模型，不包含视频生成功能。"
echo "如果需要'生成未来视频'功能，请使用 download.sh 下载完整版本。"
echo ""

# 下载基础模型
REPO_URL1="https://huggingface.co/hyf015/Vinci-8B-base"
echo "正在下载: $REPO_URL1"
git clone "$REPO_URL1"

# 下载检查点模型
REPO_URL2="https://huggingface.co/hyf015/Vinci-8B-ckpt"
echo "正在下载: $REPO_URL2"
git clone "$REPO_URL2"

echo ""
echo "======================================"
echo "下载完成！"
echo "======================================"
echo ""
echo "已下载："
echo "  - Vinci-8B-base (基础模型)"
echo "  - Vinci-8B-ckpt (检查点模型)"
echo ""
echo "未下载（视频生成功能需要）："
echo "  - seine_weights (约 5GB+)"
echo ""
echo "如果后续需要视频生成功能，运行："
echo "  git clone https://huggingface.co/hyf015/seine_weights"
echo ""
