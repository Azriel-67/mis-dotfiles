#!/bin/bash
echo "Instalando paquetes base..."
sudo pacman -S --needed git hyprland fish 

echo "Copiando dotfiles a ~/.config/..."
cp -r hypr ~/.config/
cp -r fish ~/.config/
cp -r caelestia ~/.config/

echo "Configurando Fish como shell predeterminada..."
chsh -s $(which fish)

echo "¡Listo! Cierra sesión y entra a Hyprland."
