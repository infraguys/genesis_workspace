#!/usr/bin/env bash

# Copyright 2025 Genesis Corporation
#
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -eu
set -x
set -o pipefail

INSTALL_PATH="/opt/"
WORK_DIR="/opt/genesis_workspace"
WEB_DIR="/var/www/html"
FLUTTER_SDK_PATH="/opt/flutter"
BUILD_TARGET="${UI_BUILD_ENV_BUILD_TARGET:-ci_stage}"

apt update
apt install -y nginx jq

cd "$WORK_DIR"

# Detect the Flutter SDK version
FLUTTER_SDK_VERSION=$(cat .fvmrc | jq -r .flutter | awk NF)

[[ "$EUID" == 0 ]] || exec sudo -s "$0" "$@"

# Install FVM
export FVM_ALLOW_ROOT=true
curl -fsSL https://fvm.app/install.sh | bash

cd "/tmp"
wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_SDK_VERSION-stable.tar.xz"
tar -xf "flutter_linux_$FLUTTER_SDK_VERSION-stable.tar.xz" -C "$INSTALL_PATH"

ln -sv "$FLUTTER_SDK_PATH/bin/flutter" "/usr/local/bin/flutter"

cd "$WORK_DIR"

# Prepare the environment
python3 genesis/images/make_ui_build_env.py

# Build the application
make "$BUILD_TARGET"

rm -fv "$WEB_DIR/index.nginx-debian.html"
find "build/web/" -maxdepth 1 -type f -exec mv -t "$WEB_DIR/" {} +
cp -r "build/web/assets" "$WEB_DIR/"

# Configure Nginx for single page application
cp genesis/images/nginx.conf /etc/nginx/sites-available/default
