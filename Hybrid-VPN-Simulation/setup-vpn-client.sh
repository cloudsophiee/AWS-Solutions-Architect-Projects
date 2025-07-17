#!/bin/bash

# On-Premises VPN Client Setup Script
echo "Setting up On-Premises VPN Client..."

# Update system
sudo yum update -y

# Install OpenVPN
sudo yum install -y openvpn

# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Create client config directory
mkdir -p ~/vpn-config

echo "VPN Client setup complete!"
echo "Copy certificates and client1.ovpn to ~/vpn-config/"
echo "Start VPN with: sudo openvpn --config ~/vpn-config/client1.ovpn"