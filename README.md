# DotFile-hyprland

Repositorio de configuraciones (dotfiles) e instalador automatizado para **Hyprland** y sus dependencias en sistemas basados en Arch Linux / EndeavourOS.

## Estructura del repositorio

- [`hypr/`](./hypr): Configuración de Hyprland (`hyprland.lua`).
- [`ski/`](./ski): Ajustes del explorador de archivos Ski (`settings.json`).
- [`kitty/`](./kitty): Configuración de la terminal Kitty.
- [`install.sh`](./install.sh): Script de instalación de paquetes oficiales (`pacman`), paquetes AUR (`yay`) y despliegue de dotfiles en `~/.config`.

## Instalación rápida

### Opción 1: Clonar e instalar
```bash
git clone https://github.com/GodJuegos/DotFile-hyprland.git ~/DotFile-hyprland
cd ~/DotFile-hyprland
chmod +x install.sh
./install.sh
```

### Opciones del instalador
- `./install.sh` — Instala todas las dependencias y copia las configuraciones a `~/.config` (creando respaldo previo si existen).
- `./install.sh --pkgs-only` — Solo instala los paquetes y dependencias de `pacman` y `AUR`.
- `./install.sh --configs-only` — Solo aplica los archivos de configuración en `~/.config`.
