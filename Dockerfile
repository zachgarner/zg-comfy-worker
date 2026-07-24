# syntax=docker/dockerfile:1.7
# ComfyUI serverless worker for the LifeOps muse pipeline (PONY base).
# Base = RunPod's official worker-comfyui: handler accepts {"input":{"workflow": <API graph>}}
# and returns base64 PNGs - exactly what genphoto emits. Models baked in => region-free
# (any GPU tier selectable). One image per BASE model; this is pony.
FROM runpod/worker-comfyui:5.8.6-base

RUN comfy-node-install comfyui-impact-pack comfyui-impact-subpack
# comfy-node-install registers the nodes but does NOT pull their Python deps, so
# FaceDetailer fails to import at runtime ("Node 'FaceDetailer' not found") - the exact
# same failure the pod hit Jul 23. Install the deps explicitly into ComfyUI's env.
# Pin numpy<2: unconstrained pip pulls numpy 2.x, which segfaults the torch/opencv the
# base image is built against as soon as FaceDetailer's ultralytics/cv2 touch an array
# -> the worker crashes (goes "unhealthy") instead of erroring. numpy<2 keeps ABI compat.
RUN python -m pip install --no-cache-dir "numpy<2" \
      dill piexif ultralytics segment-anything scikit-image opencv-python-headless

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
