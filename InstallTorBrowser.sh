#!/bin/bash 

if grep -qi "Fedora" /etc/*release; then
while true; do
echo "Pick how you want to install tor browser:
1. Tar Install
2. Dnf install
3. Flatpak install 
"
 read -p "Pick an option [1-3]: " torbrowser_installation_option
  if [[ "$torbrowser_installation_option" == "1." || "$torbrowser_installation_option" == "1" ]]; thein
    # If file is found then it will not install the package
    echo "Checking if tar and wget is installed..."
    if [ -f /usr/bin/wget ]; then
      echo "wget is installed, not installing wget."
    else
      echo "wget is not installed, installing wget..."
      sudo dnf install -y wget
      sleep 0.2
      clear
      echo "Finished installing wget."
    fi
    if [ -f /usr/bin/tar ]; then
      echo "Tar is installed, not installing tar."
    else
      echo "Tar is not installed, installing tar..."
      sudo dnf install -y tar
      sleep 0.2
      clear
      echo "Finished installing Tar, downloading and extracting the tor browser tar file"
    fi
        wget --show-progress -q -P ~/ https://dist.torproject.org/torbrowser/14.5.6/tor-browser-linux-x86_64-14.5.6.tar.xz
        echo "Extracting tar file..."
        tar -xf tor-browser-linux-x86_64-14.5.6.tar.xz -C ~/
        echo "Removing tarfile..."
        rm -rf ~/tor-browser-linux-x86_64-14.5.6.tar.xz
        echo "creating symbolic link..."
        sudo ln -s ~/tor-browser/Browser/start-tor-browser /usr/bin/tor-browser
        echo "Done, creating symbolic link, creating desktop file..."
        sudo $(curl -fsSL https://bit.ly/TorBrowserDesktopFile) >> /usr/share/applications/tor-browser.desktop
        echo "Done, installing tor browser"
  elif [[ "$torbrowser_installation_option" == "2." || "$torbrowser_installation_option" == "2" ]]; then
    echo "Installing Tor using dnf..."
    echo "adding tor repository using dnf..."
    sudo dnf config-manager --add-repo https://rpm.torproject.org/fedora/torproject.repo
    sleep 0.2
    clear
    echo "Done, adding tor repository."
    echo "Adding tor gpg key..."
    sudo dnf install -y tor-project-keyring
    sleep 0.2
    clear
    echo "Done adding tor gpg key"
    echo "now installing tor..."
    sudo dnf install -y torbrowser-launcher
    echo "Done, running tor browser..."
    torbrowser-launcher
  elif [[ "$torbrowser_installation_option" == "3." || "$torbrowser_installation_option" == "3" ]]; then
    check_if_in_container=$(systemd-detect-virt --container)
  if [ "$check_if_in_container" == "docker" ; then
    echo "Flatpak does not work in a containerizied environment, exiting..."
    exit 1
  else
  fi
  else
    echo "Invalid option, try again..."
    sleep 0.5
    clear
  fi
done

else 
   echo "This script supports fedora only, exiting..."
   exit 1
fi
