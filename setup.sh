#!/usr/bin/env bash
set -e

INIT="
systemctl enable systemd-networkd systemd-resolved;
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf;
mkdir -p /etc/portage/repos.conf;
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf;
emerge-webrsync;
emerge --sync --quiet;
eselect news read --quiet all;
eselect locale set ${LANG};
emerge app-shells/bash-completion;
"

AUTOBUILDS_URL="http://distfiles.gentoo.org/releases/amd64/autobuilds"
STAGE3_LATEST_FILE="${AUTOBUILDS_URL}/latest-stage3-amd64-systemd.txt"

function command_exists() {
  which "${1}" > /dev/null 2>&1
}

function error() {
  echo "[ERROR] ${*}"
  exit 1
}

function info() {
  echo "[INFO] ${*}"
}

function does_image_exist() {
  machinectl show-image "${1}" > /dev/null 2>&1
}

function get_latest_tar_url() {
  local latest=""
  if command_exists curl
  then
    latest="$(curl --silent ${STAGE3_LATEST_FILE})"
  elif command_exists wget
  then
    latest="$(wget -O- --quiet ${STAGE3_LATEST_FILE})"
  else
    error "curl or wget is not available, can't find latest tar."
  fi
  path=$(echo "${latest}" | grep -v "^[#]" | awk '{print $1}')
  echo "${AUTOBUILDS_URL}/${path}"
}

if ! command_exists systemd-nspawn || ! command_exists machinectl
then
  error "Gentoo in a Container only supports systems based on systemd."
fi

if [ -z ${LANG} ]
then
  error "LANG not set, we are unable to continue."
fi

if [ "${EUID}" -ne 0 ]
then
  info "Root privileges are needed. Running as root."
  if command_exists sudo
  then
    exec sudo ${BASH} "${0}" "${*}"
  else
    exec su -c "${BASH} ${0} ${*}"
  fi
fi

if does_image_exist gentoo
then
  error "Gentoo image already exists."
fi

URL="$(get_latest_tar_url)"
machinectl pull-tar --verify=no "${URL}" gentoo
machinectl start gentoo
sleep 3
machinectl shell gentoo /bin/bash -c "${INIT}"
info "Setup complete."
