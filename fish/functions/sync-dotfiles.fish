function sync-dotfiles
    echo "🔄 Actualizando copias locales..."
    # Copia y sobreescribe las versiones anteriores en mis-dotfiles
    cp -r ~/.config/hypr ~/mis-dotfiles/
    cp -r ~/.config/fish ~/mis-dotfiles/
    cp -r ~/.config/caelestia ~/mis-dotfiles/

    echo "📦 Subiendo a GitHub..."
    # Cambia al directorio, sube los cambios y regresa al directorio anterior
    cd ~/mis-dotfiles
    git add .
    git commit -m "Actualización automática: "(date "+%Y-%m-%d %H:%M")
    git push
    cd -
    
    echo "✅ ¡Tus dotfiles están actualizados en la nube!"
end
