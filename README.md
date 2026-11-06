<!-- ~/.config/README.md (Versión 1.0.0) -->
<!-- Propósito: Documentación principal de DotFile-hyprland v1.0.0, su estructura modular en Quickshell e instrucciones de instalación. -->

# DotFile-hyprland (Versión 1.0.0)

Repositorio de configuraciones (dotfiles), **Shell Modular Liquid Glass en Quickshell (v1.0.0)** e instalador automatizado para **Hyprland** en sistemas basados en Arch Linux / EndeavourOS.

---

## 📂 Estructura del Repositorio que se Sube a Git

```text
~/.config/
├── .gitignore             # Whitelist: ignora datos privados y solo sube dotfiles del sistema
├── README.md              # Documentación general e instrucciones de uso
├── packages.txt           # Lista categorizada de todas las dependencias (Pacman + Qt6 + Audio + Red)
├── install.sh             # Instalador automatizado de paquetes, dotfiles y audio ALSA/WirePlumber
├── hypr/                  # Configuración principal de Hyprland (hyprland.lua)
├── kitty/                 # Configuración de la terminal Kitty
├── ski/                   # Ajustes de la aplicación Ski (settings.json)
├── wireplumber/
│   └── wireplumber.conf.d/
│       └── 51-disable-headphone-autoswitch.conf  # Evita que los audífonos silencien los altavoces
└── quickshell/            # Shell de escritorio Wayland con diseño iOS Liquid Glass
    ├── shell.qml          # Punto de entrada principal de Quickshell
    ├── qmldir             # Registro de Singletons y componentes QML
    ├── settings.json      # Configuración reactiva (posición de barra, módulos, ruta de audio)
    ├── assets/
    │   └── shaders/       # Shaders GLSL precompilados (liquid_glass y node_beams_clipped)
    ├── components/
    │   └── LiquidCapsule.qml  # Cápsula flotante con efecto iOS Liquid Glass y brillo especular
    ├── services/
    │   ├── ConfigService.qml    # Lectura/escritura en caliente de settings.json
    │   ├── ThemeService.qml     # Paleta de colores Liquid Glass y tipografía Iosevka Nerd Font
    │   ├── DateTimeService.qml  # Servicio de hora con segundos y fecha en español
    │   ├── AudioService.qml     # Control PipeWire + enrutador ALSA (Dual Altavoz + Audífonos)
    │   └── NetService.qml       # Velocidad de red en vivo (↓/↑), IP/MAC, Speedtest y estado orbital
    └── bar/
        ├── Bar.qml              # Contenedor de barra adaptable (top, bottom, left, right) + IPC
        ├── modules/             # Islas modulares de la barra
        │   ├── WorkspacesModule.qml
        │   ├── FocusModule.qml
        │   ├── TimeDateModule.qml
        │   ├── NetworkModule.qml
        │   ├── AudioModule.qml
        │   ├── TrayModule.qml
        │   └── BatteryModule.qml
        └── popups/
            └── NetworkPopup.qml # Cápsula Orbital de Configuración de Red con radar y shaders
```

---

## 🚀 Instalación Rápida

```bash
git clone https://github.com/GodJuegos/DotFile-hyprland.git ~/DotFile-hyprland
cd ~/DotFile-hyprland
chmod +x install.sh
./install.sh
```

### Opciones del instalador (`install.sh`)
- `./install.sh` — Instala todas las dependencias (`pacman` + `AUR`), copia las configuraciones a `~/.config` (creando respaldo previo) y configura `NetworkManager` + `WirePlumber/ALSA`.
- `./install.sh --pkgs-only` — Solo instala los paquetes y dependencias.
- `./install.sh --configs-only` — Solo despliega los archivos de configuración y aplica las reglas de audio/red.

---

## 🎛️ Comandos IPC de la Barra (`quickshell`)

- **Iniciar la barra:** `quickshell -d -p ~/.config/quickshell/shell.qml`
- **Abrir/Cerrar Cápsula Orbital de Internet:** `quickshell ipc call bar toggleNetwork`
- **Cambiar posición de la barra (`top`, `bottom`, `left`, `right`):** `quickshell ipc call bar setPosition top`
- **Rotar posición automáticamente:** `quickshell ipc call bar cyclePosition`
- **Activar/Desactivar módulo de batería (Laptop/PC):** `quickshell ipc call bar toggleBattery`
