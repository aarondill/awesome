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
```

### Program List

See [packages.md](./docs/packages.md) for a list of packages installed by `setup.lua` and their purpose.

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
