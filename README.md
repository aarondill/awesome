## Theme for [AwesomeWM](https://awesomewm.org/)

### Original design by [PapyElGringo](https://github.com/PapyElGringo). Cloned from [ChrisTitusTech/titus-awesome](https://github.com/ChrisTitusTech/titus-awesome)

This repo is designed to be compatible with AwesomeWM latest (4.3) and the git HEAD.
I primarily use latest, so this may be undertested on HEAD.
If you notice any issues, please create an issue or PR!

An almost desktop environment made with [AwesomeWM](https://awesomewm.org/) with a performant opinionated keyboard workflow to increase daily productivity and comfort.

![](./theme/images/demo.png)

|             Fullscreen             |        Rofi Launcher         |             Exit Screen             |
| :--------------------------------: | :--------------------------: | :---------------------------------: |
| ![](./theme/images/fullscreen.png) | ![](./theme/images/rofi.png) | ![](./theme/images/exit-screen.png) |

## Installation

### `setup.sh`

for convenience, a `setup.sh` script has been provided, simply clone the repository and run `./setup.sh` to auto install dependencies and setup submodules.
If using `setup.sh`, skip to 3) after successfully running it.

```shell
> git clone 'https://github.com/aarondill/awesome' ~/.config/awesome
> cd ~/.config/awesome/ && ./setup.sh
> # run lxappearance to modify theme if so desired
```

NOTE: if your awesome or lua are not in the PATH, set $AWESOME or $LUA respectively to override the executable.
Note that $LUA's version _must_ match the version that will be used by awesome

```shell
> # get the lua version required by awesome
> awesome-client 'require("naughty").notify({text=_VERSION})' # awesome v4.3 or before
> awesome-client 'require("naughty").notify({message=_VERSION})' # awesome v4.4 or later
```

### Manual (not recommended. May be required on unsupported distros):

```
git clone 'https://github.com/aarondill/awesome' ~/.config/awesome
cd ~/.config/awesome && git submodule update --init --recursive
```

### Program list (note: may be outdated. See `setup.sh` for full dependency list)

- [AwesomeWM](https://awesomewm.org/) as the window manager - universal package install: awesome
- [Roboto](https://fonts.google.com/specimen/Roboto) as the **font** - Debian: fonts-roboto Arch: ttf-roboto
- [Rofi](https://github.com/DaveDavenport/rofi) for the app launcher - universal install: rofi
- [picom](https://github.com/yshui/picom) for the compositor (blur and animations) Universasal install: picom
- [i3lock](https://github.com/meskarune/i3lock-fancy) the lockscreen application universal install: i3lock-fancy
- [xclip](https://github.com/astrand/xclip) for copying screenshots to clipboard package: xclip
- [gnome-polkit](https://gitlab.gnome.org/Archive/policykit-gnome) recommend using the gnome-polkit as it integrates nicely for elevating programs that need root access
- [lxappearance](https://sourceforge.net/projects/lxde/files/LXAppearance/) to set up the gtk and icon theme
- [flameshot](https://flameshot.org/) screenshot utility of choice, can be replaced by whichever you want, just remember to edit the `configuration/apps/default.lua` file
- [pasystray](https://github.com/christophgysin/pasystray) Audio Tray icon for PulseAudio. Replace with another if not running PulseAudio.
- [network-manager-applet](https://gitlab.gnome.org/GNOME/network-manager-applet) nm-applet is a Network Manager Tray display from GNOME.
- [xcape](https://github.com/alols/xcape) xcape makes single taps of ctrl (or caps lock) emit an ESC code
- [blueman](https://github.com/blueman-project/blueman/) blueman is a simple bluetooth manager that doesn't depend on any specific DE.
- [diodon](https://github.com/diodon-dev/diodon) is a clipboard manager to keep clipboard after closing a window
- [udiskie](https://github.com/coldfix/udiskie) handles USB drives and auto-mount

## Set the themes

Start `lxappearance` to activate the **icon** theme and **GTK** theme
Note: copy `~/.config/gtk3-0/settings.ini` to `~root/config/gtk3-0/settings.ini` to also show up in applications run as root

### Same theme for Qt/KDE applications and GTK applications

install `qt5-style-plugins` (debian) | `qt5-styleplugins` (arch)

## Configuration:

All configuration should be possible through the `/configuration` directory.
Note that some of this has become complicated, so please report an issue if any arise.

## Running:

Start awesome you might start any other X window manager.

If you don't know how to do this, I suggest you research the topic.
Use one of the following commands, depending on your installed packages:

```shell
> startx "$(which awesome)"
> xinit "$(which awesome)"
```

If you cloned the repository to an unusual location, you can use awesome's `-c` option to start it
The configuration should handle this without issue.

```shell
startx "$(which awesome)" -c "<PATH TO THE REPO>/rc.lua"
```
