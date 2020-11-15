# nixos
Welcome to my NixOS configuration!

![alt text](https://github.com/haoxiangliew/nixos/blob/main/nixos.jpg?raw=true)

|           |                  |
|-----------|------------------|
| Shell:    | fish             |
|-----------|                  |
| DM:       | lightdm          |
|-----------|                  |
| WM:       | xmonad + xmobar  |
|-----------|                  |
| Editor:   | doom emacs / vim |
|-----------|                  |
| Term:     | alacritty        |
|-----------|                  |
| Launcher: | dmenu            |
|-----------|                  |
| Browser:  | firefox          |
|-----------|                  |
| GTK:      | one dark         |
|-----------|                  |


## Installation
1. Boot into `nixos-minimal`
2. To manually configure the wifi on the minimal installer, run 
```
wpa_supplicant -B -i interface -c <(wpa_passphrase 'SSID' 'key')
```
3. Set partitions (example uses parted)
```
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 3 esp on
```
4. Format partitions
```
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
```
5. Mount partitions
```
mount /dev/sda1 /mnt
mkdir /mnt/boot
mount /dev/sda3 /mnt/boot
swapon /dev/sda2
```
6. Generate and edit the default configuration.nix
```
nixos-generate-config --root /mnt

vim /mnt/etc/nixos/configuration.nix

environment.systemPackages = with pkgs; [
  ...
  git
];
```
7. Install NixOS and reboot
```
nixos-install

reboot
```
8. Login as `root`, `git clone` this repository and `nixos-rebuild switch`
9. Configure as you like!
