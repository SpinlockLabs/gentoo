#!/usr/bin/env bash
set -e

function command_exists() {
  which "${1}" > /dev/null 2>&1
}

if [ "${EUID}" -ne 0 ]
then
  echo "[INFO] Root privileges are needed. Running as root."
  if command_exists sudo
  then
    exec sudo ${BASH} "${0}" "${*}"
  else
    exec su -c "${BASH} ${0} ${*}"
  fi
fi

machinectl terminate gentoo || true
sleep 1
machinectl remove gentoo || true
