#!/bin/bash


# Pi Home install script
#
# script to
# 1 configure pi settings
# 2 set static network config
# 3 update pi
# 4 install pi hole
# 5 install my preffered block lists
# 6 setup wireguard wg0
# 7 setup wg-cli
# 8 Add facebook asn firewall block to wg0
# 9 setup wireguard wg1 (no firewalling)
# 10 harden pi
# 11 setup auto updating

# Get variables

# Get new pi password

# Get new ip address (CIDR)
# get current ip address
currentIP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}...')
# Prompt to enter new ip

read -p "Static IP in CIDR format (current IP $currentIP): " newIP

# if newIP not entered, make same as currentIP

# Get new gateway
# get current gateway
currentGateway=$(ip route | grep default | grep -oP '(?<=via\s)\d+(\.\d+){3}')

read -p "Gateway IP (current gateway $currentGateway): " newGateway

# if newGateway not entered, make same as currentGateway

# Get DNS Server
# get current DNS
currentDNS=$(cat /etc/resolv.conf | grep -oP '(?<=nameserver\s)\d+(\.\d+){3}')

read -P "DNS Server (current DNS $currentDNS): " newDNS

# if newDNS not entered, make same as currentDNS

# Get new Password

read -sp "New pi user password: " newPassword

# First we update the Pi
apt update && apt -y upgrade


# configure Pi
# Don't change the following lines unless you know what you are doing
# They execute the config options starting with 'do_' below
grep -E -v -e '^\s*#' -e '^\s*$' <<END | \
sed -e 's/$//' -e 's/^\s*/\/usr\/bin\/raspi-config nonint /' | bash -x -
#
############# INSTRUCTIONS ###########
#
# Change following options starting with 'do_' to suit your configuration
#
# Anything after a has '#' is ignored and used for comments
#
# If on Windows, edit using Notepad++ or another editor that can save the file
# using UNIX-style line endings
#
# macOS and GNU/Linux use UNIX-style line endings - use whatever editor you like
#
# Then drop the file into the boot partition of your SD card
#
# After booting the Raspberry Pi, login as user 'pi' and run following command:
#
# sudo /boot/raspi-config.txt
#
############# EDIT raspi-config SETTINGS BELOW ###########

# Hardware Configuration
do_boot_wait 0            # Turn off waiting for network before booting
do_boot_splash 1          # Disable the splash screen
do_overscan 1             # Disable overscan
do_camera 1               # Disable the camera
do_ssh 0                  # Disable remote ssh login
do_spi 1                  # Disable spi bus
do_memory_split 16        # Set the GPU memory limit to 64MB
do_i2c 1                  # Disable the i2c bus
do_serial 1               # Disable the RS232 serial bus
do_boot_behaviour B1      # Boot to CLI & require login
#                 B2      # Boot to CLI & auto login as pi user
#                 B3      # Boot to Graphical & require login
#                 B4      # Boot to Graphical & auto login as pi user
do_onewire 1              # Disable onewire on GPIO4
do_audio 0                # Auto select audio output device
#        1                # Force audio output through 3.5mm analogue jack
#        2                # Force audio output through HDMI digital interface
#do_gldriver G1           # Enable Full KMS Opengl Driver - must install deb package first
#            G2           # Enable Fake KMS Opengl Driver - must install deb package first
#            G3           # Disable opengl driver (default)
#do_rgpio 1               # Disable gpio server - must install deb package first

# System Configuration
do_configure_keyboard uk                     # Specify US Keyboard
do_hostname pihole                         # Set hostname to 'rpi-test'
#do_wifi_country GB                           # Set wifi country as Australia
#do_wifi_ssid_passphrase wifi_name password   # Set wlan0 network to join 'wifi_name' network using 'password'
do_change_timezone Europe/London        # Change timezone to Brisbane Australia
do_change_locale en_GB.UTF-8                 # Set language to Australian English

#Don't add any raspi-config configuration options after 'END' line below & don't remove 'END' line
END



# function to setup networking

cat <<EOT >> /etc/dhcpcd.conf

interface eth0
static ip_address=$newIP
static routers=$newGateway
static domain_name_servers=$newDNS
EOT




# function to install pihole

curl -sSL https://install.pi-hole.net | bash


# function to setup blocklists

wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash


# function to setup wg0

apt install wireguard

mkdir vpn
cd vpn

wget https://raw.githubusercontent.com/c4software/WireGuard-cli/master/wg-cli

# function to setup facebook firewall block


# function to setup wg1


# function to harden pi


# function to setup auto updates

