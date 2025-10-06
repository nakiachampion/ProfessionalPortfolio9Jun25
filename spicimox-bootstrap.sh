#!/bin/bash
# Spicimox Bootstrap Script v7.0-final (bridge-only, untagged LAN)
set -e

readonly SCRIPT_VERSION="7.0-final"
readonly LOG_FILE="/var/log/spicimox-bootstrap.log"
readonly LOCK_DIR="/var/lock/spicimox"
readonly HOSTNAME="Spicimox"
readonly HOST_IP="19.0.4.2"
readonly DNS_SERVER="19.0.4.1"
readonly FALLBACK_DNS1="8.8.8.8"
readonly FALLBACK_DNS2="1.1.1.1"
readonly NETWORK_BRIDGE="vmbr0"
readonly NETWORK_GATEWAY="19.0.4.1"
readonly NETWORK_SUBNET="19.0.4"
readonly STORAGE_DEVICE="/dev/sda"
readonly CONTAINERS_PASSWORD="Spicimox2025!"

declare -A CONTAINERS=(
    [100]="Spicituu,19.0.4.3,2,2048,20,Ubuntu Base Container"
    [101]="Spiciker,19.0.4.4,4,4096,32,Docker Container Platform"
    [102]="Spicitainer,19.0.4.5,2,2048,16,Portainer Management"
    [103]="Spicizuh,19.0.4.6,4,8192,64,Wazuh Security Platform"
    [104]="SpiciHA,19.0.4.7,2,4096,32,Home Assistant"
    [105]="Spicifana,19.0.4.8,2,4096,32,Grafana Monitoring"
)

log_info() { echo "[INFO] $(date --iso-8601=seconds): $*" | tee -a "$LOG_FILE"; }
log_error() { echo "[ERROR] $(date --iso-8601=seconds): $*" | tee -a "$LOG_FILE" >&2; }
log_warn() { echo "[WARN] $(date --iso-8601=seconds): $*" | tee -a "$LOG_FILE" >&2; }

mkdir -p "$(dirname "$LOG_FILE")"
log_info "=== Spicimox Bootstrap v$SCRIPT_VERSION ==="

configure_host_networking() {
    log_info "Configuring Proxmox host networking..."
    hostnamectl set-hostname "$HOSTNAME" 2>/dev/null || { echo "$HOSTNAME" > /etc/hostname; hostname "$HOSTNAME"; }
    cat > /etc/resolv.conf << EOF
nameserver $DNS_SERVER
nameserver $FALLBACK_DNS1
nameserver $FALLBACK_DNS2
search localdomain
EOF
    if ! ip link show "$NETWORK_BRIDGE" >/dev/null 2>&1; then
        log_error "Network bridge $NETWORK_BRIDGE does not exist"
        log_error "Configure bridge in Proxmox GUI: Network -> Create Linux Bridge"
        return 1
    fi
    ip link set "$NETWORK_BRIDGE" up || { log_error "Cannot bring up bridge $NETWORK_BRIDGE"; return 1; }
    if ping -c 2 "$NETWORK_GATEWAY" >/dev/null 2>&1; then
        log_info "Host can reach gateway: $NETWORK_GATEWAY"
    else
        log_warn "Host cannot reach gateway - check network configuration"
    fi
    log_info "Host networking configured"
}

update_repositories() {
    log_info "Updating package repositories..."
    export DEBIAN_FRONTEND=noninteractive
    if grep -q "trixie" /etc/os-release 2>/dev/null; then
        log_info "Detected Debian Trixie - updating repositories"
        cat > /etc/apt/sources.list << 'EOF'
deb https://deb.debian.org/debian trixie main contrib non-free-firmware
deb https://deb.debian.org/debian trixie-updates main contrib non-free-firmware
deb https://security.debian.org/debian-security trixie-security main contrib non-free-firmware
EOF
    fi
    local attempts=0
    local max_attempts=3
    while [[ $attempts -lt $max_attempts ]]; do
        if apt-get update -q; then
            log_info "Package lists updated successfully"
            break
        else
            ((attempts++))
            log_warn "Package update attempt $attempts failed, retrying..."
            if [[ $attempts -eq $max_attempts ]]; then
                log_error "Failed to update package lists after $max_attempts attempts"
                return 1
            fi
            sleep 5
        fi
    done
    apt-get install -y bridge-utils curl wget vim net-tools iputils-ping dnsutils || {
        log_error "Failed to install essential packages"
        return 1
    }
    log_info "Repositories and packages updated"
}

download_template() {
    log_info "Verifying Ubuntu LXC template..."
    local template="ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    if ! pveam list local | grep -q "ubuntu-22.04-standard"; then
        log_info "Downloading Ubuntu 22.04 LXC template..."
        if pveam download local "$template"; then
            log_info "Template downloaded successfully"
        else
            log_error "Failed to download template"
            return 1
        fi
    else
        log_info "Template already available"
    fi
}

