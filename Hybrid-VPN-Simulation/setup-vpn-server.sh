#!/bin/bash

# AWS VPN Server Setup Script
echo "Setting up AWS VPN Server..."

# Update system
sudo yum update -y

# Install OpenVPN and Easy-RSA
sudo yum install -y openvpn easy-rsa

# Setup Easy-RSA
cd ~
mkdir easy-rsa
cp -r /usr/share/easy-rsa/* easy-rsa/
cd easy-rsa

# Initialize PKI
./easyrsa init-pki

# Build CA (automated)
echo "AWS-CA" | ./easyrsa build-ca nopass

# Generate server certificate
./easyrsa gen-req server nopass
echo "yes" | ./easyrsa sign server server

# Generate client certificate
./easyrsa gen-req client1 nopass
echo "yes" | ./easyrsa sign client client1

# Generate DH parameters
./easyrsa gen-dh

# Copy certificates to OpenVPN directory
sudo cp ~/easy-rsa/pki/ca.crt /etc/openvpn/
sudo cp ~/easy-rsa/pki/issued/server.crt /etc/openvpn/
sudo cp ~/easy-rsa/pki/private/server.key /etc/openvpn/
sudo cp ~/easy-rsa/pki/dh.pem /etc/openvpn/

# Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start OpenVPN services
sudo systemctl start openvpn@server
sudo systemctl start openvpn@server2
sudo systemctl enable openvpn@server
sudo systemctl enable openvpn@server2

echo "VPN Server setup complete!"
echo "Check status with: sudo systemctl status openvpn@server"