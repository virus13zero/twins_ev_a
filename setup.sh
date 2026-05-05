#!/bin/bash
echo "Installing Dependencies for Twins_Evil_AT..."
sudo apt update
sudo apt install -y aircrack-ng dnsmasq tshark iptables xterm wireless-tools
chmod +x Twins_Evil_AT.sh
echo "Setup Complete! Run: sudo ./Twins_Evil_AT.sh"
