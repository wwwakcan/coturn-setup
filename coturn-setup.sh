#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Functions
info() {
    echo -e "${GREEN}[+]${NC} $1"
}

error() {
    echo -e "${RED}[!]${NC} $1"
}

# COTURN Installation Function
install_coturn() {
    clear
    info "Starting COTURN Installation..."
    
    echo
    echo "This will modify any existing COTURN installation."
    echo -e "${BLUE}[?]${NC} Do you want to continue? (Y/n)"
    read -p "> " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]] && [ ! -z "$confirm" ]; then
        error "Installation cancelled."
        return 1
    fi

    info "Updating system..."
    apt-get update -y
    
    info "Installing COTURN..."
    apt-get install coturn -y
    
    info "Stopping COTURN service..."
    systemctl stop coturn
    
    info "Enabling COTURN service..."
    echo "TURNSERVER_ENABLED=1" > /etc/default/coturn
    
    info "COTURN installed successfully!"
    echo
    info "You can now configure COTURN using the configuration menu."
    echo
    read -p "Press ENTER to return to main menu..."
}

# Configuration Function
configure_coturn() {
    clear
    echo "===== COTURN Configuration ====="
    echo

    # IP Information
    info "Enter server IP address:"
    read -p "> " PUBLIC_IP
    while [[ ! "$PUBLIC_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
        error "Please enter a valid IP address!"
        read -p "> " PUBLIC_IP
    done

    # Username
    info "Enter TURN username:"
    read -p "> " USERNAME
    while [ -z "$USERNAME" ]; do
        error "Username cannot be empty!"
        read -p "> " USERNAME
    done

    # Password
    info "Enter TURN password (minimum 8 characters):"
    read -s -p "> " PASSWORD
    echo
    info "Confirm password:"
    read -s -p "> " PASSWORD2
    echo
    while [ -z "$PASSWORD" ] || [ ${#PASSWORD} -lt 8 ] || [ "$PASSWORD" != "$PASSWORD2" ]; do
        error "Passwords don't match or are less than 8 characters!"
        info "Enter TURN password (minimum 8 characters):"
        read -s -p "> " PASSWORD
        echo
        info "Confirm password:"
        read -s -p "> " PASSWORD2
        echo
    done

    # TURN configuration
    info "Configuring TURN server..."
    cat > /etc/turnserver.conf << EOL
# Listening ports
listening-port=3478
tls-listening-port=5349
listening-ip=0.0.0.0

# TURN relay IP (server's public IP address)
relay-ip=$PUBLIC_IP
external-ip=$PUBLIC_IP

# User authentication
fingerprint
lt-cred-mech
user=$USERNAME:$PASSWORD
realm=$PUBLIC_IP

# Logging and performance settings
total-quota=100
bps-capacity=0
log-file=/var/log/turnserver.log
simple-log

# TLS/DTLS disabled
no-tls
no-dtls
EOL

    # Firewall rules
    info "Adding firewall rules..."
    ufw allow 3478/tcp
    ufw allow 3478/udp
    ufw allow 5349/tcp
    ufw allow 5349/udp
    ufw allow 49152:65535/udp

    # Start TURN service
    systemctl enable coturn
    systemctl start coturn

    # Show access information
    clear
    echo "===== COTURN Configuration Complete ====="
    echo
    info "Access Information:"
    echo "----------------------------------------"
    echo "STUN Server       : stun:${PUBLIC_IP}:3478"
    echo "TURN Server       : turn:${PUBLIC_IP}:3478"
    echo
    echo "Username         : $USERNAME"
    echo "Password         : $PASSWORD"
    echo "Realm           : $PUBLIC_IP"
    echo
    echo "Supported Protocols:"
    echo "- STUN/TURN UDP    : Port 3478"
    echo "- STUN/TURN TCP    : Port 3478"
    echo "----------------------------------------"
}

# Main menu
while true; do
    clear
    echo "===== COTURN Installation and Configuration ====="
    echo "Please select an operation:"
    echo
    echo "1) Install COTURN"
    echo "2) Configure COTURN"
    echo "3) Exit"
    echo
    echo -e "${BLUE}[?]${NC} Enter your choice (1-3):"
    read -p "> " choice

    case "$choice" in
        "1")
            install_coturn
            ;;
        "2")
            configure_coturn
            echo
            read -p "Press ENTER to return to main menu..."
            ;;
        "3")
            echo "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid selection! Please enter a number between 1-3."
            sleep 2
            ;;
    esac
done
