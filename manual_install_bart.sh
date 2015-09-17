#!/usr/bin/env bash

# Check running as root
if [ $(id -u) != '0' ]; then
  echo "You must run $0 as root!"
  exit 1
fi

su - barman -c "mkdir /var/lib/barman/.ssh"

