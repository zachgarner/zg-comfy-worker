# zg-comfy-worker

RunPod Serverless ComfyUI worker for the LifeOps muse image pipeline (pony base +
juggernaut skin refiner + FaceDetailer), models baked in so the endpoint is region-free
and any GPU tier is selectable.

**Build arg:** `CIVITAI_TOKEN` (for the cyberrealistic_pony checkpoint). Never committed.

**API:** POST `{"input":{"workflow": <ComfyUI API-format graph>}}` to `/run`, poll `/status/{id}`,
images returned base64. `genphoto --endpoint <id>` targets this.

One endpoint per base model; this is the pony proof. Others follow the same pattern.
