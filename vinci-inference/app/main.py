import uvicorn
import threading
import os

from fastapi import FastAPI, HTTPException
from fastapi import APIRouter
from sse_starlette.sse import EventSourceResponse

import data
import service

from exception import exception_handlers


router = APIRouter()


def _env_bool(name: str, default: bool = False) -> bool:
    value = os.environ.get(name)
    if value is None:
        return default
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def _status_payload():
    status = service.model_status()
    return {
        "status": "ready" if status.get("ready") else ("loading" if status.get("loading") else "cold"),
        "model_ready": bool(status.get("ready")),
        "model_loading": bool(status.get("loading")),
        "error": status.get("error"),
        "started_at": status.get("started_at"),
        "finished_at": status.get("finished_at"),
    }


def _raise_if_model_unavailable():
    status = service.model_status()
    err = status.get("error")
    if err:
        raise HTTPException(status_code=503, detail=str(err))


@router.get("/health")
async def health():
    payload = _status_payload()
    payload["service"] = "vinci-inference"
    return payload


@router.post("/warmup")
async def warmup():
    service.preload_models()
    return {"status": "warming_up"}

@router.post("/inference/internvl", response_model=data.IntervlInferenceResponse)
async def internval_inference(req: data.InternvlInferenceRequest):
    _raise_if_model_unavailable()
    return service.internvl_inference(req.question, req.history, req.base64_frames, req.frames,
                                      req.session_id, req.timestamp, req.silent)

chat_lock = threading.Lock()
@router.post("/inference/internvl/stream", response_model=data.IntervlInferenceResponse)
async def internval_inference(req: data.InternvlInferenceRequest):
    acquired = False
    try:
        _raise_if_model_unavailable()
        chat_lock.acquire()
        acquired = True
        stream_generator = service.internvl_stream_inference(req.question, req.history, req.base64_frames, req.frames, 
                                                             req.session_id, req.timestamp, req.silent, model_index=0)
        return EventSourceResponse(stream_generator)
    finally:
        if acquired:
            chat_lock.release()

   
screen_shot_chat_lock = threading.Lock()
@router.post("/inference/internvl/screenshot", response_model=data.IntervlInferenceResponse)
async def internval_inference(req: data.InternvlInferenceRequest):
    acquired = False
    try:
        _raise_if_model_unavailable()
        chat_lock.acquire()
        acquired = True
        return service.internvl_inference(req.question, req.history, req.base64_frames, req.frames, 
                                          req.session_id, req.timestamp, req.silent, model_index=-1)
    finally:
        if acquired:
            chat_lock.release()

@router.post("/inference/seine", response_model=data.SeineInferenceResponse)
async def seine_inference(req: data.SeineInferenceRequest):
    try:
        return service.seine_inference(req.prompt, req.base64_image, req.image)
    except RuntimeError as e:
        if "Seine 模型未安装" in str(e):
            raise HTTPException(status_code=503, detail="视频生成功能未启用，请下载 Seine 模型: git clone https://huggingface.co/hyf015/seine_weights")
        raise

def build_app():
    fast_kwargs = {
        "include_in_schema": True,
        "docs_url": '/swagger-ui'}
    app = FastAPI(exception_handlers=exception_handlers, **fast_kwargs)
    app.include_router(router, prefix="/api/v1", tags=["Model"])

    return app

def start_fast_server(*args, **kwarg):
    preload = _env_bool("VINCI_PRELOAD_MODELS", default=False)
    if preload:
        service.preload_models()

    host = os.environ.get("VINCI_HOST", "0.0.0.0")
    port = int(os.environ.get("VINCI_PORT", "18081"))
    uvicorn.run(build_app(), host=host, port=port)

if __name__ == "__main__":
    start_fast_server()
