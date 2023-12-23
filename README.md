## Material and Mouse driven theme for [AwesomeWM](https://awesomewm.org/)

### Original design by PapyElGringo. Cloned from [ChrisTitusTech/titus-awesome](https://github.com/ChrisTitusTech/titus-awesome)

This repo is designed to be compatible with AwesomeWM latest (4.3) and the git HEAD.
I primarily use latest, so this may be undertested on HEAD.
If you notice any issues, please create an issue or PR!

An almost desktop environment made with [AwesomeWM](https://awesomewm.org/) following the [Material Design guidelines](https://material.io) with a performant opinionated mouse/keyboard workflow to increase daily productivity and comfort.

[![](./theme/titus-theme/demo.png)](https://www.reddit.com/r/unixporn/comments/anp51q/awesome_material_awesome_workflow/)

## Installation

for convenience, a `setup.sh` script has been provided, simply clone the repository and run `./setup.sh` to auto install dependencies and setup submodules.
If using `setup.sh`, skip to 3) after successfully running it.

```shell
git clone https://github.com/aarondill/awesome ~/.config/awesome
cd ~/.config/awesome/
bash ./setup.sh
# run lxappearance to modify theme if so desired

```

### 1) Get all the dependencies

#### Debian-Based

```shell
sudo apt install awesome fonts-roboto rofi picom i3lock xclip qt5-style-plugins lxappearance brightnessctl flameshot pasystray network-manager-gnome policykit-1-gnome blueman diodon udiskie xss-lock notification-daemon ibus numlockx alsa-utils playerctl libinput-tools
```

#### Arch-Based

```shell
yay -S --needed awesome ttf-roboto rofi-git picom i3lock xclip qt5-styleplugins lxappearance brightnessctl flameshot pasystray network-manager-applet polkit-gnome blueman diodon udiskie xss-lock notification-daemon ibus numlockx alsa-utils playerctl
```

#### Program list

- [AwesomeWM](https://awesomewm.org/) as the window manager - universal package install: awesome
- [Roboto](https://fonts.google.com/specimen/Roboto) as the **font** - Debian: fonts-roboto Arch: ttf-roboto
- [Rofi](https://github.com/DaveDavenport/rofi) for the app launcher - universal install: rofi
- [picom](https://github.com/yshui/picom) for the compositor (blur and animations) Universasal install: picom
- [i3lock](https://github.com/meskarune/i3lock-fancy) the lockscreen application universal install: i3lock-fancy
- [xclip](https://github.com/astrand/xclip) for copying screenshots to clipboard package: xclip
- [gnome-polkit] recommend using the gnome-polkit as it integrates nicely for elevating programs that need root access
- [lxappearance](https://sourceforge.net/projects/lxde/files/LXAppearance/) to set up the gtk and icon theme
- [flameshot](https://flameshot.org/) screenshot utility of choice, can be replaced by whichever you want, just remember to edit the `apps.lua` file
- [pasystray](https://github.com/christophgysin/pasystray) Audio Tray icon for PulseAudio. Replace with another if not running PulseAudio.
- [network-manager-applet](https://gitlab.gnome.org/GNOME/network-manager-applet) nm-applet is a Network Manager Tray display from GNOME.
- [xcape](https://github.com/alols/xcape) xcape makes single taps of ctrl (or caps lock) emit an ESC code
- [blueman](https://github.com/blueman-project/blueman/) blueman is a simple bluetooth manager that doesn't depend on any specific DE.
- [diodon](https://github.com/diodon-dev/diodon) is a clipboard manager to keep clipboard after closing a window
- [udiskie](https://github.com/coldfix/udiskie) handles USB drives and auto-mount

### 2) Clone the configuration

```
git clone https://github.com/aarondill/awesome ~/.config/awesome
git submodule update --init --recursive
make -C deps/autorandr/contrib/autorandr_launcher/
```

### 3) Set the themes

Start `lxappearance` to activate the **icon** theme and **GTK** theme
Note: for cursor theme, edit `~/.icons/default/index.theme` and `~/.config/gtk3-0/settings.ini`, for the change to also show up in applications run as root, copy the 2 files over to their respective place in `/root`.

Recommended Cursors - <https://github.com/keeferrourke/capitaine-cursors>

### 4) Same theme for Qt/KDE applications and GTK applications

install `qt5-style-plugins` (debian) | `qt5-styleplugins` (arch)
