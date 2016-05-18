#!/bin/bash
#--------------------------------------------------
# vagrant_box.sh
#
# Builds and packages the given machine as a box
# for sharing and redistribution of VM image.
# Usage:
#   ./vagrant_box.sh [machine]
#--------------------------------------------------

if [[ -n "$1" ]]; then
  vagrant up "$1"
else
  vagrant up
fi

vm="${1:-$(echo .vagrant/machines/*/virtualbox/id | \
      sed -re 's|^[.]vagrant/machines/(.*)/virtualbox/id$|\1|' | \
      head -n 1)}"

if [[ -f .vagrant/machines/$vm/virtualbox/id ]]; then
  mkdir -p "boxes"
  rm -f "boxes/$vm.box"
  vagrant package \
    --base "$(cat .vagrant/machines/$vm/virtualbox/id)" \
    --output "boxes/$vm.box"
fi
