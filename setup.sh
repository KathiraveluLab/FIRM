#!/bin/bash
set -e

echo "==> Installing Pixi package manager..."
curl -fsSL https://pixi.sh/install.sh | sh

# Reload PATH to make pixi available in the current session
export PATH="$HOME/.pixi/bin:$PATH"

echo "==> Initializing Pixi project..."
if [ ! -f pixi.toml ]; then
    pixi init .
else
    echo "    pixi.toml already exists, skipping init."
fi

echo "==> Adding Modular channel..."
pixi project channel add https://conda.modular.com/max/

echo "==> Adding conda-forge channel..."
pixi project channel add conda-forge

echo "==> Installing Mojo..."
pixi add mojo

echo ""
echo "Setup complete! Run 'pixi shell' to enter the Mojo environment."
