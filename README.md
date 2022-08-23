# Linux Mint Customization Script
[![Build State](https://github.com/tiliavir/dotfiles/workflows/Shellcheck/badge.svg)](https://github.com/Tiliavir/mvw-creator/actions)

This script documents my Linux Mint Cinnamon 21 "Vanessa" setup.

This follows my preferences, therefore I do not recommend using this script as
is - you should most probably fork and adjust it according to your needs!

## Execution
```shell script
bash -c "$(curl -fsSL https://raw.github.com/tiliavir/dotfiles/main/setup.sh)"
```

Alternatively you can clone this repository and run it locally.

*If you do that, consider adjusting the $TDF variable!*

## What will it do? 
- remove OOB software that I do not need / want
- install software, that I consider useful
- link my dotfiles
- checkout git repositories I need
- use my keyboard binding adjustments (mostly necessary to keep my IntelliJ Idea binding)
- set my theme adjustments
- remind me to do additional stuff that was not automized here
