**This repository is no longer maintained. I recommend using [Tide](https://github.com/IlanCosman/tide) as a faster and more featureful alternative. To make it look close to Powerfish, you can use the following settings:**

```fish
set -g tide_left_prompt_items vi_mode context pwd terraform virtual_env rustc git
set -g tide_right_prompt_items status jobs
set -g tide_pwd_color_anchors black
set -g tide_pwd_color_dirs black
set -g tide_pwd_color_truncated_dirs black
set -g tide_vi_mode_bg_color_default brred
set -g tide_vi_mode_color_default black
set -g tide_vi_mode_icon_default N
set -g tide_vi_mode_bg_color_insert green
set -g tide_vi_mode_color_insert black
set -g tide_vi_mode_icon_insert I
set -g tide_vi_mode_bg_color_replace yellow
set -g tide_vi_mode_color_replace black
set -g tide_vi_mode_icon_replace R
set -g tide_vi_mode_bg_color_visual brmagenta
set -g tide_vi_mode_color_visual black
set -g tide_vi_mode_icon_visual V
set -g tide_virtual_env_icon '🐍'
```

# Powerfish

Powerfish is an elegant and informative prompt for [Fish](https://github.com/fish-shell/fish-shell) inspired by [agnoster-zsh-theme](https://github.com/agnoster/agnoster-zsh-theme) and [Powerline](https://github.com/powerline/powerline). The prompt only shows information relevant to the context, so it won't clutter your screen. But enough talking, a picture is worth a thousand words:

![Powerfish](prompt.png)![Powerfish-Tomorrow-Night](prompt-tomorrow-night.png)

## Features

Powerfish displays the following:

* Current Vi mode
* Flags:
    * private mode
    * failure of previous command
    * number of background jobs
* Kubernetes context
* Terraform workspace
* Vagrant status
* Python virtual environment
* Ruby version
* User:
    * Non-default user
    * Elevated priviledges
* Remote host
* Current working directory
* Git, via colors and flags:
    * Dirty or conficted working directory
    * Branch name or detached head
    * Number of commits ahead/behind remote
    * Number of untracked/modified/staged/conflicted/stashed files

And that's not all! You can choose from several different color themes - the default (on the picture), Tomorrow Night, Solarized Dark or Solarized Light.

## Install

**Fisherman**

You can install Powerfish via [Fisherman](https://github.com/fisherman/fisherman):

`fisher radek-sprta/powerfish`

**Manual**

Alternatively, for manual install from Git, first clone the repository:

`git clone git@gitlab.com:radek-sprta/powerfish.git`

Then copy the `fish_prompt.fish` to overwrite your current prompt.
```
mkdir -p ~/.config/fish/functions/
cp fish_prompt.fish ~/.config/fish/functions/
```

For best experience, you should use one of the [Powerline-patched fonts](https://github.com/Lokaltog/powerline-fonts).

## Configuration

You can override some of the default options in your `config.fish`:

```fish
set -g DEFAULT_USER username
set -g pf_no_counters true
set -g pf_color_theme default|tomorrow-night|solarized-dark|solarized-light
```

- `set -g DEFAULT_USER username` hides the default username.
- `set -g pf_no_counters` hides the counter for git files, jobs etc.
- `set -g pf_color_theme` change the color theme to `tomorrow-night`, `solarized-dark`, `solarized-light` or back to `default`

Alternatively, you can use powerfish command to set these.

```
Usage: powerfish help
       powerfish color COLOR
       powerfish counters true|false
       powerfish separator SEPARATOR
       powerfish user USER

Options:
color      Choose theme (default, tomorrow-night, solarized-dark, solarized-light)
counter    Whether to show counters [default true]
help       Show this help
separator  Configure prompt separator [such as ; leave empty for flat separation]
user       Set the default user
```

## License

Powerfish is licensed under GNU GPLv3.
