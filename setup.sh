#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install ufw curl wget

echo "Configuring /etc/sysctl.d/99-tailscale.conf for subrouting"
echo -e "net.ipv4.ip_forward = 1\nnet.ipv6.conf.all.forwarding = 1" | sudo tee /etc/sysctl.d/99-tailscale.conf

echo "Enabling UFW and SSH access"
sudo ufw allow ssh && sudo ufw enable

echo "Downloading and installing Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh

echo "Configuring Tailscale up script"
echo "sudo tailscale up --advertise-routes=192.168.1.0/24 #replace with proper subnet" > up.sh
chmod +x up.sh

echo "Setting hostname"
echo "df-abnb-vprod" | sudo tee /etc/hostname

echo "Modifying /etc/systemd/logind.conf"
sudo cp /etc/systemd/logind.conf /etc/systemd/logind.conf.bak
sudo sed -i 's/^#HandleLidSwitch=.*$/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sudo sed -i 's/^#HandleLidSwitchExternalPower=.*$/HandleLidSwitchExternalPower=ignore/g' /etc/systemd/logind.conf
sudo sed -i 's/^#HandleLidSwitchDocked=.*$/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
sudo sed -i 's/^#LidSwitchIgnoreInhibited=.*$/HandleLidSwitch=no/g' /etc/systemd/logind.conf


echo "Modifying /etc/default/grub"
sudo cp /etc/default/grub /etc/default/grub.bak
sudo sed -i 's/^GRUB_DEFAULT=.*$/GRUB_DEFAULT=0/g' /etc/default/grub
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*$/GRUB_TIMEOUT_STYLE=hidden/g' /etc/default/grub
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"consoleblank=300\"/g' /etc/default/grub

echo "Updating grub"
sudo update-grub

echo "Finished setup - consider rebooting."
