#!/bin/bash
if grep -qi "Debian" /etc/*release; then
  echo "you are using debian, running script..."
 if ! ls /var/lib/apt/lists | grep -qi InRelease; then
  if [ $(id -u root) -ne 0 ]; then
    apt update
  else
    sudo apt update
  fi
fi
if ! dpkg -l | grep -qw extrepo; then
  sudo apt install extrepo -y
  check_if_disabled=$(sudo extrepo list | grep -qi librewolf)
  if ! $check_if_disabled | grep -qi disabled; then
    sudo extrepo enable librewolf
  fi
else
  echo "Extrepo already installed."
fi
if ! ls /etc/apt/sources.list.d/ | grep -qi librewolf &>/dev/null; then
  echo "librewolf extrepo source was not added, updating..."
  sudo apt update
fi
echo "installing librewolf..."
sudo apt install -y librewolf
clear
echo "Librewolf is now installed on your system"
fi
exit 1
