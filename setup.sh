#!/usr/bin/env bash
set -euC -o pipefail

# Ensure we're in the correct directory
SOURCE="${BASH_SOURCE[0]:-}"
DIR=$(dirname -- "$SOURCE")
[ -d "$DIR" ] || {
  printf '%s\n' "Could not find containing directory for script!" >&2
  exit 1
}
cd "$DIR"

ID=${FORCE_ID:-}
if [ -z "${ID}" ]; then ID=$(. /etc/os-release && echo "${ID_LIKE:-${ID:-}}"); fi
case "${ID,,}" in
debian | ubuntu)
  sudo apt install \
    awesome fonts-roboto rofi picom i3lock xclip qt5-style-plugins lxappearance \
    brightnessctl flameshot pasystray network-manager-gnome policykit-1-gnome \
    blueman diodon udiskie xss-lock notification-daemon ibus numlockx alsa-utils \
    playerctl libinput-tools
  ;;
arch)
  if ! command -v yay &>/dev/null; then
    printf '%s\n' "Please install yay to use this setup script" >&2
    exit 1
  fi
  yay -S --needed awesome ttf-roboto rofi-git picom i3lock xclip qt5-styleplugins \
    lxappearance brightnessctl flameshot pasystray network-manager-applet \
    polkit-gnome blueman diodon udiskie xss-lock notification-daemon ibus \
    numlockx alsa-utils playerctl
  ;;
'') # Strict compliance would set this to 'linux', but it's not useful to do.
  printf '%s\n' "Could not find ID_LIKE or ID in /etc/os-release. Please set the FORCE_ID variable if your system is a supported system." >&2
  exit 1
  ;;
*)
  printf '%s\n' "Unrecognized ID_LIKE or ID: $ID. Please report this as a bug if your system is not supported." >&2
  exit 1
  ;;
esac

git submodule update --init --recursive
make -C deps/autorandr/contrib/autorandr_launcher/
