- [[nixos](https://git.sr.ht/~haoxiangliew/nixos)](#orgf7a54fb)
  - [Installation](#org8d45ba5)



<a id="orgf7a54fb"></a>

# [nixos](https://git.sr.ht/~haoxiangliew/nixos)

Welcome to my NixOS configuration!

|              |                                                                   |
|------------ |----------------------------------------------------------------- |
| Shell        | fish                                                              |
| Environments | lightdm + i3-gaps                                                 |
| Editors      | [emacs](https://git.sr.ht/~haoxiangliew/.emacs.d), vscode, neovim |
| Term         | kitty                                                             |
| Theme        | dracula                                                           |

Most of the [dotfiles](https://git.sr.ht/~haoxiangliew/nixos/tree/master/item/dotfiles) found in other configurations are managed by home-manager in this nixos configuration, except for emacs

Configuration is daily-driven and maintained on nixos-unstable


<a id="org8d45ba5"></a>

## Installation

-   Boot into the latest [nixos-unstable](https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso)
-   To simply configure the wifi with wpa-supplicant

```sh
wpa_supplicant -B -i interface -c <(wpa_passphrase 'SSID' 'key')
```

-   Set partitions (we use parted here)

```sh
parted /dev/sda  -- unit MiB
parted /dev/sda  -- mklabel gpt
parted /dev/sda1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda2 -- mkpart primary ext4 512MiB -8GiB # (if u want swap)
parted /dev/sda3 -- mkpart swap linux-swap -8GiB 100%
parted /dev/sda  -- set 1 esp on

# with btrfs & luks

# create partitions with parted
cryptsetup --verify-passphrase -v luksFormat /dev/sda2
cryptsetup open /dev/sda2 enc
```

-   Format partitions

```sh
mkfs.vfat -n boot /dev/sda1
mkfs.ext4 -L primary /dev/sda2
mkswap -L swap /dev/sda3

# with btrfs & luks

mkfs.vfat -n boot /dev/sda1
mkfs.btrfs /dev/mapper/enc
```

-   Mount partitions

```sh
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda3

# with btrfs & luks

mount -t btrfs /dev/mapper/enc /mnt
btrfs subvolume create /mnt/root
umount /mnt

mount -o subvol=root,compress=zstd,noatime /dev/mapper/enc /mnt

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

-   Generate and edit the default `configuration.nix`

```sh
nixos-generate-config --root /mnt

vim /mnt/etc/nixos/configuration.nix
```

```nix
environment.systemPackages = with pkgs; [
  ...
  git
];
```

```sh
# with btrfs & luks

vim /mnt/etc/nixos/configuration.nix
```

```nix
fileSystems."/" =
  { device = "/dev/disk/by-uuid/<uuid>";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ]; # changes on this line
  };
```

-   Install NixOS and reboot

    ```sh
    nixos-install

    reboot
    ```
-   Login as `root`, `git clone` this repository, `passwd` your username, and `nixos-rebuild switch`
-   Configure as you like