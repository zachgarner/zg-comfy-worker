# ComfyUI serverless worker for the LifeOps muse pipeline.
# Base = RunPod's official worker-comfyui (handler accepts an API-format workflow at
# {"input":{"workflow": <graph>}} and returns base64 PNGs). We extend it with the exact
# nodes + models genphoto's graph needs, BAKED IN so the endpoint is region-free and any
# GPU tier can be selected (a network volume would pin us to a GPU-starved datacenter).
FROM runpod/worker-comfyui:5.8.6-base

# --- FaceDetailer (default-on in genphoto): Impact Pack + Subpack ---
RUN comfy-node-install comfyui-impact-pack comfyui-impact-subpack

# --- Base checkpoint (Pony) + skin refiner (Juggernaut) ---
# Civitai needs auth; pass --build-arg CIVITAI_TOKEN=... (token stays out of the repo).
ARG CIVITAI_TOKEN
RUN comfy model download \
      --url "https://civitai.com/api/download/models/2884631?token=${CIVITAI_TOKEN}" \
      --relative-path models/checkpoints --filename cyberrealistic_pony.safetensors
RUN comfy model download \
      --url "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
      --relative-path models/checkpoints --filename juggernaut.safetensors

# --- FaceDetailer bbox model (Impact Subpack looks in models/ultralytics/bbox) ---
RUN comfy model download \
      --url "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
      --relative-path models/ultralytics/bbox --filename face_yolov8m.pt
