# ComfyUI serverless worker for the LifeOps muse pipeline (PONY base).
# Base = RunPod's official worker-comfyui: handler accepts {"input":{"workflow": <API graph>}}
# and returns base64 PNGs - exactly what genphoto emits. Models are baked in so the endpoint
# is region-free (any GPU tier selectable; a network volume would pin us to a GPU-starved
# datacenter). One image per BASE model - this is pony; illustrious/chroma/etc. are their own.
FROM runpod/worker-comfyui:5.8.6-base

# --- FaceDetailer (default-on in genphoto): Impact Pack + Subpack ---
RUN comfy-node-install comfyui-impact-pack comfyui-impact-subpack

# --- Pony base. Civitai needs auth: set CIVITAI_TOKEN as a build argument in the RunPod
#     endpoint's build config. (The image is private to your RunPod registry.) ---
ARG CIVITAI_TOKEN
RUN comfy model download \
      --url "https://civitai.com/api/download/models/2884631?token=${CIVITAI_TOKEN}" \
      --relative-path models/checkpoints --filename cyberrealistic_pony.safetensors

# --- Juggernaut skin refiner (public HF) ---
RUN comfy model download \
      --url "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
      --relative-path models/checkpoints --filename juggernaut.safetensors

# --- FaceDetailer bbox model (Impact Subpack reads models/ultralytics/bbox) ---
RUN comfy model download \
      --url "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
      --relative-path models/ultralytics/bbox --filename face_yolov8m.pt
