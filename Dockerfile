# syntax=docker/dockerfile:1.7
# PONY worker WITH FaceDetailer. Layer order = stable-first for registry caching: the big
# model downloads sit BELOW the deps, so iterating deps rebuilds only the small top layers.
FROM runpod/worker-comfyui:5.8.6-base

# --- models (stable, cached) ---
ARG CIVITAI_TOKEN
RUN --mount=type=secret,id=civitai \
    CIVITAI_API_TOKEN="$(cat /run/secrets/civitai)" \
    comfy model download --url "https://civitai.com/api/download/models/2884631" \
      --relative-path models/checkpoints --filename cyberrealistic_pony.safetensors
RUN comfy model download \
      --url "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
      --relative-path models/checkpoints --filename juggernaut.safetensors
RUN comfy model download \
      --url "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
      --relative-path models/ultralytics/bbox --filename face_yolov8m.pt

# --- FaceDetailer node + deps (iterate here; models above stay cached) ---
RUN comfy-node-install comfyui-impact-pack comfyui-impact-subpack
# numpy<2 kept for torch/opencv ABI; skip segment-anything (we don't use the SAM path).
RUN python -m pip install --no-cache-dir "numpy<2" dill piexif ultralytics scikit-image opencv-python-headless
