# My dotfiles

## Requirements

- ansible
- [afx](https://github.com/babarot/afx)
- [chezmoi](https://github.com/twpayne/chezmoi)

## Install

```
sudo apt update
sudo apt install -y ansible git

sudo ansible-pull -U https://github.com/ayato-p/dotfiles.git ansible.yaml
```