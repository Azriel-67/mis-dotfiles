function postgame
    echo "===================================================================="
    echo "  RESTAURADOR POST-GAME ADB - MODO DIARIO (FISH SHELL)               "
    echo "===================================================================="
    
    set -l GAME_PKG "com.mobile.legends"
    
    adb shell am force-stop $GAME_PKG
    adb shell settings put global window_animation_scale 1.0
    adb shell settings put global transition_animation_scale 1.0
    adb shell settings put global animator_duration_scale 1.0
    adb shell dumpsys deviceidle whitelist -$GAME_PKG >/dev/null 2>&1
    adb shell am set-standby-bucket $GAME_PKG working_set >/dev/null 2>&1
    
    echo ">> Estado del teléfono restaurado a modo diario (Animaciones a 1.0)."
end
