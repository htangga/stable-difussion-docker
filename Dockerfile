FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    WEBUI_DIR=/opt/stable-diffusion-webui \
    TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9+PTX" \
    FORCE_CUDA=1

# Install system deps + debugging tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget ca-certificates \
    python3 python3-pip \
    libgl1 libglib2.0-0 \
    net-tools iproute2 curl \
    && rm -rf /var/lib/apt/lists/*

# Fix: symlink python -> python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash sd && mkdir -p ${WEBUI_DIR} && chown -R sd:sd ${WEBUI_DIR}
USER sd
WORKDIR ${WEBUI_DIR}

# Clone AUTOMATIC1111 repo
RUN git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui .

# Upgrade pip (global)
RUN python3 -m pip install --upgrade pip wheel setuptools

# 🔹 Pre-install Torch + torchvision (CUDA 12.1) + xformers
RUN pip install torch==2.1.2+cu121 torchvision==0.16.2+cu121 --extra-index-url https://download.pytorch.org/whl/cu121 \
    && pip install xformers==0.0.23

# Install all Python dependencies required by WebUI
RUN pip install -r requirements_versions.txt || true \
    && pip install -r requirements.txt || true

# Expose WebUI port
EXPOSE 7860

# Default CLI args (can be overridden in docker-compose)
ENV CLI_ARGS="--api --listen --xformers --skip-torch-cuda-test --disable-console-progressbars --no-half-vae"

# Entrypoint
ENTRYPOINT ["bash", "-lc", "python launch.py $CLI_ARGS"]
