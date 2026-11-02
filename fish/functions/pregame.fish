function pregame
    set -l APPLY_CHANGES 0
    if test (count $argv) -gt 0; and test "$argv[1]" = "--apply"
        set APPLY_CHANGES 1
    end
    
    echo "===================================================================="
    echo "  OPTIMIZADOR COMPLETO LOBBY + JUEGO - MOBILE LEGENDS (FISH SHELL)  "
    echo "===================================================================="
    
    if not command -v adb >/dev/null 2>&1
        echo "ERROR: El comando 'adb' no está instalado."
        return 1
    end
    
    set -l GAME_PKG "com.mobile.legends"
    
    if test $APPLY_CHANGES -eq 0
        echo ">> Modo simulación (--dry-run). Para aplicar cambios ejecuta: pregame --apply"
        return 0
    end
    
    echo ">> Aplicando optimizaciones completas..."
    
    # 1. Cierre de aplicaciones de usuario en segundo plano
    set -l USER_APPS_TO_STOP \
                "com.facebook.katana" \
                "com.instagram.android" \
                "com.ss.android.ugc.trill" \
                "com.whatsapp" \
                "com.twitter.android"
    
    for pkg in $USER_APPS_TO_STOP
        if test -n "(adb shell pm list packages $pkg)"
            adb shell am force-stop $pkg
        end
    end
    
    # 2. Ajustes de prioridad, exención y animaciones a 0.5
    adb shell am set-standby-bucket $GAME_PKG active
    adb shell dumpsys deviceidle whitelist +$GAME_PKG >/dev/null 2>&1
    adb shell settings put global window_animation_scale 0.5
    adb shell settings put global transition_animation_scale 0.5
    adb shell settings put global animator_duration_scale 0.5
    adb shell pm trim-caches 2000M >/dev/null 2>&1
    
    # 3. Compilación AOT nativa (WebView + Juego)
    echo ">> Compilando motor WebView y Mobile Legends a código nativo..."
    adb shell cmd package compile -m speed com.google.android.webview
    adb shell cmd package compile -m speed -f $GAME_PKG
    
    echo ">> Optimizaciones completas aplicadas con éxito."
end
