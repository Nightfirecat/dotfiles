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
   git clone https://git.nightfirec.at/nightfirecat/dotfiles.git
   ```

2. Run `setup.sh`

   ```sh
   "${XDG_CONFIG_HOME:-$HOME/.config}"/dotfiles/setup.sh
   ```

Once completed, all necessary symlinks will be created for environment setup. Restart your login for the `.bash_profile`
to take effect.

## Post-setup

There are a few optional files which can be created in the home directory after setup is complete which can aid in
environment setup:

* **`.user.gitconfig`**: This is primarily used as a way to set up GPG commit signing [(as shown in
  `.user.gitconfig.dist`)](./.user.gitconfig.dist), but can also be used to change the git user name or email on systems
  which should use something besides your personal details. (eg. work email on a work machine)
* **`.bash_profile.after`** and **`.bashrc.after`**: These files can be created to run following completion of
  `.bash_profile` and `.bashrc`, respectively. This is primarily useful for overriding environment variables pointing to
  paths of binaries, or adjust aliases which don't work in environments with varying coreutils support for convenience
  flags.

## Uninstall

Run `setup.sh --remove` to clear any symlinks created by the setup process.
