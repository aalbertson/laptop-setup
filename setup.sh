#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -Eeuo pipefail
IFS=$'\n\t'

if [ "$(id -u)" -eq 0 ]; then
    echo "🙀 This script should not be run as root!"
    echo ""
    echo "Please run this as your user, you will be prompted for your password when necessary."
    exit 1
fi

if [ -f /Library/Developer/CommandLineTools/usr/bin/clang ]; then
  echo "XCode Command Line Tools are installed. Continuing..."
else
  echo "Installing the Command Line Tools (expect a GUI popup)"
  sudo /usr/bin/xcode-select --install
  echo "Relaunch this script when the installation has completed."
  exit 1
fi


exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! exists brew; then
  echo "this script requires 'homebrew'."
  echo "installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "homebrew is installed, continuing..."
fi

if ! exists python3; then
  echo "this script requires 'python3'."
  echo "installing..."
  export PATH="/usr/local/opt/python/libexec/bin:$PATH"
  brew install python
else
  echo "python3 is installed, continuing..."
fi

#if ! exists pip3; then
#  echo "this script requires 'pip3'."
#  echo "installing..."
#  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#  python get-pip.py --user
#else
#  echo "pip3 is installed, continuing..."
#fi

if ! exists ansible; then
  echo "this script requires 'ansible'."
  echo "installing..."
  sudo pip3 install ansible
else
  echo "ansible is installed, continuing..."
fi

if ansible-playbook -i hosts.ini playbook.yml --ask-become-pass; then
    echo ""
    echo "    Laptop setup complete!"
    echo ""
    osascript -e 'display notification "Your laptop should be ready to use now! 😸" with title "Laptop Setup Complete"'
else
    echo ""
    echo "    Laptop setup Failed :("
    echo ""
    echo "    It is safe to re-run this script as many times as you"
    echo "    need to."
    echo ""
    osascript -e 'display notification "Automated laptop setup has failed! 🙀" with title "Laptop Setup Failed!"'
fi
