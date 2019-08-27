#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

if [ $(id -u) -eq 0 ]; then
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

echo "Installing pip"
sudo easy_install pip

echo "Installing ansible"
sudo pip install ansible

if ansible-playbook -i hosts.ini playbook.yml --ask-become-pass; then
    echo ""
    echo "    Laptop setup complete!"
    echo ""
    echo "    Feel free to visit the #dev-eff slack channel with questions!"
    osascript -e 'display notification "Your laptop should be ready to use now! 😸" with title "Laptop Setup Complete"'
else
    echo ""
    echo "    Laptop setup Failed :("
    echo ""
    echo "    It is safe to re-run this script as many times as you"
    echo "    need to."
    echo ""
    echo "    If you run into trouble don't hesitate to visit the #dev-eff"
    echo "    slack channel for help troubleshooting!"
    osascript -e 'display notification "Automated laptop setup has failed! 🙀" with title "Laptop Setup Failed!"'
fi
