#!/usr/bin/env bash
# ==============================================================================
# DotFile-hyprland - Instalador Base de Hyprland y Dependencias (Arch / EOS)
# Autor: godjuegos (villagamer203@gmail.com)
# Repositorio: https://github.com/GodJuegos/DotFile-hyprland.git
# ==============================================================================

set -euo pipefail

# Colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

REPO_URL="https://github.com/GodJuegos/DotFile-hyprland.git"
CONFIG_DIR="${HOME}/.config"
BACKUP_DIR="${HOME}/.config-backup-$(date +%Y%m%d-%H%M%S)"

# ------------------------------------------------------------------------------
# 1. Listas de paquetes (Pacman / Oficiales)
# ------------------------------------------------------------------------------
PACMAN_PKGS=(
    # Core Hyprland & Wayland
    hyprland
    hyprpolkitagent
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gnome
    wl-clipboard
    qt6ct
    qt6-multimedia
    qt6-websockets

    # Interfaz, Shell, Lanzadores y Temas
    quickshell
    wofi
    matugen
    dart-sass
    cava
    fastfetch
    cliphist
    adw-gtk-theme

    # Terminal y Gestor de Archivos
    kitty
    nemo

    # Audio, Multimedia y Brillo
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    pamixer
    pavucontrol
    playerctl
    brightnessctl
    ddcutil

    # Capturas de pantalla, Grabación y OCR
    grim
    slurp
    satty
    wf-recorder
    gpu-screen-recorder
    tesseract
    tesseract-data-eng
    scrcpy

    # Utilidades de Sistema y Fuentes
    git
    base-devel
    jq
    socat
    inotify-tools
    wmctrl
    duf
    glances
    tldr
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    cantarell-fonts
)

# Paquetes de AUR
AUR_PKGS=(
    libastal-io-git
    libastal-git
    libastal-4-git
)

# Directorios de configuración administrados por este repo
CONFIG_FOLDERS=(
    "hypr"
    "kitty"
    "ski"
)

# ------------------------------------------------------------------------------
# 2. Funciones de instalación
# ------------------------------------------------------------------------------
check_arch() {
    if ! command -v pacman >/dev/null 2>&1; then
        error "Este instalador está diseñado para sistemas basados en Arch Linux (pacman)."
    fi
}

install_yay() {
    if ! command -v yay >/dev/null 2>&1; then
        info "Instalando yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm git base-devel
        local tmp_dir
        tmp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
        (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
        rm -rf "$tmp_dir"
        success "yay instalado correctamente."
    else
        success "yay ya se encuentra instalado."
    fi
}

install_packages() {
    info "Actualizando base de datos e instalando dependencias principales con pacman..."
    sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"
    success "Paquetes oficiales instalados."

    if [ ${#AUR_PKGS[@]} -gt 0 ]; then
        install_yay
        info "Instalando paquetes de AUR..."
        yay -S --needed --noconfirm "${AUR_PKGS[@]}"
        success "Paquetes de AUR instalados."
    fi
}

deploy_configs() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ "$script_dir" = "$CONFIG_DIR" ]; then
        info "El repositorio ya se encuentra directamente en ${CONFIG_DIR}. No es necesario copiar archivos."
        return 0
    fi

    info "Copiando configuraciones hacia ${CONFIG_DIR}..."
    mkdir -p "$CONFIG_DIR"

    for folder in "${CONFIG_FOLDERS[@]}"; do
        if [ -d "${script_dir}/${folder}" ]; then
            if [ -d "${CONFIG_DIR}/${folder}" ]; then
                mkdir -p "$BACKUP_DIR"
                warn "Respaldando ${CONFIG_DIR}/${folder} en ${BACKUP_DIR}/${folder}"
                mv "${CONFIG_DIR}/${folder}" "${BACKUP_DIR}/${folder}"
            fi
            cp -r "${script_dir}/${folder}" "${CONFIG_DIR}/${folder}"
            success "Configuración aplicada: ${folder}"
        fi
    done
}

# ------------------------------------------------------------------------------
# 3. Flujo principal
# ------------------------------------------------------------------------------
main() {
    echo -e "${BLUE}=====================================================${NC}"
    echo -e "${BLUE}   Instalador de DotFile-hyprland (@GodJuegos)       ${NC}"
    echo -e "${BLUE}=====================================================${NC}"

    check_arch

    case "${1:-all}" in
        --pkgs-only)
            install_packages
            ;;
        --configs-only)
            deploy_configs
            ;;
        all|*)
            install_packages
            deploy_configs
            ;;
    esac

    success "¡Proceso completado! Puedes reiniciar tu sesión de Hyprland."
}

main "$@"
