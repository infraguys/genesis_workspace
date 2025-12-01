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
UI_BUILD_ENV_WEB_ARCHIVE="${UI_BUILD_ENV_WEB_ARCHIVE:-https://repository.genesis-core.tech/genesis_workspace/latest/workspace-web.tar.gz}"

cd "$WORK_DIR"

[[ "$EUID" == 0 ]] || exec sudo -s "$0" "$@"

apt update
apt install -y nginx

# Install web archive    
wget -q "$UI_BUILD_ENV_WEB_ARCHIVE" -O /tmp/web.tar.gz
tar -xzf /tmp/web.tar.gz -C "$WEB_DIR"
chown -R www-data:www-data "$WEB_DIR"

# Configure Nginx for single page application
cp genesis/images/nginx.conf /etc/nginx/sites-available/default
