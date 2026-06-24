#!/usr/bin/env bash
# Corre los tests Pester de config/git-commits.ps1 en un contenedor. Requiere Docker.
#
# Usa la imagen del .NET SDK porque trae pwsh + git nativos para arm64. La imagen
# suelta (mcr.microsoft.com/powershell) es solo amd64 y segfaultea bajo emulación
# QEMU en Apple Silicon.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="mcr.microsoft.com/dotnet/sdk:8.0"

exec docker run --rm -v "$REPO_DIR:/repo" -w /repo "$IMAGE" bash -c '
  git config --global --add safe.directory "*"
  pwsh -NoProfile -File tests/run-pester.ps1
'
