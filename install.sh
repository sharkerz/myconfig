#!/usr/bin/env bash
# Install essential packages, fonts, programming language dependencies and macOS applications
# Author: Dario Blanco (dblancoit@gmail.com)

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=utils.sh
. utils.sh

trap exit_gracefully INT

packages=(
  bash-completion
  bash-git-prompt
  curl
  exa
  gettext
  graphviz
  gh
  git
  google-cloud-sdk
  helm
  jq
  kubectx
  kubernetes-cli
  markdown
  nmap
  openjdk
  openssl
  pipenv
  pulumi
  python3
  romkatv/powerlevel10k/powerlevel10k
  ruby
  shellcheck
  thefuck
  tmux
  tree
  vim
  wget
  yamllint
  yarn
  zsh
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

fonts=(
  font-consolas-for-powerline
  font-fira-code-nerd-font
  font-fira-code
  font-inconsolata-for-powerline
  font-inconsolata-nerd-font
  font-inconsolata
  font-menlo-for-powerline
  font-meslo-lg-dz
  font-meslo-lg-nerd-font
  font-meslo-lg
)

quicklook_plugins=(
  qlmarkdown
  qlprettypatch
  qlstephen
  qlimagesize
  quicklook-csv
  quicklook-json
)

apps=(
  alfred
  bitwarden
  caffeine
  calibre
  discord
  docker
  figma
  firefox
  github
  grammarly
  google-chrome
  iterm2
  keka
  kindle
  little-snitch
  microsoft-office
  microsoft-teams
  miro
  postman
  slack
  signal
  spotify
  telegram
  visual-studio-code
  vlc
  whatsapp
  zoom
)

python_packages=(
  virtualenv
  virtualenvwrapper
)

ruby_gems=(
  bundler
  rake
)

function install_xcode_clt() {
  if xcode-select -p > /dev/null; then
    print_yellow "XCode Command Line Tools already installed"
  else
    print_blue "Installing XCode Command Line Tools..."
    xcode-select --install
  fi
}

function install_homebrew() {
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  if hash brew &>/dev/null; then
    print_yellow "Homebrew already installed. Getting updates and package upgrades..."
    brew update
    brew upgrade
    brew doctor
  else
    print_blue "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew update
  fi
}

function install_brew_formulas() {
  local formulas=$*
  for formula in $formulas; do
    if brew list --formula | grep "$formula" > /dev/null; then
      print_yellow "Formula $formula is already installed"
    else
      brew install "$formula"
    fi
  done
}

function install_brew_casks() {
  local casks=$*
  for cask in $casks; do
    if brew list --casks | grep "$cask" > /dev/null; then
      print_yellow "Cask $cask is already installed"
    else
      brew install --cask "$cask"
    fi
  done
}

function install_packages() {
  print_blue "Installing macOS and Linux packages..."
  install_brew_formulas "${packages[@]}"
  print_blue "Cleaning up brew packages..."
  brew cleanup
}

function install_fonts() {
  print_blue "Installing fonts..."
  brew tap homebrew/cask-fonts
  install_brew_casks "${fonts[@]}"
}

function install_quicklook_plugins() {
  print_blue "Installing QuickLook Plugins..."
  install_brew_casks "${quicklook_plugins[@]}"
}

function install_macos_apps() {
  print_blue "Installing macOS apps..."
  brew tap homebrew/cask
  install_brew_casks "${apps[@]}"
}

function install_python_packages() {
  if pip3 freeze | grep virtualenv > /dev/null; then
    print_yellow "Essential python packages are already installed"
  else
    print_blue "Installing Python packages (requires admin password)..."
    sudo pip3 install "${python_packages[@]}"
  fi
}

function install_ruby_gems() {
  if [[ $(gem list | grep -e bundler -e rake -c) -ge 2 ]]; then
    print_yellow "Essential ruby packages are already installed"
  else
    print_blue "Installing Ruby gems (requires admin password)..."
    sudo gem install "${ruby_gems[@]}"
  fi
}

function main() {
  print_green "Installing essential packages, fonts, programming language dependencies and macOS applications..."
  install_xcode_clt
  install_homebrew
  install_packages
  install_fonts
  install_quicklook_plugins
  install_macos_apps
  install_python_packages
  install_ruby_gems
  print_green "Installation successful"
}

main