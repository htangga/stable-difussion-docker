#!/usr/bin/env bash
set -e

# ====== CONFIG: model directories ======
BASE_DIR="./models"
SD_DIR="$BASE_DIR/Stable-diffusion"
LORA_DIR="$BASE_DIR/Lora"
VAE_DIR="$BASE_DIR/VAE"
VAE_APPROX_DIR="$BASE_DIR/VAE-approx"
CODEFORMER_DIR="$BASE_DIR/Codeformer"
GFPGAN_DIR="$BASE_DIR/GFPGAN"
DEEPBOORU_DIR="$BASE_DIR/deepbooru"
HYPERNET_DIR="$BASE_DIR/hypernetworks"
KARLO_DIR="$BASE_DIR/karlo"
EMB_DIR="$BASE_DIR/embeddings"

# ====== CONFIG: model URLs ======
MODELS=(
  # Format: "NAME|URL|DEST_DIR|FILENAME"
  # SDXL family
  "sdxl-base|https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors|$SD_DIR|sd_xl_base_1.0.safetensors"
  "sdxl-refiner|https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors|$SD_DIR|sd_xl_refiner_1.0.safetensors"
  "sdxl-vae|https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors|$VAE_DIR|sdxl_vae.safetensors"
  "vae-approx|https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-approx.vae.pt|$VAE_APPROX_DIR|vae-ft-mse-approx.vae.pt"

  # Stable Diffusion v1.5
  "sd15|https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors|$SD_DIR|v1-5-pruned-emaonly.safetensors"

  # Extra models
  "lineart|https://huggingface.co/lllyasviel/Annotators/resolve/main/networks/diffusion_pytorch_model.safetensors|$SD_DIR|anime-lineart.safetensors"
  "dreamshaper|https://huggingface.co/Lykon/dreamshaper-xl/resolve/main/dreamshaperXL10_alpha2Xl10.safetensors|$SD_DIR|dreamshaperXL.safetensors"
  "sticker-lora|https://huggingface.co/ItsJayQz/sticker-Lora/resolve/main/sticker_style.safetensors|$LORA_DIR|sticker-style.safetensors"

  # Face restoration
  "gfpgan|https://huggingface.co/TencentARC/GFPGAN/resolve/main/GFPGANv1.4.pth|$GFPGAN_DIR|GFPGANv1.4.pth"
  "codeformer|https://huggingface.co/sczhou/CodeFormer/resolve/main/codeformer.pth|$CODEFORMER_DIR|codeformer.pth"

  # Alternative models
  "karlo|https://huggingface.co/kakaobrain/karlo-v1-alpha/resolve/main/model.ckpt|$KARLO_DIR|karlo-v1-alpha.ckpt"

  # Embeddings & Hypernetworks
  "emb-easynegative|https://huggingface.co/datasets/gsdf/EasyNegative/resolve/main/EasyNegative.pt|$EMB_DIR|EasyNegative.pt"
  "hypernet-anime|https://huggingface.co/hakurei/waifu-diffusion-v1-4/resolve/main/animeStyle.pt|$HYPERNET_DIR|animeStyle.pt"

  # Tagger
  "deepbooru|https://huggingface.co/DeepDanbooru/DeepDanbooru/resolve/main/deepdanbooru.onnx|$DEEPBOORU_DIR|deepdanbooru.onnx"
)

# ====== FUNCTIONS ======
make_dirs() {
  echo "[INFO] Creating model directory structure at $BASE_DIR ..."
  mkdir -p "$SD_DIR" "$LORA_DIR" "$VAE_DIR" "$VAE_APPROX_DIR" \
           "$CODEFORMER_DIR" "$GFPGAN_DIR" "$DEEPBOORU_DIR" \
           "$HYPERNET_DIR" "$KARLO_DIR" "$EMB_DIR"
}

download_model() {
  local name=$1
  local url=$2
  local dest_dir=$3
  local filename=$4
  echo "[INFO] Downloading $name ..."
  wget -c "$url" -O "$dest_dir/$filename"
}

download_by_name() {
  local target=$1
  for m in "${MODELS[@]}"; do
    IFS="|" read -r name url dest file <<< "$m"
    if [[ "$name" == "$target" ]]; then
      download_model "$name" "$url" "$dest" "$file"
      return
    fi
  done
  echo "[ERROR] Unknown model: $target"
  exit 1
}

download_all() {
  for m in "${MODELS[@]}"; do
    IFS="|" read -r name url dest file <<< "$m"
    download_model "$name" "$url" "$dest" "$file"
  done
}

download_minimal() {
  download_by_name "sdxl-base"
  download_by_name "lineart"
  download_by_name "sticker-lora"
}

show_help() {
  cat <<EOF
Usage: $0 [OPTION]

Options:
  --sdxl-base        Download SDXL Base (~6.6GB)
  --sdxl-refiner     Download SDXL Refiner (~6.6GB)
  --sdxl-vae         Download SDXL VAE (~300MB)
  --vae-approx       Download Approximate VAE (~70MB)
  --sd15             Download Stable Diffusion v1.5 (~4GB)
  --lineart          Download LineArt / ColoringBook (~1.2GB)
  --dreamshaper      Download DreamShaper XL (~6GB)
  --sticker-lora     Download Sticker LoRA (~200MB)
  --gfpgan           Download GFPGAN Face Restorer (~350MB)
  --codeformer       Download CodeFormer Face Restorer (~350MB)
  --karlo            Download Karlo Text-to-Image (~15GB)
  --emb              Download EasyNegative Embedding (~25KB)
  --hypernet         Download Anime Style Hypernetwork (~80MB)
  --deepbooru        Download DeepDanbooru Tagger (~150MB)
  --minimal          Download minimal setup (SDXL Base + LineArt + Sticker LoRA)
  --all              Download all models (~40GB+)
  --help             Show this help message

Examples:
  $0 --sd15
  $0 --sdxl-base
  $0 --vae-approx
  $0 --gfpgan
  $0 --all
EOF
}

# ====== MAIN ======
make_dirs

case "$1" in
  --sdxl-base)      download_by_name "sdxl-base" ;;
  --sdxl-refiner)   download_by_name "sdxl-refiner" ;;
  --sdxl-vae)       download_by_name "sdxl-vae" ;;
  --vae-approx)     download_by_name "vae-approx" ;;
  --sd15)           download_by_name "sd15" ;;
  --lineart)        download_by_name "lineart" ;;
  --dreamshaper)    download_by_name "dreamshaper" ;;
  --sticker-lora)   download_by_name "sticker-lora" ;;
  --gfpgan)         download_by_name "gfpgan" ;;
  --codeformer)     download_by_name "codeformer" ;;
  --karlo)          download_by_name "karlo" ;;
  --emb)            download_by_name "emb-easynegative" ;;
  --hypernet)       download_by_name "hypernet-anime" ;;
  --deepbooru)      download_by_name "deepbooru" ;;
  --minimal)        download_minimal ;;
  --all)            download_all ;;
  --help|"")        show_help ;;
  *)                echo "[ERROR] Unknown option: $1"; show_help; exit 1 ;;
esac
