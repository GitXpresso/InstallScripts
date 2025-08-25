#!/bin/bash
# functions:
nixOS_flatpak_install() {
# Check if the option is already set
if grep -q "services\.flatpak\.enable" "$CONFIG_FILE"; then
  # Replace existing line
  sed -i 's/services\.flatpak\.enable.*/services.flatpak.enable = true;/' "$CONFIG_FILE"
  echo "Updated existing Flatpak setting in configuration.nix."
else
  # Insert the option (you can adjust where it goes)
  echo "$FLATPAK_OPTION" >> "$CONFIG_FILE"
  echo "Added Flatpak setting to configuration.nix."
fi

# Rebuild the system
echo "Rebuilding NixOS configuration..."
$non_root nixos-rebuild switch

echo "Flatpak has been enabled."
}
alpine_sudo_setup() {
    USER_NAME=$(whoami)
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USER_NAME

# Set proper permissions on the sudoers file
sudo chmod 440 /etc/sudoers.d/$USER_NAME

echo "User '$USER_NAME' configured for passwordless sudo."
}
opensuse_sudo_setup() {
  grep -q '^%wheel ALL=(ALL) ALL' /etc/sudoers
  if [ $? -eq 0 ]; then
    echo "Line exists in /etc/sudoers"
    return 0
  else
    echo "Line does not exist, appending now..."
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
  fi
}

gentoo_sudo_setup() {
  read -p "what is your non-root username? (ex: gitxpresso ) " question2

  gpasswd -a "$question2" wheel
  if [ $? -ne 0 ]; then
    echo "invalid username, try again..."
    exit_code="1"

    read -p "what is your non-root username? (ex: gitxpresso ) " question2_retry
    gpasswd -a "$question2_retry" wheel
  else
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  fi

  if [ $? -ne 0 ]; then
    exit_code2="2"
    if [ "$exit_code2" = "2" ]; then 
      while true; do
        read -p "Would you like to list all available users? (yes/no/y/n): " y_or_n2  
        if [[ "$y_or_n2" == "yes" || "$y_or_n2" == "y" ]]; then
          echo "listing all available users..."
          cut -d: -f1 /etc/passwd  
          break
        elif [[ "$y_or_n2" == "no" || "$y_or_n2" == "n" ]]; then
          echo "not listing all available users."
          break
        else 
          echo "invalid input, try again"
          sleep_and_clear
        fi
      done
    else
      echo ""
    fi
  fi
}

command_1="sudo"

