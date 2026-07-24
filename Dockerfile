# syntax=docker/dockerfile:1.7
# PONY base worker - MINIMAL. Stock worker-comfyui + our checkpoints only. NO custom nodes,
# NO extra pip: the FaceDetailer deps (ultralytics/opencv/etc.) drag a conflicting torch that
# breaks ComfyUI startup, so the worker reports "ready" but never processes jobs (Jul 24).
# This image processes base + refiner graphs cleanly. FaceDetailer is a separate image built
# with carefully-pinned deps once base is proven.
FROM runpod/worker-comfyui:5.8.6-base

ARG CIVITAI_TOKEN
RUN --mount=type=secret,id=civitai \
    CIVITAI_API_TOKEN="$(cat /run/secrets/civitai)" \
    comfy model download --url "https://civitai.com/api/download/models/2884631" \
      --relative-path models/checkpoints --filename cyberrealistic_pony.safetensors
RUN comfy model download \
      --url "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
      --relative-path models/checkpoints --filename juggernaut.safetensors
