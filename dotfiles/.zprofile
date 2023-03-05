#!/usr/bin/bash
export Z_PROFILE_SOURCED=1

if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM="wayland;xcb"
fi
