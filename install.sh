#!/usr/bin/env bash
# Install essential packages, fonts, programming language dependencies and macOS applications
# Author: Dario Blanco (dblancoit@gmail.com)

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=utils.sh
. utils.sh

trap exit_gracefully INT

taps=(
  hashicorp/tap
  helm/tap
  homebrew/cask
  homebrew/cask-fonts
  homebrew/core
  pulumi/tap
  romkatv/powerlevel10k
  vmware-tanzu/carvel
)

packages=(
  argocd
  awscli
  aws-iam-authenticator
  bash-completion
  bash-git-prompt
  chart-releaser
  curl
  exa
  gettext
  graphviz
  gh
  git
  golang
  google-cloud-sdk
  gpg
  hashicorp/tap/terraform
  helm
  jq
  jsonnet-bundler
  jsonnet
  kubectx
  kubernetes-cli
  kustomize
  markdown
  nmap
  openjdk
  openssl
  pipenv
  python3
  romkatv/powerlevel10k/powerlevel10k
  ruby
  shellcheck
  terraformer
  thefuck
  tmux
  tree
  vault
  vim
  watch
  wget
  yamllint
  yarn
  yq
  ytt
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
  macs-fan-control
  microsoft-office
  microsoft-teams
  miro
  postman
  slack
  signal
  spotify
  telegram
  tunnelblick
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

go_libraries=(
  github.com/brancz/gojsontoyaml
)

function install_xcode_clt() {
  if xcode-select -p > /dev/null; then
    print_yellow "XCode Command Line Tools already installed"
  else
    print_blue "Installing XCode Command Line Tools..."
    xcode-select --install
  fi
}

function apply_brew_taps() {
  local tap_packages=$*
  for tap in $tap_packages; do
    if brew tap | grep "$tap" > /dev/null; then
      print_yellow "Tap $tap is already applied"
    else
      brew tap "$tap"
    fi
  done
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
  apply_brew_taps "${taps[@]}"
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

function install_go_libraries() {
  print_blue "Installing Go libraries..."
  go get "${go_libraries[@]}"
  export PATH
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
  install_go_libraries
  install_python_packages
  install_ruby_gems
  # Install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  print_green "Installation successful"
}

main