if [ ! -f /usr/bin/sudo ]; then      
  if [ "$(id -u)" -ne 0 ]; then
    echo "run this script as root by doing \"su\" in the Terminal"
  else
    while true; do
      read -p "This script requires sudo and sudo is not installed, do you want sudo to be installed? (yes/no/y/n): " y_or_n

      if [[ "$y_or_n" == "yes" || "$y_or_n" == "y" ]]; then
        echo "installing \"sudo\" based on your distro..."

        if grep -qi "opensuse" /etc/*release; then
          zypper install "$command_1"
          opensuse_sudo_setup
          break

        elif grep -qi "arch linux" /etc/*release; then
          check_if_already_root
          pacman -Sy --noconfirm "$command_1"
          break

        elif grep -qi "gentoo" /etc/*release; then
          emerge --quiet app-admin/sudo
          gentoo_sudo_setup
          break

        elif grep -qi "debian" /etc/*release; then
          apt install -y "$command_1"
          break
        elif grep -qi "alpine" /etc/*release; then
          apk add --no-progress --quiet "$command_1"
          alpine_sudo_setup
          break

        elif grep -qi "solus" /etc/*release; then 
          eopkg install -y "$command_1"
          break

        elif grep -qi "mageia" /etc/*release; then
          urpmi --auto "$command_1"
          break

        elif grep -qi "void linux" /etc/*release; then
          xbps-install -Sy "$command_1"
          break

        elif grep -qi "slackware" /etc/*release; then
          slackpkg install -batch "$command_1"
          break

        elif grep -qi "clear linux" /etc/*release; then
          swupd bundle-add "$command_1"
          break

        elif grep -qi "sabayon" /etc/*release; then
          equo install --yes "$command_1"
          break

        elif grep -qi "PCLinuxOS" /etc/*release; then
          apt-get install -y "$command_1"
          break

        elif grep -qi "Crux" /etc/*release; then 
          prt-get install -y "$command_1"
          break

        elif grep -qi "nixos" /etc/*release; then
          nix-env -iA nixpkgs."$command_1"
          break

        else
          echo "distro not found."
          exit 1
        fi

      elif [[ "$y_or_n" == "no" || "$y_or_n" == "n" ]]; then
        echo "not installing sudo, exiting..."
        exit 1

      else
        echo "Invalid input, please answer yes or no."
      fi

    done
  fi
fi

echo "\"sudo\" is not installed, installing sudo..."

if [ ! $(id -u) -eq 0 ]; then
  echo "Run this script as root, like this: \"sudo $0\""
  exit 1
fi

debian_librewolf_install() {
  sudo extrepo enable librewolf
  sudo apt update
  echo "updating to add librewolf repository from extrepo..."
  sudo apt update
  sleep_and_clear
  echo "installing librewolf"
  sudo apt install librewolf -y
  sleep_and_clear
}

sleep_and_clear() {
  sleep 0.5
  clear
}

librewolf_opensuse_install() {
  echo "installing librewolf using zypper..."
  echo "importing gpg key..."
  echo "gpg key should look like this: \"662E3CDD6FE329002D0CA5BB40339DD82B12EF16\""
  sudo rpm --import https://rpm.librewolf.net/pubkey.gpg
  sudo zypper ar -ef https://rpm.librewolf.net librewolf
  sudo zypper ref
  sudo zypper in librewolf
}

librewolf_compile_from_source() {
  echo "checking if git is installed..."
  if [ -f /usr/bin/git ]; then
    echo "git is installd, not installing..."
  else
    if grep -qi "alpine" /etc/*release; then
      sudo apk add --no-progress --quiet git
    elif grep -qi "solus" /etc/*release; then 
      sudo eopkg install -y git
    elif grep -qi "mageia" /etc/*release; then
      sudo urpmi --auto git
    elif grep -qi "void linux" /etc/*release; then
      sudo xbps-install -Sy git
    elif grep -qi "slackware" /etc/*release; then
      sudo slackpkg install -batch git
    elif grep -qi "clear linux" /etc/*release; then
      sudo swupd bundle-add git
    elif grep -qi "sabayon" /etc/*release; then
      sudo equo install --yes git
    elif grep -qi "PCLinuxOS" /etc/*release; then
      sudo apt-get install -y git
    elif grep -qi "Crux" /etc/*release; then 
      sudo prt-get install -y git
    elif grep -qi "nixos" /etc/*release; then
      sudo nix-env -iA nixpkgs.git
    else
      echo "distro not found."
      exit 1
    fi
  fi

  echo "git cloning repository..."
  $non_root git clone --recursive https://gitlab.com/librewolf-community/browser/source.git librewolf-source
  sleep_and_clear
  echo "Done cloning repository changing current directory to \"librewolf-source\""
  cd librewolf-source
  echo "done changing current directory, making dir..."
  $non_root make dir
  sleep_and_clear
  echo "making bootstrap..."
  sleep_and_clear
  $non_root make bootstrap
  sleep_and_clear
  echo "doing the finishing touches..."
  non_root make run
}

librewolf_flatpak_install() { 
  echo "checking if flatpak is installed..."
  if [ -f /usr/bin/flatpak ]; then
    echo "flatpak is installed, adding flathub remote repository"
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sleep_and_clear
    echo "installing librewolf via flatpak..."
    sudo flatpak install flathub io.gitlab.librewolf-community
    A="Yes"
    break
  else  
    if grep -qi "opensuse" /etc/*release; then
          sudo zypper install 
          
        elif grep -qi "Fedora" /etc/*release; then
          sudo dnf install flatpak -y
          
        elif grep -qi "arch linux" /etc/*release; then
          sudo pacman -Sy --noconfirm "$command_1"
          
        elif grep -qi "gentoo" /etc/*release; then
          sudo emerge --ask --verbose sys-apps/flatpak
          
        elif grep -qi "debian" /etc/*release; then
          sudo apt install -y "$command_1"
          
        elif grep -qi "alpine" /etc/*release; then
          sudo apk add --no-progress --quiet flatpak
          
        elif grep -qi "solus" /etc/*release; then 
          sudo eopkg install -y flatpak
          
        elif grep -qi "mageia" /etc/*release; then
          sudo urpmi --auto flatpak
          
        elif grep -qi "void linux" /etc/*release; then
          sudo xbps-install -Sy --noconfirm flatpak

        elif grep -qi "clear linux" /etc/*release; then
          sudo swupd bundle-add flatpak

        elif grep -qi "PCLinuxOS" /etc/*release; then
          sudo apt-get install -y flatpak

        elif grep -qi "Crux" /etc/*release; then 
          sudo prt-get install -y flatpak

        elif grep -qi "nixos" /etc/*release; then
          nixOS_flatpak_installx
        else
          echo "distro not found."
          exit 1
        fi
    A="Yes"
    echo "flatpak is now installed, adding flathub remote repository"
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sleep_and_clear
    echo "installing librewolf via flatpak..."
    sudo flatpak install flathub io.gitlab.librewolf-community
    break
  fi
}

librewolf_AppImage_install() {
      echo "downloading Librewolf Appimage..."
      $non_root wget -q --show-progress https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/141.0.3-1/LibreWolf.x86_64.AppImage
      sleep_and_clear
      echo "Done downloading."
      $non_root chmod a+x LibreWolf.x86_64.AppImage
      echo "installing librewolf AppImage..."
      $non_root ./LibreWolf.x86_64.AppImage
}

# functions ending line

if [ -f /usr/bin/librewolf ]; then
  echo "Librewolf already installed, exiting script."
  exit 0
fi

# rest of your script here (only runs if librewolf not found)

if grep -qi "Debian" /etc/*release; then
    echo "checking if extrepo is installed..."
    if [ -f /usr/bin/extrepo ]; then
        echo "extrepo installed, installing librewolf..."
    else
        echo "extrepo not installed, installing..."
        sudo apt install extrepo -y
        sleep_and_clear
    fi

    if [ ! -f ~/.bash_history ]; then
        history -w
    else
        echo ".bash_history exists."
    fi

    if grep -qi "sudo apt update" ~/.bash_history; then
        echo "system already updated, not updating."
        debian_librewolf_install
    else
        echo "system is not updated, updating..."
        sudo apt update
        debian_librewolf_install
    fi
fi

if grep -qi "Fedora" /etc/*release; then
    if [ -f /etc/yum.repos.d/librewolf.repo ]; then
        echo "librewolf repo already added, skipping..."
        sudo dnf install librewolf -y
    else
        echo "librewolf repo not added, adding librewolf repo..."
        $non_root curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
        echo "done adding repo, installing fedora..."
        sudo dnf install librewolf -y
    fi
fi

if grep -qi "Gentoo" /etc/*release; then
    echo "adding librewolf repository..."
    sudo eselect repository add librewolf git https://codeberg.org/librewolf/gentoo.git
    echo "syncing repository..."
    $non_root emaint -r librewolf sync
fi

if grep -qi "opensuse" /etc/*release; then
    librewolf_opensuse_install
fi
if grep -qi "Arch Linux" /etc/*release; then
    if [ ! -f /usr/bin/yay ] && [ ! -f /usr/bin/paru ]; then
        X="X"
    else
        X=""
    fi

    if [ -f /usr/bin/paru ] && [ -f /usr/bin/yay ]; then
        while true; do
            echo "
1. Yay
2. Paru
"
            read -p "you have both \"yay\" and \"paru\" installed, choose a package manager to install librewolf with: " package_manager_choice
            if [[ "$package_manager_choice" == "1." || "$package_manager_choice" == "1" ]]; then
                echo "installing librewolf using yay..."
                $non_root yay -S librewolf
                break
            elif [[ "$package_manager_choice" == "2." || "$package_manager_choice" == "2" ]]; then
                echo "installing librewolf using paru..."
                $non_root paru -S librewolf
                break
            else
                echo "invalid input, try again..."
            fi
        done
    fi

    if [ -z "$X" ]; then
        while true; do
            read -p "You don't have either \"Yay\" or \"Paru\" installed, do you want to install one of them? (y/n): " yesorno1
            if [[ "$yesorno1" == "yes" || "$yesorno1" == "y" ]]; then
                while true; do
                    echo "
1. Yay
2. Paru
3. Abort Script
"
                    read -p "pick an package manager to install [1-3]: " pick_an_3rd_party_package_manager
                    if [[ "$pick_an_3rd_party_package_manager" == "1." || "$pick_an_3rd_party_package_manager" == "1" ]]; then
                        echo "installing Yay..."
                        echo "checking if \"git\" and \"base-devel\" is installed..."
                        if pacman -Qi git &> /dev/null; then
                            echo "git is installed, not installing..."
                        else
                            echo "git is not installed, installing..."
                            sudo pacman -S git --noconfirm
                            sleep_and_clear
                            echo "done installing git."
                        fi
                        if pacman -Qi base-devel &> /dev/null; then
                            echo "base-devel installed, not installing..."
                        else
                            echo "base-devel is not installed, installing..."
                            sudo pacman -S base-devel --noconfirm
                            sleep_and_clear
                            echo "done installing base-devel."
                            sleep_and_clear
                        fi
                        echo "git cloning \"Yay\" repository..."
                        $non_root git clone https://aur.archlinux.org/yay.git
                        sleep_and_clear
                        echo "done cloning \"Yay\" repository, changing current directory to \"Yay\"..."
                        $non_root cd yay
                        echo "compiling from source, may take a while..."
                        $non_root makepkg -Si
                        sleep_and_clear
                        echo "done compiling from source, installing librewolf ( contains yes or no prompts )"
                        $non_root yay -S --noconfirm librewolf
                        break
                    elif [[ "$pick_an_3rd_party_package_manager" == "2." || "$pick_an_3rd_party_package_manager" == "2" ]]; then
                        echo "installing paru..."
                        echo "checking if \"git\" and \"base-devel\" is installed..."
                        if pacman -Qi git &> /dev/null; then
                            echo "git is already installed, not installing..."
                        else
                            echo "git is not installed, installing git..."
                            sudo pacman -S git --noconfirm
                            sleep_and_clear
                            echo "done installing git"
                        fi
                        if pacman -Qi base-devel &> /dev/null; then
                            echo "base-devel already installed, not installing..."
                        else
                            echo "base-devel is not installed, installing..."
                            sudo pacman -S base-devel --noconfirm
                            sleep_and_clear
                            echo "done installing base-devel."
                        fi
                        echo "git cloning \"Paru\" repository..."
                        $non_root git clone https://aur.archlinux.org/paru.git
                        sleep_and_clear
                        echo "done git cloning \"Paru\" repository, changing current directory to \"paru\""
                        cd paru
                        echo "compiling from source..."
                        $non_root makepkg -Si
                        sleep_and_clear
                        echo "done compiling from source, installing librewolf (contains yes or no prompts)"
                        $non_root paru -S --noconfirm librewolf
                        break
                    else
                        echo "invalid option, try again..."
                    fi
                done
            elif [[ "$yesorno1" == "no" || "$yesorno1" == "n" ]]; then
                echo "not installing Yay or Paru, exiting script..."
                break
            else
                echo "invaild input, try again..."
                sleep_and_clear
            fi
        done
    fi
fi

if ! grep -i "Fedora" /etc/*release && ! grep -i "Debian" /etc/*release && ! grep -i "Gentoo" /etc/*release && ! grep -i "Arch Linux" /etc/*release; then
    echo "You are using a different linux distro, do you want to install Librewolf by:
1. Compile from Source
2. Flatpak
3. Appimage
"
    while true; do
        read -p "Pick a option through [1-3]: " pick_an_option
        if [[ "$pick_an_option" == "1." || "$pick_an_option" == "1" ]]; then
            echo "compiling from source..."
            librewolf_compile_from_source
            break
        elif [[ "$pick_an_option" == "2." || "$pick_an_option" == "2" ]]; then
            echo "installing via flatpak..."
            librewolf_flatpak_install
            break
        elif [[ "$pick_an_option" == "3." || "$pick_an_option" == "3" ]]; then
            echo "installing via AppImage..."
            librewolf_Appimage_install
            break
        else
            echo "Invalid option, pick a number from [1-3]"
            sleep_and_clear
        fi
    done
fi

sleep_and_clear
echo "done installing librewolf."
if [ "$A" == "Yes" ]; then
while true; do
    read -p "do you want to start librewolf? (yes/no/y/n): " yesorno
    if [[ "$yesorno" == "yes" || "$yesorno" == "y" ]]; then
        echo "starting librewolf..."
        $non_root flatpak run io.gitlab.librewolf-community
        break
    elif [[ "$yesorno" == "no" || "$yesorno" == "n" ]]; then
        echo "not starting librewolf, exiting..."
        exit 1
    else
        echo "invalid option, try again..."
        sleep_and_clear
    fi
done
else
while true; do
    read -p "do you want to start librewolf? (yes/no/y/n): " yesorno4
    if [[ "$yesorno4" == "yes" || "$yesorno4" == "y" ]]; then
        echo "starting librewolf..."
        $non_root librewolf
        break
    elif [[ "$yesorno4" == "no" || "$yesorno4" == "n" ]]; then
        echo "not starting librewolf, exiting..."
        exit 1
    else
        echo "invalid option, try again..."
        sleep_and_clear
    fi
done
