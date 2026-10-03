# dev-container-script

`setup-development.sh` creates a Podman container named `development` (Fedora
Toolbox 44) with VS Code, Firefox, `gh`, Claude Code and `uv` installed. GUI apps
inside it draw directly on the host's Wayland session.

## Usage

```bash
./setup-development.sh
```

The script refuses to run if a container named `development` already exists. To
rebuild from scratch, remove it first with `podman rm -f development`.

The container can be opened from the Fedora terminal, or by running the following command in a terminal:

```bash
podman exec --user truls -it development bash
```

## Desktop entry for VS Code

VS Code is installed inside the container, so the host has no launcher for it.
These steps add one to your app menu.

### 1. Copy the icon to the host

The icon ships with the `code` package inside the container. Copy it out:

```bash
podman cp development:/usr/share/pixmaps/vscode.png ~/.local/share/icons/vscode.png
```

### 2. Create the desktop file

Run the following command to create the desktop entry:

```bash
cat > ~/.local/share/applications/code-development.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=VS Code
Exec=podman exec --user truls development code --ozone-platform=wayland
Icon=/var/home/truls/.local/share/icons/vscode.png
EOF
```
