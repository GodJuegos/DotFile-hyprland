#!/usr/bin/env bash
# ==============================================================================
# DotFile-hyprland (Versión 1.0.0) - Instalador de Dependencias y Quickshell
# Autor: godjuegos (villagamer203@gmail.com)
# Repositorio: https://github.com/GodJuegos/DotFile-hyprland.git
# ==============================================================================
# Propósito:
#   1. Instala todas las dependencias de Hyprland, Quickshell (Liquid Glass),
#      Qt6 Shaders, PipeWire/ALSA, NetworkManager y fuentes Nerd Fonts.
#   2. Despliega las carpetas de configuración en ~/.config (hypr, quickshell,
#      wireplumber, kitty, ski) creando un respaldo previo si ya existen.
#   3. Configura el enrutamiento de audio ALSA/WirePlumber para evitar que
#      los audífonos silencien los altavoces automáticamente.
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
# 1. Listas de paquetes (Pacman / Oficiales + Quickshell Liquid Glass)
# ------------------------------------------------------------------------------
PACMAN_PKGS=(
    # Core Hyprland & Wayland
    hyprland
    hyprpolkitagent
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gnome
    wl-clipboard

    # Quickshell & Qt6 (Barra Modular Liquid Glass + Shaders GLSL)
    quickshell
    qt6-base
    qt6-declarative
    qt6-wayland
    qt6-svg
    qt6-shadertools
    qt6-5compat
    qt6-multimedia
    qt6-websockets
    qt6ct

    # Red, Speedtest y Bluetooth (NetworkPopup Orbital)
    networkmanager
    iproute2
    curl
    bluez
    bluez-utils

    # Audio, PipeWire y ALSA (Modo Dual Altavoces + Audífonos)
    pipewire
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    alsa-utils
    pamixer
    pavucontrol
    playerctl
    brightnessctl
    ddcutil

    # Interfaz, Lanzadores, Temas y Fuentes Nerd Font
    ttf-iosevka-nerd
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    cantarell-fonts
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

    # Capturas de pantalla, Grabación y OCR
    grim
    slurp
    satty
    wf-recorder
    gpu-screen-recorder
    tesseract
    tesseract-data-eng
    scrcpy

    # Utilidades de Sistema
    git
    base-devel
    jq
    socat
    inotify-tools
    wmctrl
    duf
    glances
    tldr
)

# Paquetes de AUR (opcionales / complementarios)
AUR_PKGS=(
    libastal-io-git
    libastal-git
    libastal-4-git
)

# Directorios de configuración administrados por este repositorio
CONFIG_FOLDERS=(
    "hypr"
    "quickshell"
    "wireplumber"
    "kitty"
    "ski"
)

# ------------------------------------------------------------------------------
# 2. Funciones de instalación y configuración
# ------------------------------------------------------------------------------
check_arch() {
    if ! command -v pacman >/dev/null 2>&1; then
        error "Este instalador está diseñado para sistemas basados en Arch Linux / EndeavourOS (pacman)."
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
    else
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
    fi
}

configure_services() {
    info "Configurando servicios de red y audio (WirePlumber / ALSA)..."

    # Habilitar NetworkManager si no está activo
    if systemctl list-unit-files | grep -q "^NetworkManager.service"; then
        sudo systemctl enable --now NetworkManager.service >/dev/null 2>&1 || true
        success "Servicio NetworkManager activo."
    fi

    # Desactivar Auto-Mute en tarjeta ALSA Generic_1 si existe (permite Altavoces + Audífonos simultáneos)
    if command -v amixer >/dev/null 2>&1 && amixer -c Generic_1 info >/dev/null 2>&1; then
        amixer -c Generic_1 sset 'Auto-Mute Mode' Disabled >/dev/null 2>&1 || true
        amixer -c Generic_1 sset 'Front' 100% unmute >/dev/null 2>&1 || true
        amixer -c Generic_1 sset 'Headphone' 100% unmute >/dev/null 2>&1 || true
        success "ALSA Generic_1 configurado: Auto-Mute desactivado (Altavoces + Audífonos activos)."
    fi

    # Reiniciar WirePlumber de usuario para cargar la regla 51-disable-headphone-autoswitch.conf
    if systemctl --user is-active wireplumber >/dev/null 2>&1; then
        systemctl --user restart wireplumber || true
        success "WirePlumber reiniciado con la regla anti-secuestro de audífonos."
    fi
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
            configure_services
            ;;
        all|*)
            install_packages
            deploy_configs
            configure_services
            ;;
    esac

    success "¡Proceso completado! Puedes iniciar la barra con: quickshell -d -p ~/.config/quickshell/shell.qml"
}

main "$@"
