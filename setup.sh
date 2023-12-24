#!/usr/bin/env sh
set -euC

# Ensure we're in the correct directory
dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
[ -d "$dir" ] || {
  printf '%s\n' "Could not find containing directory for script!" >&2
  exit 1
}
cd "$dir"

ID=${FORCE_ID:-}
if [ -z "${ID}" ]; then ID=$(. /etc/os-release && echo "${ID_LIKE:-${ID:-}}"); fi
install=1 # call ./setup.sh no-install to skip dep installation
if [ "${1:-}" = "no-install" ]; then install=0; fi

if [ "$install" -eq 1 ]; then
  case "$ID" in
  debian | ubuntu)
    sudo apt install \
      awesome fonts-roboto rofi picom i3lock xclip qt5-style-plugins lxappearance \
      brightnessctl flameshot pasystray network-manager-gnome policykit-1-gnome \
      blueman diodon udiskie xss-lock notification-daemon ibus numlockx alsa-utils \
      playerctl libinput-tools
    ;;
  arch)
    if ! command -v yay >/dev/null 2>/dev/null; then
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
fi

git submodule update --init --recursive
make -C deps/autorandr/contrib/autorandr_launcher/

LUAPOSIX_DIR="$dir/deps/luaposix"
LUAPOSIX_DEST="$dir/deps/posix"
( # note: subshell so pwd is not lost
  printf '%s\n' "Compiling luaposix"
  cd "$LUAPOSIX_DIR"
  # Note: if using lua 5.1, we may be missing the 'bit32' module!
  "$LUAPOSIX_DIR/build-aux/luke" LDOC='true'                     # build luaposix, set LDOC to 'true' to avoid compiling docs
  "$LUAPOSIX_DIR/build-aux/luke" PREFIX="$LUAPOSIX_DEST" install # 'install' to ./deps/posix so these can be required
)
