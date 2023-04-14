#!/usr/bin/zsh
export Z_PROFILE_SOURCED=1
export PATH="/home/nex/.local/share/JetBrains/Toolbox/scripts:$PATH"

if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
    # Wayland compatability through env vars where possible.
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM="wayland;xcb"
fi
