#!/usr/bin/env bash

TDF="$HOME/Code/dotfiles"

are-you-sure() {
  read -rp "Ready to continue? [y/n] " sure
  if [[ $sure != "y" && $sure != "Y" ]]
  then
    exit
  fi
}

cleanup() {
  printf "\nCleanup\n=======\n";
  sudo apt-get remove -yq --purge libreoffice*
  sudo apt-get remove -yq --purge thunderbird
  sudo apt-get remove -yq --purge flatpak
  sudo apt-get remove -yq --purge gir1.2-flatpak-1.0
  sudo apt-get remove -yq --purge snapd
  sudo apt-get clean
  sudo apt-get autoremove
}

install-software() {
  printf "\nInstall\n=======\n";
  sudo apt-get install -y dselect
  sudo dselect update

  # shellcheck disable=SC2024
  sudo dpkg --set-selections <"$TDF/config/packages.list"
  sudo apt-get update && sudo apt-get -u dselect-upgrade
}

link-dotfiles() {
  printf "\nConfig\n======\n";
  if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
  fi

  if [ ! -d "$HOME/.config/filezilla" ]; then
    mkdir -p "$HOME/.config/filezilla"
  fi

  ln -sf "$TDF/config/.gitconfig" "$HOME/.gitconfig"
  ln -sf "$TDF/config/.bashrc" "$HOME/.bashrc"
  ln -sf "$TDF/config/.ssh/config" "$HOME/.ssh/config"
  ln -sf "$TDF/config/.config/filezilla/sitemanager.xml" "$HOME/.config/filezilla/sitemanager.xml"
  ln -sf "$TDF/config/.config/autostart/Flameshot.desktop" "$HOME/.config/autostart/Flameshot.desktop"

  ln -sf "$TDF/config/.themes/" "$HOME/"
  ln -sf "$TDF/config/.local/share/cinnamon" "$HOME/.local/share"
}

clone() {
  printf "\nClone\n=====\n";
  sudo apt-get install -y git
  git clone --recurse-submodules https://github.com/tiliavir/dotfiles.git "$TDF"

  cd "$TDF" || exit
  git pull
  cd - || exit

  cd "$HOME/Code" || exit
  while read -r repo; do
    git clone "$repo"
  done <"$TDF/config/repos.list"
  cd - || exit
}

style() {
  printf "\nStyle\n=====\n";
  # Install Git Icons: https://github.com/chrisjbillington/git-nautilus-icons
  pip3 install --user git-nautilus-icons

  # Link images
  ln -s "$TDF/img/bg.jpg" "$HOME/Pictures/bg.jpg"
  ln -s "$TDF/img/grub.png" "$HOME/Pictures/grub.png"
  ln -s "$TDF/img/profile.png" "$HOME/Pictures/profile.png"

  # install grub theme
  "$TDF/mod/grub2-theme/install.sh -b -s 1080p -t whitesur -i white"

  # Install Plymouth theme
  cp "$TDF/mod/plymouth/linux-penguin" "/usr/share/plymouth/themes/"
  update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/linux-penguin/linux-penguin.plymouth 800
  update-initramfs -u

  # install icon set
  "$TDF/mod/icons/tela/install.sh blue"

  # linux mint theme including key-bindings
  # gathered with: `dconf dump /org/cinnamon/ > ./cinnamon-backup`
  sed -i.bak -e "s|/home/markus/|$HOME/|g" "$TDF/config/cinnamon-backup"
  dconf load /org/cinnamon/ <"$TDF/config/cinnamon-backup"

  # Terminal config: https://ohmybash.github.io/
  (sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)")
  sed -i.bak -e "s/OSH_THEME=.*/OSH_THEME=\"mbriggs\"/" "$HOME/.bashrc"

  # flameshot config: hide tray icon
  flameshot config -t false
}

additionals() {
  printf "\nAdditional\n==========\n";
  echo " - intellij idea, download, not flatpak!
 - create new GitHub SSH key and store in ~/Code/tiliavir_rsa
 - load cinnamon-menu.json config (right click on Starter icon > Configure)
 - clone private repos
 - set users/pwds in FileZilla";
}

neofetch
are-you-sure
clone
cleanup
install-software
link-dotfiles
style
additionals
