#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -Eeuo pipefail
IFS=$'\n\t'

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ "$(id -u)" -eq 0 ]; then
    print_error "🙀 This script should not be run as root!"
    echo ""
    echo "Please run this as your user, you will be prompted for your password when necessary."
    exit 1
fi

print_status "Checking for Xcode Command Line Tools..."

if [ -f /Library/Developer/CommandLineTools/usr/bin/clang ]; then
  print_success "Xcode Command Line Tools are installed. Continuing..."
else
  print_warning "Installing the Command Line Tools (expect a GUI popup)"
  sudo /usr/bin/xcode-select --install
  print_status "Relaunch this script when the installation has completed."
  exit 1
fi


exists() {
  command -v "$1" >/dev/null 2>&1
}

print_status "Checking for Homebrew..."

if ! exists brew; then
  print_status "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for both Intel and Apple Silicon Macs
  if [[ $(uname -m) == "arm64" ]]; then
    # Apple Silicon Mac
    print_status "Configuring Homebrew for Apple Silicon Mac..."
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Intel Mac
    print_status "Configuring Homebrew for Intel Mac..."
    (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  print_success "Homebrew installed successfully!"
else
  print_success "Homebrew is already installed, continuing..."
fi

# Install Python 3 via Homebrew (modern approach)
print_status "Checking for Python 3..."

if ! exists python3; then
  print_status "Installing Python 3.13 via Homebrew..."
  brew install python@3.13
  print_success "Python 3.13 installed successfully!"
else
  print_success "Python 3 is already installed, continuing..."
fi

# Ensure pip is up to date (handle externally-managed-environment)
if exists python3; then
  print_status "Updating pip to latest version..."
  if python3 -m pip install --upgrade pip --user 2>/dev/null; then
    print_success "pip updated successfully!"
  else
    print_warning "Could not upgrade pip system-wide, but pip is available for user installations"
  fi
fi

# Set up Python aliases in shell config
print_status "Setting up Python aliases..."

SHELL_CONFIG=""
if [[ "$SHELL" == "/bin/zsh" ]]; then
    SHELL_CONFIG=~/.zshrc
elif [[ "$SHELL" == "/bin/bash" ]]; then
    SHELL_CONFIG=~/.bash_profile
fi

if [[ -n "$SHELL_CONFIG" ]]; then
    print_status "Configuring Python aliases in $SHELL_CONFIG..."
    # Add Python aliases if they don't exist
    if ! grep -q "alias python=python3" "$SHELL_CONFIG"; then
        echo 'alias python=python3' >> "$SHELL_CONFIG"
    fi
    if ! grep -q "alias pip=pip3" "$SHELL_CONFIG"; then
        echo 'alias pip=pip3' >> "$SHELL_CONFIG"
    fi
    print_success "Python aliases configured!"
fi

# Install Ansible via Homebrew (recommended for macOS)
print_status "Checking for Ansible..."

if ! exists ansible; then
  print_status "Installing Ansible via Homebrew..."
  brew install ansible
  print_success "Ansible installed successfully!"
else
  print_success "Ansible is already installed, continuing..."
fi

print_status "Verifying Ansible installation..."

if ! exists ansible-playbook; then
  print_error "ansible-playbook command not found!"
  print_status "Trying to refresh Homebrew PATH..."
  eval "$(brew shellenv)"
  
  if ! exists ansible-playbook; then
    print_error "ansible-playbook still not found. Please check your Homebrew installation."
    exit 1
  fi
fi

print_success "Ansible is ready to use!"

print_status "Starting Ansible playbook execution..."
print_status "You may be prompted for your password for system-level installations."

if ansible-playbook -i hosts.ini playbook.yml --ask-become-pass; then
    echo ""
    print_success "🎉 Laptop setup complete!"
    echo ""
    print_success "Your development environment is ready to use!"
    osascript -e 'display notification "Your laptop should be ready to use now! 😸" with title "Laptop Setup Complete"'
else
    echo ""
    print_error "❌ Laptop setup failed!"
    echo ""
    print_warning "It is safe to re-run this script as many times as you need to."
    echo ""
    print_status "Check the error messages above for troubleshooting information."
    osascript -e 'display notification "Automated laptop setup has failed! 🙀" with title "Laptop Setup Failed!"'
fi
