#!/usr/bin/env bash

echo "Updating dotfiles..."

rm ./configuration.nix
echo "Removed ./configuration.nix"
rm ./home.nix
echo "Removed ./home.nix"
rm -rf ./dotfiles
echo "Removed dotfiles"
rm -rf ./devices
echo "Removed devices"
rm -rf ./environments
echo "Removed environments"
rm -rf ./packages
echo "Removed packages"

cp /etc/nixos/configuration.nix ./
echo "Updated configuration.nix"
cp /etc/nixos/home.nix ./
echo "Updated home.nix"
cp -r /etc/nixos/dotfiles ./
echo "Updated dotfiles"
cp -r /etc/nixos/devices ./
echo "Updated devices"
cp -r /etc/nixos/environments ./
echo "Updated environments"
cp -r /etc/nixos/packages ./
echo "Updated packages"

../haoxiangliew/./commit.sh

echo
echo "All done!"
