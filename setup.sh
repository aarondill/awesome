#!/usr/bin/env sh
set -euC
log() { printf '%s\n' "$@" || true; }
err() { printf '%s\n' "$@" >&2 || true; }

# Ensure we're in the correct directory
dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
[ -d "$dir" ] || {
  err "Could not find containing directory for script!"
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
      err "Please install yay to use this setup script"
      exit 1
    fi
    yay -S --needed awesome ttf-roboto rofi-git picom i3lock xclip qt5-styleplugins \
      lxappearance brightnessctl flameshot pasystray network-manager-applet \
      polkit-gnome blueman diodon udiskie xss-lock notification-daemon ibus \
      numlockx alsa-utils playerctl
    ;;
  '') # Strict compliance would set this to 'linux', but it's not useful to do.
    err "Could not find ID_LIKE or ID in /etc/os-release. Please set the FORCE_ID variable if your system is a supported system."
    exit 1
    ;;
  *)
    err "Unrecognized ID_LIKE or ID: $ID. Please report this as a bug if your system is not supported."
    exit 1
    ;;
  esac
fi

git submodule update --init --recursive

AR_LAUNCHER_DIR="$dir/deps/autorandr/contrib/autorandr_launcher"
log "Compiling autorandr_launcher (${AR_LAUNCHER_DIR#"$dir/"})"
(cd "$AR_LAUNCHER_DIR" && make -s)

LUAPOSIX_DIR="$dir/deps/luaposix"
LUAPOSIX_DEST="$dir/deps/.build"
log "Compiling luaposix (${LUAPOSIX_DIR#"$dir/"})"
(
  cd "$LUAPOSIX_DIR"
  # Note: if using lua 5.1, we may be missing the 'bit32' module!
  "$LUAPOSIX_DIR/build-aux/luke" --quiet LDOC='true' # build luaposix, set LDOC to 'true' to avoid compiling docs
  log "Installing luaposix to $LUAPOSIX_DEST"
  "$LUAPOSIX_DIR/build-aux/luke" --quiet PREFIX="$LUAPOSIX_DEST" install # 'install' to ./deps/.build so these can be required
)
