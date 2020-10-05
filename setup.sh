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
  sudo apt-get remove -y --purge libreoffice*
  sudo apt-get remove -y --purge thunderbird
  sudo apt-get clean
  sudo apt-get autoremove
}

install-software() {
  # shellcheck disable=SC2024
  sudo dpkg --set-selections <"$TDF/packages.list"
  sudo apt-get update && sudo apt-get -u dselect-upgrade

  # todo firefox : momentum
  # todo download intellij idea ultimate and execute
}

link-dotfiles() {
  ln -sf "$TDF/config/.gitconfig" "$HOME/.gitconfig"
  ln -sf "$TDF/config/.bashrc" "$HOME/.bashrc"
  ln -sf "$TDF/config/.ssh/config" "$HOME/.ssh/config"
  ln -sf "$TDF/config/.config/filezilla/sitemanager.xml" "$HOME/.config/filezilla/sitemanager.xml"
  ln -sf "$TDF/config/.config/autostart/Flameshot.desktop" "$HOME/.config/autostart/Flameshot.desktop"
  ln -sf "$TDF/config/.config/autostart/kupfer.desktop" "$HOME/.config/autostart/kupfer.desktop"
}

clone() {
  sudo apt-get install -y git
  git clone https://github.com/tiliavir/dotfiles.git "$TDF"

  mkdir "$HOME/Code"
  cd "$HOME/Code" || exit
  while read -r repo; do
    git clone "$repo"
  done <"$TDF/repos.list"
  cd - || exit
}

style() {
  # Install Git Icons: https://github.com/chrisjbillington/git-nautilus-icons
  sudo apt-get install python3-gi python-nemo python3-pip
  pip3 install --user git-nautilus-icons

  # Link images
  ln -s "$TDF/img/bg.jpg" "$HOME/Pictures/bg.jpg"
  ln -s "$TDF/img/grub.png" "$HOME/Pictures/grub.png"
  ln -s "$TDF/img/profile.png" "$HOME/Pictures/profile.png"

  # linux mint theme including key-bindings
  dconf load /org/cinnamon/ <"$TDF/cinnamon_desktop_backup"

  # Terminal config: https://ohmybash.github.io/
  sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)"
  sed -i .bak -e "s/OSH_THEME=.*/OSH_THEME=\"mbriggs\"/" "$HOME/.bashrc"
}

additionals() {
  echo "Additional steps:
 - momentum for firefox
 - intellij idea, download, not flatpak!
 - create new GitHub SSH key and store in ~/Code/tiliavir_rsa
 - set users/pwds in Filezilla

Optional steps:
 - grub-customizer"
}

neofetch
are-you-sure
clone
cleanup
install-software
link-dotfiles
style
additionals
