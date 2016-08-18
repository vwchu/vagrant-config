#!/bin/bash
#-----------------------------------------------------------------
# vagrant.sh
#
# This script is a wrapper for Vagrant, allows the 
# Vagrantfile to be call for anywhere in the system
# with a `vagrant.yml` or `vagrant.json` locate in the
# current working directory. 
#
#<doc>
# Usage: ./vagrant.sh --configs=CONFIG [<vagrant_args>...]
#
#   --configs=CONFIG
#       Comma-separated list of paths to cascading config
#       files in order of cascade; if path does not 
#       include file extension, will try .yml and .json
#       in that order. Default: ./vagrant
#
#<enddoc>
#-----------------------------------------------------------------

print_help() {
  cat "$0" | sed -n '/#<doc>/,/#<enddoc>/p' | while read -r line; do
    if [[ "$line" != '#'* ]]; then
      break
    elif [[ "$line" == '#!/bin/bash' || "$line" == '#<doc>' || "$line" == '#<enddoc>' ]]; then
      continue
    else
      echo "${line:2}"
    fi
  done
}

ARGV=()
for argv in "$@"; do
  case "$argv" in
    (--configs=*) export VAGRANT_CONFIGS="${argv#--configs=}";;
    (--help) print_help && ARGV+=("$argv");;
    (*) ARGV+=("$argv");;
  esac
done

export VAGRANT_VAGRANTFILE="$(dirname $0)/../Vagrantfile"
vagrant "${ARGV[@]}"
