#!/usr/bin/env bash
# ProxmoxVE Community Script Style
# Server 1C LXC installer
# Author: Evgeny Karamnov
# License: MIT

set -e

# --- Defaults ---
APP="torrserver"
CTID=${CTID:-9002}
HN=${HN:-server1c}
DISK_SIZE=${DISK_SIZE:-8}
MEM=${MEM:-8192}
CORE=${CORE:-4}
BRIDGE=${BRIDGE:-vmbr0}
NET=${NET:-dhcp}
STORAGETEMP=${STORAGETEMP:-local}
STORAGE=${STORAGE:-local-lvm}
IMG="local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"

echo -e "\n>>> Creating LXC for $APP (CTID=$CTID)\n"
# --- Template check ---
if ! pveam list $STORAGE | grep -q "debian-12"; then
    # Если шаблон не найден, выполняем следующие действия:
    
    echo ">>> Downloading Debian 12 template..."
    
    # Обновляем список доступных шаблонов
    pveam update
    
    # Загружаем шаблон Debian 12
    pveam download $STORAGETEMP debian-12-standard_12.12-1_amd64.tar.zst
fi

# --- Create container ---
pct create $CTID $IMG \
    -hostname $HN \
    -storage $STORAGETEMP \
    -rootfs ${STORAGE}:${DISK_SIZE} \
    -memory $MEM \
    -cores $CORE \
    -net0 name=eth0,bridge=$BRIDGE,ip=$NET \
    -onboot 1 \
    -unprivileged 1

# --- Start container ---
pct start $CTID
sleep 5

# --- Install TorrServer ---
echo ">>> Installing server1c inside CT..."
