# Stable Diffusion WebUI (AUTOMATIC1111) - Dockerized

This repository provides a Dockerized setup for running AUTOMATIC1111's Stable Diffusion WebUI with GPU support.  
The setup mounts local directories for models and outputs, making it easy to manage models and generated images.

---

## 📂 Project Structure

```
sd-docker/
│── Dockerfile
│── docker-compose.yml
│── setup-models.sh   # helper script to download models
│── models/           # put your models here
│    ├── Stable-diffusion/
│    ├── Lora/
│    ├── VAE/
│    └── embeddings/
│── outputs/          # generated images will be saved here
```

---

## ⚡ Requirements

- Docker and Docker Compose
- NVIDIA GPU with [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- Internet connection (for downloading models)

---

## 🚀 Usage

### 1. Create Docker Network
```bash
docker network create ai_net
```

### 2. Download Models
You **must have at least one checkpoint model** before starting the container (e.g., SDXL Base).

Use the provided helper script:

```bash
chmod +x setup-models.sh

# Show help
./setup-models.sh --help

# Download all models (~20GB total, very heavy)
./setup-models.sh --all

# Minimal setup (~8GB total: SDXL Base + LineArt + Sticker LoRA)
./setup-models.sh --minimal

# Example: only SDXL Base
./setup-models.sh --sdxl-base
```

Models will be stored in `./models/`.

---

### 3. Build the Docker Image
```bash
docker compose build --pull
```

### 4. Start the Container
```bash
docker compose up -d
```

### 5. Verify Container Status
```bash
docker ps
```

---

## 🌐 Access

- WebUI: [http://localhost:7860](http://localhost:7860)  
- API: `http://localhost:7860/sdapi/v1/txt2img`

---

## 🔧 Example API Call

Generate a black-and-white line art (coloring book style):

```bash
curl -s http://localhost:7860/sdapi/v1/txt2img   -H "Content-Type: application/json"   -d '{
    "prompt": "cute cartoon cat, black and white line art, coloring book style, clean outlines",
    "negative_prompt": "color, shading, gradient, background",
    "steps": 20,
    "width": 512,
    "height": 512
  }' | jq -r '.images[0]' | base64 -d > outputs/test.png
```

The generated image will also appear in the `./outputs/` folder.

---

## 📌 Notes

- **Mandatory model**: At least one checkpoint (e.g., `sd_xl_base_1.0.safetensors`) must exist inside `./models/Stable-diffusion/`.  
- For **stickers** → use `DreamShaper XL` + `Sticker LoRA`.  
- For **coloring books** → use `LineArt Model` with SDXL Base.  
- Use the `--minimal` setup option if you want a lightweight setup (~8GB).  
- The `./outputs/` folder is mounted so you can access generated images directly on the host machine.

---

## 🛠️ Troubleshooting

- **Error: `couldn't find NVIDIA drivers`**  
  → Install NVIDIA Container Toolkit and update your GPU driver.  
  [Toolkit Install Guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

- **Error: Out of Memory (OOM)**  
  → Reduce `width/height` or lower `steps`. SDXL requires significant VRAM.  

- **Error: no model found**  
  → Make sure at least one `.safetensors` file is inside `./models/Stable-diffusion/`.

- **Slow generation**  
  → The `--xformers` flag (already enabled) improves memory usage and speed.

---

## 📜 License

This project uses AUTOMATIC1111's [stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui).  
Models belong to their respective authors (StabilityAI, HuggingFace contributors, etc.).