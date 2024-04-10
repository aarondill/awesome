#!/usr/bin/env bash
set -euC
log() { printf '%s\n' "$@" || true; }
err() { printf '%s\n' "$@" >&2 || true; }
abort() { err "$1" && exit "${2:-1}"; }
has() { [ -x "$(command -v "$1" 2>/dev/null)" ]; }

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
    sudo apt install -- \
      awesome fonts-roboto rofi picom i3lock xclip qt5-style-plugins lxappearance \
      brightnessctl flameshot pasystray network-manager-gnome policykit-1-gnome \
      blueman diodon udiskie xss-lock notification-daemon ibus numlockx playerctl \
      libinput-tools x11-xserver-utils redshift pulseaudio-utils
    ;;
  arch)
    if ! has yay; then
      err "Please install yay to use this setup script"
      exit 1
    fi
    yay -S --needed -- \
      awesome ttf-roboto rofi-git picom i3lock xclip qt5-styleplugins \
      lxappearance brightnessctl flameshot pasystray network-manager-applet \
      polkit-gnome blueman diodon udiskie xss-lock notification-daemon ibus \
      numlockx playerctl libinput xorg-xrandr redshift libpulse pacutils
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

# Use the AWESOME and LUA variables to configure this if needed
[ -n "${LUA:-}" ] || LUA=()
AWESOME=${AWESOME:-awesome}
if [ "${#LUA[@]}" -eq 0 ]; then
  declare -A lua_hash=() # Remove duplicate entries automatically
  while read -r -d: path; do
    path=${path:-"$PWD"} # empty path means pwd
    [ -d "$path" ] || continue
    for f in "$path"/lua*; do
      [ -x "$f" ] || continue
      case "$f" in */luac* | */luajit*) continue ;; esac # I'm not looking for luajit or luac
      f=$(realpath -- "$f") || continue
      lua_hash["$f"]=1
    done
  done < <(printf '%s' "$PATH:")
  LUA=("${!lua_hash[@]}") lua_hash=()

  lua_version=$("$AWESOME" --version | perl -ne 'm/running with Lua (\d+.\d+)/ && print "$1"')
  has "lua$lua_version" || abort "Could not find lua $lua_version required for awesome $AWESOME!" 1
fi

# Check that lua is installed.
# Do this to allow the user to choose their preferred lua version (since 'lua' is a virtual package in debian/ubuntu)
[ "${#LUA[@]}" -gt 0 ] || abort "Could not find any lua installations!" 1

git submodule update --init --recursive

AR_LAUNCHER_DIR="$dir/deps/autorandr/contrib/autorandr_launcher"
log "Compiling autorandr_launcher (${AR_LAUNCHER_DIR#"$dir/"})"
(cd "$AR_LAUNCHER_DIR" && make -s)

# LUAPOSIX_DIR="$dir/deps/luaposix" LUAPOSIX_DEST="$dir/deps/.build"
#
# pushd "$LUAPOSIX_DIR" >/dev/null
# for lua in "${LUA[@]}"; do
#   log "Compiling luaposix (${LUAPOSIX_DIR#"$dir/"}) using lua $lua"
#   # Note: if using lua 5.1, we may be missing the 'bit32' module!
#   "$lua" "$LUAPOSIX_DIR/build-aux/luke" --quiet LDOC='true' # build luaposix, set LDOC to 'true' to avoid compiling docs
#   log "Installing luaposix to ${LUAPOSIX_DEST#"$dir/"}"
#   "$lua" "$LUAPOSIX_DIR/build-aux/luke" --quiet PREFIX="$LUAPOSIX_DEST" install # 'install' to ./deps/.build so these can be required
# done
# popd >/dev/null
