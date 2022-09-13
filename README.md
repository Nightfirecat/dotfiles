dotfiles
========

## Features

* A wealth of bash and git aliases scoured from the internet
* Beautiful terminal `PS1` and message-of-the-day-style prompt at start of session
* Sane defaults for shell options and builtins (`rm -I --preserve-root`, `mkdir -pv`, `grep --color=auto`, etc.)
* Config files and settings for [vim](https://www.vim.org/), [ripgrep](https://github.com/BurntSushi/ripgrep),
  [abcde](http://lly.org/~rcw/abcde/page/), and [shellcheck](https://www.shellcheck.net/)

## Setup

1. Clone this repository into a directory of your choice. I recommend using the [`XDG_CONFIG_HOME`
directory](https://wiki.archlinux.org/title/XDG_Base_Directory#User_directories). (`$HOME/.config`)

   ```sh
   cd "${XDG_CONFIG_HOME:-$HOME/.config}"
   git clone https://github.com/Nightfirecat/dotfiles.git
   ```

2. Run `setup.sh`

   ```sh
   "${XDG_CONFIG_HOME:-$HOME/.config}"/dotfiles/setup.sh
   ```

Once completed, all necessary symlinks will be created for environment setup. Restart your login for the `.bash_profile`
to take effect.

## Uninstall

Run `setup.sh --remove` to clear any symlinks created by the setup process.
