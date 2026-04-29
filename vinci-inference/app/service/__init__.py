from .internvl import inference as internvl_inference
from .internvl import stream_inference as internvl_stream_inference
from .internvl import model_status
from .internvl import preload_models

# Seine 模型是可选的（用于视频生成功能）
# 如果没有下载 seine_weights，此功能将不可用
try:
    from .seine import inference as seine_inference
    SEINE_AVAILABLE = True
except Exception as e:
    print(f"警告: Seine 模型不可用（需要 seine_weights）: {e}")
    print("视频生成功能将被禁用。如需启用，请下载: git clone https://huggingface.co/hyf015/seine_weights")

    def seine_inference(*args, **kwargs):
        raise RuntimeError("Seine 模型未安装。请运行: git clone https://huggingface.co/hyf015/seine_weights")

    SEINE_AVAILABLE = False
