#!/usr/bin/env bash
set -Eeuo pipefail
# Recreate the "development" sandbox container from scratch.

if podman container exists development; then
  echo "Container 'development' already exists. Aborting, nothing was changed."
  exit 1
fi

echo ">>> Creating container"
podman --log-level error create \
  --name development \
  --env WAYLAND_DISPLAY="/run/user/1000/wayland-0" \
  --env PATH="/var/home/truls/.local/bin:/usr/local/bin:/usr/bin" \
  --security-opt label=disable \
  --userns keep-id \
  --user root:root \
  --shm-size=1g \
  --volume "/run/user/1000/wayland-0:/run/user/1000/wayland-0" \
  registry.fedoraproject.org/fedora-toolbox:44 \
  sleep infinity

echo ">>> Starting container"
podman start development

echo ">>> Setting up the 'truls' user"
podman exec --user root development mkdir -p /var/home/truls
podman exec --user root development usermod --shell /bin/bash --home /var/home/truls truls
podman exec --user root development chown truls:truls /var/home/truls
podman exec --user root development bash -c \
  "echo 'truls ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/truls && chmod 0440 /etc/sudoers.d/truls"

echo ">>> Adding the VS Code repository"
podman exec --user truls development bash -c \
  'sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
   printf "%s\n" \
     "[code]" \
     "name=Visual Studio Code" \
     "baseurl=https://packages.microsoft.com/yumrepos/vscode" \
     "enabled=1" \
     "autorefresh=1" \
     "type=rpm-md" \
     "gpgcheck=1" \
     "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" |
   sudo tee /etc/yum.repos.d/vscode.repo > /dev/null'

echo ">>> Installing packages (this takes a few minutes)"
podman exec --user truls development sudo dnf update -y
podman exec --user truls development sudo dnf install firefox gh code -y

echo ">>> Installing Claude Code and uv"
podman exec --user truls development bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
podman exec --user truls development bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'

echo ">>> Done. Enter with:  podman exec --user truls -it development bash"
