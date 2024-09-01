# Dotfiles

⚠️ **WARNING: This project is under construction and may contain instabilities.** ⚠️

This repository contains my personal dotfiles and config scripts to quickly set up a new development environment.

## Overview

This project includes configs for:

- Zsh (with Oh My Zsh and Powerlevel10k)
- Neovim
- Visual Studio Code
- Git
- WezTerm
- Various other tools and utilities

## Prerequisites

- Unix-based operating system (tested on Ubuntu 20.04+)
- Git
- Curl

## Installation

1. Clone this repository:

```bash
git clone https://github.com/felipepimentel/dotfiles.git ~/.dotfiles
```

2. Execute the installation script:

```bash
cd ~/.dotfiles
bash scripts/install.sh
```

3. Follow the installation script's instructions to set up your development environment.

## config

The installation script uses the `dotfiles_config.yml` file to get user-specific configs. You can edit this file to customize the configs according to your needs.

## Installation Scripts

The `scripts` directory contains installation scripts for various tools and utilities. You can run these scripts individually to install only the tools you need.

## Contribution

Contributions are welcome! If you find any issues or have any suggestions for improvement, open an issue or send a pull request.

## License

This project is licensed under the MIT License.

## Project Status

This project is currently under active development. Some features may not be fully implemented or may change in the future. Use at your own risk and always back up your important data before using these scripts.