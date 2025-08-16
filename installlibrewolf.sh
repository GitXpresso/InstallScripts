#!/bin/bash
#functions:
debian_librewolf_install(){
sudo extrepo enable librewolf 
sudo apt update
echo "updating to add librewolf repository from extrepo..."
sudo apt update
sleep 0.5
clear
echo "installing librewolf"
sudo apt install librewolf -y
sleep 0.5 clear
}
librewolf_opensuse_install(){
echo "installing librewolf using zypper..."                                                                             echo "importing gpg key..."                                                                                             echo "gpg key should look like this: \"662E3CDD6FE329002D0CA5BB40339DD82B12EF16\""                                      sudo rpm --import https://rpm.librewolf.net/pubkey.gpg                                                                  sudo zypper ar -ef https://rpm.librewolf.net librewolf                                                                  sudo zypper ref                                                                                                         sudo zypper in librewolf
}
librewolf_compile_from_source(){

}
librewolf_flatpak_install(){

}
librewolf_AppImage_install(){

}
#functions ending line
   if [ -f /usr/bin/librewolf ]; then
      echo "Librewolf already installed, exiting..."
      exit 1
   else
      echo "Librewolf is not installed, installing librewolf based on your distro"
   fi
   if [ $(grep -i "Debian" /etc/*release) ]; then
      echo "checking if extrepo is installed..."
         if [ -f /usr/bin/extrepo ]; then
   	    echo "extrepo installed, installing librewolf..."
   	 else
            echo "extrepo not installed, installing..."
   	    sudo apt install extrepo -y
   	    sleep 0.5
   	    clear
   	 fi
   	    if [ ! -f ~/.bash_history ]; then
   	       history -w
   	    else
    	       echo ".bash_history exists."
   	    fi
   	       if [ $(cat ~/.bash_history | grep -i "sudo apt update") ]; then
   	          echo "system already updated, not updating."
                  debian_librewolf_install
               else
                  echo "system is not updated, updating..."
                  sudo apt update
   		  debian_librewolf_install
               fi		   
    fi
    if [ $(grep -i "Fedora" /etc/*release) ]; then
	 if [ -f /etc/yum.repos.d/librewolf.repo ]; then
	    echo "librewolf repo already added, skipping..."
            sudo dnf install librewolf -y
         else
            echo "librewolf repo not added, adding librewolf repo..."
            curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
            echo "done adding repo, installing fedora..."
            sudo dnf install librewolf -y
	 fi
    fi
    if [ $(grep -i "Gentoo" /etc/*release) ]; then
       echo "adding librewolf repository..."
       sudo eselect repository add librewolf git https://codeberg.org/librewolf/gentoo.git
       echo "syncing repository..."
       emaint -r librewolf sync
    fi
    if [ $(grep -i "opensuse" /etc/*release) ]; then
       librewolf_opensuse_install
    fi
    if [ $(grep -i "Arch Linux" /etc/*release) ]; then
       echo "checking if yay is installed..."
       if [ -f /usr/bin/yay ]; then
	  while true; do
            read -p "which 3rd party package manager do you have?
	    1. Yay
	    2. Paru
	    3. Neither
	    " $3rd_party_package_manager
	     if [ "$3rd_party_package_manager" == "1." || "$3rd_party_package_manager" == "1" ]; then
		echo "installing librewolf using yay..."
		yay -S librewolf
             elif [ "$3rd_party_package_manager" == "2." || "$3rd_party_package_manager" == "2" ]; then
		  echo "installing librewolf using paru..."
		  paru -S librewolf
             elif [ "$3rd_party_package_manager" == "3." || "$3rd_party_package_manager" == "3" ]; then
		  while true; do
	            read -p "which 3rd party package manager do you want to install?
		    1. Yay
		    2. Paru
		    " $pick_an_3rd_party_package_manager
		      if [ "$pick_an_3rd_party_package_manager" == "1." || "$pick_an_3rd_party_package_manager" == "1" ]; then
			 echo "installing yay..."
			 echo "checking if git and base-devel is installed..."
			 if [ $(pacman -q | grep -i "git") ]; then
		            echo "git is installed, not installing..."
		         else
		            echo "git is not installed, installing..."
			    sudo pacman -S git 
			 fi
			 if [ $(pacman -q | grep -i "base-devel") ]; then
		            echo "base-devel is installed, not installing..."
			 else
			    echo "base-devel is not installed, installing..."
			    sudo pacman -S base-devel
			 fi
                         sleep 0.5
			 clear
			 echo "cloning yay repository..."
			 git clone https://aur.archlinux.org/yay.git
			 sleep 0.5
			 clear
			 echo "done cloning yay repository, changing directory to \"yay\""
			 cd yay
			 echo "building source from repository, may take a while..."
			 makepkg -si
			 sleep 0.5
			 clear
			 echo "done installing yay, installing librewolf... (contains yes or no prompts)"
			 sudo yay -S librewolf
		     elif [ "$pick_an_3rd_party_package_manager" == "2." || "$pick_an_3rd_party_package_manager" == "2" ]; then                    echo "installing paru..."                                                                                                echo "checking if git and base-devel is installed..."                                                                   if [ $(pacman -q | grep -i "git") ]; then                                                                                  echo "git is installed, not installing..."                                                                           else                                                                                                                       echo "git is not installed, installing..."                                                                              sudo pacman -S git                                                                                                   fi                                                                                                                      if [ $(pacman -q | grep -i "base-devel") ]; then                                                                           echo "base-devel is installed, not installing..."                                                                    else                                                                                                                       echo "base-devel is not installed, installing..."                                                                       sudo pacman -S base-devel                                                                                            fi                                                                                                                      sleep 0.5                                                                                                               clear                                                                                                                   echo "cloning yay repository..."                                                                                        git clone https://aur.archlinux.org/yay.git                                                                             sleep 0.5                                                                                                               clear                                                                                                                   echo "done cloning yay repository, changing directory to \"yay\""                                                       cd yay                                                                                                                  echo "building source from repository, may take a while..."                                                             makepkg -si                                                                                                             sleep 0.5                                                                                                               clear                                                                                                                   echo "done installing yay, installing librewolf... (contains yes or no prompts)"   
		     else 
			 echo "invalid option, try again..."
	             fi
		 done
	  echo "yay is installed, installing librewolf..."
	        yay -S librewolf
       elif
	  read -p "yay is not installed, do you have paru?" $paru
	    if [ "$paru" == "yes" || "$paru" == "y" ]; then
	       echo "installing librewolf via paru..."
	       paru -S librewolf
            elif   

    if [ ! $(grep -i "Fedora" /etc/*release) ] && [ ! $(grep -i "Debian" /etc/*release) ] && [ ! $(grep -i "Gentoo" /etc/*release) ] && [ ! $(grep -i "Gentoo" /etc/*release) ] && [ ! $(grep -i "Arch Linux" /etc/*release) ]; then
       echo "You are using a different linux distro, do you want to install Librewolf by:
       1. Compile from Source
       2. Flatpak
       3. Appimage
       "
       while true; do
       read -p "Pick an option through 1 - 3: " $pick_an_option
       if [ "$pick_an_option" == "1." || "$pick_an_option" == "1" ]; then
	  echo "compiling from source..."
          librewolf_compile_from_source
       elif [ "$pick_an_option" == "2." || "$pick_an_option" == "2" ]; then
          echo "installing via flatpak..."
          librewolf_flatpak_install
	  
       elif [ "$pick_an_option" == "3." || "$pick_an_option" == "3" ]; then
          echo "installing via AppImage..."
          librewolf_Appimage_install
       else
          echo "Invalid option, pick an number from 1 to 3"
       fi
     done
   fi
sleep 0.5
clear
echo "done installing librewolf."
while true; do
  read -p "do you want to start librewolf? (yes/no/y/n): " $yesorno
    if [ "$yesorno" == "yes" || "$yesorno" == "y" ]; then
       echo "starting librewolf..."
       librewolf
    elif [ "$yesorno" == "no" || "$yesorno" == "n" ]; then
       echo "not starting librewolf, exiting..."
       exit 1
    else
       echo "invalid option, try again..."
       sleep 0.5 
       clear
    fi
done