create_container() {
    local ctid=$1
    local container_spec="${CONTAINERS[$ctid]}"
    if [[ -z "$container_spec" ]]; then
        log_error "No specification found for container $ctid"
        return 1
    fi
    IFS=',' read -ra meta <<< "$container_spec"
    local name="${meta[0]}"
    local ip="${meta[1]}"
    local cores="${meta[2]}"
    local memory="${meta[3]}"
    local disk="${meta[4]}"
    local description="${meta[5]}"
    log_info "Creating container $ctid ($name) with IP $ip"
    if pct status "$ctid" >/dev/null 2>&1; then
        log_info "Container $ctid already exists, skipping creation"
        return 0
    fi
    if pct create "$ctid" "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" \
        --hostname "$name" \
        --cores "$cores" \
        --memory "$memory" \
        --rootfs "local-lvm:${disk}G" \
        --net0 "name=eth0,bridge=$NETWORK_BRIDGE,gw=$NETWORK_GATEWAY,ip=${ip}/24,type=veth,firewall=1" \
        --password "$CONTAINERS_PASSWORD" \
        --features "keyctl=1,nesting=1" \
        --onboot 1 \
        --unprivileged 1 \
        --description "$description"; then
        log_info "Container $ctid created successfully"
    else
        log_error "Failed to create container $ctid"
        return 1
    fi
    if pct start "$ctid"; then
        log_info "Container $ctid started"
    else
        log_error "Failed to start container $ctid"
        return 1
    fi
    local wait_count=0
    while [[ $wait_count -lt 30 ]] && ! pct exec "$ctid" -- test -f /bin/bash 2>/dev/null; do
        sleep 2
        ((wait_count++))
    done
    if [[ $wait_count -eq 30 ]]; then
        log_error "Container $ctid did not become ready in time"
        return 1
    fi
    configure_container_network "$ctid" "$ip" "$name"
    log_info "Container $ctid completed successfully"
}

configure_container_network() {
    local ctid=$1
    local ip=$2
    local name=$3
    log_info "Configuring network for container $ctid ($name)..."
    local network_script='#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
mkdir -p /etc/network
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address '"$ip"'/24
    gateway '"$NETWORK_GATEWAY"'
    dns-nameservers '"$DNS_SERVER"' '"$FALLBACK_DNS1"' '"$FALLBACK_DNS2"'
EOF
cat > /etc/resolv.conf << EOF
nameserver '"$DNS_SERVER"'
nameserver '"$FALLBACK_DNS1"'
nameserver '"$FALLBACK_DNS2"'
search localdomain
EOF
systemctl disable systemd-networkd --now 2>/dev/null || true
systemctl mask systemd-networkd 2>/dev/null || true
if grep -q "jammy" /etc/os-release 2>/dev/null; then
    cat > /etc/apt/sources.list << "UBUNTU_EOF"
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
UBUNTU_EOF
fi
for attempt in 1 2 3; do
    if apt-get update -q; then
        break
    fi
    sleep 5
done
apt-get install -y ifupdown net-tools iputils-ping dnsutils curl wget
systemctl enable networking 2>/dev/null || true
systemctl restart networking 2>/dev/null || (ifdown eth0 2>/dev/null || true; ifup eth0 2>/dev/null || true)
sleep 5
'
    if echo "$network_script" | pct exec "$ctid" -- bash; then
        log_info "Network configuration completed for container $ctid"
        sleep 3
        if pct exec "$ctid" -- ping -c 2 -W 5 "$NETWORK_GATEWAY" >/dev/null 2>&1; then
            log_info "✓ Container $ctid has network connectivity"
            return 0
        else
            log_warn "✗ Container $ctid network test failed"
            return 1
        fi
    else
        log_error "Network configuration failed for container $ctid"
        return 1
    fi
}

create_all_containers() {
    log_info "Creating all containers..."
    if ! download_template; then return 1; fi
    local success_count=0
    local total_count=${#CONTAINERS[@]}
    for ctid in 100 101 102 103 104 105; do
        if [[ -n "${CONTAINERS[$ctid]:-}" ]]; then
            if create_container "$ctid"; then
                ((success_count++))
            fi
            sleep 3
        fi
    done
    log_info "Container creation completed: $success_count/$total_count successful"
    return 0
}

show_summary() {
    log_info "=== Spicimox Infrastructure Summary ==="
    echo "Host: $HOSTNAME ($HOST_IP/24)"
    echo "Network: $NETWORK_SUBNET.0/24"
    echo "Gateway: $NETWORK_GATEWAY"
    echo "Bridge: $NETWORK_BRIDGE"
    echo ""
    echo "Container Status:"
    printf "%-4s %-12s %-15s %-10s %s\n" "ID" "Name" "IP" "Status" "Description"
    echo "================================================================"
    for ctid in 100 101 102 103 104 105; do
        if [[ -n "${CONTAINERS[$ctid]:-}" ]]; then
            IFS=',' read -ra meta <<< "${CONTAINERS[$ctid]}"
            local name="${meta[0]}"
            local ip="${meta[1]}"
            local description="${meta[5]}"
            local status
            status=$(pct status "$ctid" 2>/dev/null || echo "not found")
            printf "%-4s %-12s %-15s %-10s %s\n" "$ctid" "$name" "$ip" "${status#status: }" "$description"
        fi
    done
    echo ""
    echo "Next Steps:"
    echo "1. Test connectivity: for i in {100..105}; do pct exec \\$i -- ping -c1 $NETWORK_GATEWAY; done"
    echo "2. Install services using the quick start guide"
    echo "3. Access containers: pct enter <container_id>"
    echo ""
    echo "Log file: $LOG_FILE"
}

main() {
    log_info "Starting Spicimox Bootstrap..."
    if [[ -d "$LOCK_DIR" ]]; then
        log_error "Another instance is already running"
        exit 1
    fi
    mkdir -p "$LOCK_DIR"
    cleanup() { rm -rf "$LOCK_DIR" 2>/dev/null || true; }
    trap cleanup EXIT
    local steps=(
        "configure_host_networking"
        "update_repositories"
        "create_all_containers"
        "show_summary"
    )
    for step in "${steps[@]}"; do
        log_info "Executing: $step"
        if ! "$step"; then
            log_error "Step $step failed"
            exit 1
        fi
    done
    log_info "Spicimox Bootstrap completed successfully!"
}

main "$@"
