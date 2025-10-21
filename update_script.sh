#!/bin/bash
sleep 1
cp -R update/* .
chmod +x /home/starig/development/tokenspot/flutter/genesis_workspace/build/linux/x64/debug/bundle/genesis_workspace
./genesis_workspace &
sleep 1
rm update_script.sh
rm -rf update
exit
