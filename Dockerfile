# syntax=docker/dockerfile:1.7
# ComfyUI serverless worker for the LifeOps muse pipeline (PONY base).
# Base = RunPod's official worker-comfyui: handler accepts {"input":{"workflow": <API graph>}}
# and returns base64 PNGs - exactly what genphoto emits. Models baked in => region-free
# (any GPU tier selectable). One image per BASE model; this is pony.
FROM runpod/worker-comfyui:5.8.6-base

RUN comfy-node-install comfyui-impact-pack comfyui-impact-subpack

# Pony base - Civitai token via BuildKit secret, so it never lands in an image layer.
RUN --mount=type=secret,id=civitai \
    CIVITAI_API_TOKEN="$(cat /run/secrets/civitai)" \
    comfy model download \
      --url "https://civitai.com/api/download/models/2884631" \
      --relative-path models/checkpoints --filename cyberrealistic_pony.safetensors

RUN comfy model download \
      --url "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
      --relative-path models/checkpoints --filename juggernaut.safetensors

RUN comfy model download \
      --url "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
      --relative-path models/ultralytics/bbox --filename face_yolov8m.pt
