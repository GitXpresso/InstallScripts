#!/bin/bash
if ! grep -qi "Debian" /etc/*release; then 
  echo "not using Debiab or a Debian-based distro, aborting ( Fedora and other distros not added )"
  exit 1
fi
if [ ! -f $HOME/.local/bin/ngrok ]; then
  curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com bookworm main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && sudo apt install ngrok -y
  clear
while true; do
read -p "Ngrok is now installed, enter your ngrok authtoken key: " $Ngrok_authtoken
if ! grep "2x_" $Ngrok_authtoken; then
  echo "Invalid token, try again..."
  read -p "Ngrok is now installed, enter your ngrok authtoken key: " $Ngrok_authtoken
else
  ngrok config add-authtoken $Ngrok_authtoken
fi
done
else
  echo "Ngrok already installed"
fi
