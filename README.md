<!-- This file is generated from README.tmpl.md -->
## Theme for [AwesomeWM](https://awesomewm.org/)

### Original design by [PapyElGringo](https://github.com/PapyElGringo). Cloned from [ChrisTitusTech/titus-awesome](https://github.com/ChrisTitusTech/titus-awesome)

This repo is designed to be compatible with AwesomeWM latest (4.3) and the git HEAD.
I primarily use latest, so this may be undertested on HEAD.
If you notice any issues, please create an issue or PR!

An almost desktop environment made with [AwesomeWM](https://awesomewm.org/) with a performant opinionated keyboard workflow to increase daily productivity and comfort.

![](./theme/images/demo.png)
| Full Screen | Rofi Launcher | Exit Screen | Shortcut Menu |
| :---------: | :-----------: | :---------: | :-----------: |
| ![](./theme/images/fullscreen.png) | ![](./theme/images/rofi.png) | ![](./theme/images/exit-screen.png) | ![](./theme/images/shortcut-menu.png) |

## Installation

### `setup.lua`

For convenience, a `setup.lua` script has been provided, simply clone the repository and run `lua ./setup.lua` to auto install dependencies and setup submodules.
note: Gio is required. Installing `awesome` will install `gio` as a dependency.
note: LGI is required. This may need to be installed manually.

```shell
> git clone 'https://github.com/aarondill/awesome' ~/.config/awesome
> pacman -S awesome lua-lgi # REPLACE WITH YOUR PACKAGE MANAGER
> cd ~/.config/awesome/ && ./setup.lua
> # run lxappearance to modify theme if so desired
```

### Program List

<!-- This is generated via lua. Note: the full line must match `^%s*{{([%w_-]+)}}%s*$` -->

{{program-list}}

## Set the theme (optional)

Install `lxappearance` to setup the _icon and GTK_ themes
Note: copy `~/.config/gtk3-0/settings.ini` to `~root/config/gtk3-0/settings.ini` to also show up in applications run as root

## Configuration:

All configuration should be possible through the `/configuration` directory.
Note that some of this has become complicated, so please report an issue if any arise.

## Running:

Start awesome you might start any other X window manager.

```shell
> startx "$(which awesome)"
```

If you cloned the repository to an unusual location, you can use awesome's `-c` option to start it
The configuration should handle this without issue.

```shell
startx "$(which awesome)" -c "<PATH TO THE REPO>/rc.lua"
```

### Lines of code
<sup><sub>Generated at commit 4ffd754e5bd7bfc45e33309029d94218f839f963</sub></sup>
cloc|github.com/AlDanial/cloc v 2.02
--- | ---

Language|files|blank|comment|code
:-------|-------:|-------:|-------:|-------:
Lua|170|871|2367|7639
SVG|84|8|23|474
Markdown|2|42|3|93
Bourne Again Shell|2|5|18|27
JSON|1|0|0|20
TOML|1|1|0|9
--------|--------|--------|--------|--------
SUM:|260|927|2411|8262
