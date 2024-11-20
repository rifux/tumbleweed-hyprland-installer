#!/bin/bash

#
# Copyright (C) 2024 Vladimir `rifux` Blinkov
#
# SPDX-License-Identifier: MIT
#

set -e
t="$HOME/.cache/tumbleweed-hyprland-installer"
c="$HOME/.config/"

_log() {
    echo -e "\n$1"
}

_cleanup() {
    if [ -d $t ]; then
        sudo rm -rf "$t"
    fi

    for path in ags anyrun fish/auto-Hypr.fish fish/config.fish fish/fish_variables fontconfig foot fuzzel hypr mpv qt5ct wlogout zshrc.d chrome-flags.conf code-flags.conf starship.toml thorium-flags.conf; do
        if [ -e "$t/$path" ]; then
            sudo rm -rf "$t/$path"
        fi
    done
}

_install_deps() {
    _log "[ i ] Installing dependencies from Tumbleweed repo"
    sudo zypper in axel blueprint-compiler bluez bluez-auto-enable-devices bluez-cups bluez-firmware brightnessctl cairomm-devel cairomm1_0-devel cargo cmake coreutils curl ddcutil file-devel fish fontconfig foot fuzzel gammastep gdouros-symbola-fonts gjs gjs-devel gnome-bluetooth gnome-bluetooth gnome-bluetooth gnome-control-center gnome-keyring gobject-introspection gobject-introspection-devel gojq grim gtk-layer-shell-devel gtk3 gtk3-metatheme-adwaita gtk4-devel gtkmm3-devel gtksourceview-devel gtksourceviewmm-devel gtksourceviewmm3_0-devel hypridle hyprland hyprlang-devel hyprwayland-scanner jetbrains-mono-fonts kernel-firmware-bluetooth lato-fonts libadwaita-devel libcairomm-1_0-1 libcairomm-1_16-1 libdbusmenu-gtk3-4 libdbusmenu-gtk3-devel libdbusmenu-gtk4 libdrm-devel libgbm-devel libgnome-bluetooth-3_0-13 libgtksourceview-3_0-1 libgtksourceviewmm-3_0-0 libgtksourceviewmm-4_0-0 libpulse-devel libqt5-qtwayland libsass-3_6_6-1 libsass-devel libsoup-devel libtinyxml0 libtinyxml2-10 libwebp-devel libxdp-devel Mesa-libGLESv2-devel Mesa-libGLESv3-devel meson NetworkManager npm opi pam-devel pavucontrol playerctl polkit-gnome python-base python3-anyascii python3-base python3-build python3-gobject-devel python3-libsass python3-material-color-utilities-python python3-Pillow python3-pip python3-psutil python3-pywayland python3-regex python3-setuptools_scm python3-svglib python3-wheel qt5ct qt6-wayland ripgrep rsync scdoc slurp starship swappy swww systemd-devel tesseract tesseract-data tinyxml-devel tinyxml2-devel typelib-1_0-Xdp-1_0 typelib-1_0-XdpGtk3-1_0 typelib-1_0-XdpGtk4-1_0 typescript unzip upower wayland-protocols-devel webp-pixbuf-loader wf-recorder wget wireplumber wl-clipboard wl-clipboard xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-utils xrandr

    _log "[ i ] Installing dependencies from opi"
    _log "[ ! ] Select 'yad' and then 'multimedia_proaudio' or 'Dead_Mozay' repo"
    read -p "[ ? ] Press 'Enter' to install 'yad' from opi."
    opi yad

    _log "[ i ] Installing dependencies from Python"
    pip3 install pywal https://github.com/T-Dynamos/materialyoucolor-python/archive/master.zip --break-system-packages
}

_fetch_configs() {
    _log "[ i ] Fetching configs"
    cd $t
    git clone https://github.com/end-4/dots-hyprland && \
        cd dots-hyprland && \
        cp -r {.config,.local} "$HOME/"
}

_fetch_fonts() {
    _log "[ i ] Fetching fonts"
    cd $t
    git clone https://codeberg.org/rifux/end4-fonts
    sudo cp -r end4-fonts /usr/local/share/fonts
}

#_fetch_cursor() {# WIP}

_install_cliphist() {
    _log "[ i ] Installing cliphist"
    cd $t
    wget https://github.com/sentriz/cliphist/releases/download/v0.6.1/v0.6.1-linux-amd64 -O cliphist && \
        chmod +x cliphist && \
        sudo cp -v cliphist /usr/local/bin/cliphist
}

_install_ydotool() {
    _log "[ i ] Installing ydotool"
    cd $t
    git clone https://github.com/ReimuNotMoe/ydotool && \
        cd ydotool
    mkdir build && cd build
    cmake -DSYSTEMD_USER_SERVICE=OFF -DSYSTEMD_SYSTEM_SERVICE=ON ..
    make -j `nproc`
    sudo make install
    sudo chmod +s $(which ydotool)
    sudo systemctl daemon-reload
    sudo systemctl enable ydotoold
    sudo systemctl start ydotoold
    ln -sf /tmp/.ydotool_socket /run/user/$(id -u $(whoami))/.ydotool_socket
}

_install_hyprutils() {
    _log "[ i ] Installing hyprutils"
    cd $t
    git clone https://github.com/hyprwm/hyprutils.git && \
        cd hyprutils/
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    sudo cmake --install build
}

_install_hyprpicker() {
    _log "[ i ] Installing hyprpicker"
    cd $t
    git clone https://github.com/hyprwm/hyprpicker.git && \
        cd hyprpicker
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
    cmake --build ./build --config Release --target hyprpicker -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    sudo cmake --install ./build
}

_install_dartsass() {
    _log "[ i ] Installing dart-sass"
    cd $t
    wget https://github.com/sass/dart-sass/releases/download/1.80.6/dart-sass-1.80.6-linux-x64.tar.gz
    tar -xzf dart-sass-1.80.6-linux-x64.tar.gz
    cd dart-sass
    sudo cp -rf * /usr/local/bin/
}

_install_sdbus_cpp() {
    _log "[ i ] Installing sdbus-cpp"
    cd $t
    git clone https://github.com/Kistler-Group/sdbus-cpp.git
    cd sdbus-cpp
    cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build
    cmake --build ./build -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    sudo cmake --build ./build --target install
}

_install_hyprlock() {
    _install_sdbus_cpp
    _log "[ i ] Installing hyprlock"
    cd $t
    git clone https://github.com/hyprwm/hyprlock.git
    cd hyprlock
    cmake --no-warn-unused-cli -DCMAKE_CXX_FLAGS="-L/usr/local/lib64 -lsdbus-c++" -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build
    cmake --build ./build --config Release --target hyprlock -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    sudo cmake --install build
}

_install_wlogout() {
    _log "[ i ] Installing wlogout"
    cd $t
    git clone https://github.com/ArtsyMacaw/wlogout.git
    cd wlogout
    meson build
    ninja -C build
    sudo ninja -C build install
}

_install_anyrun() {
    _log "[ i ] Installing anyrun"
    cd $t
    git clone https://github.com/Kirottu/anyrun.git
    cd anyrun
    cargo build --release
    cargo install --path anyrun/
    sudo cp $HOME/.cargo/bin/anyrun /usr/local/bin/
    mkdir -p ~/.config/anyrun/plugins
    cp target/release/*.so ~/.config/anyrun/plugins
    cp examples/config.ron ~/.config/anyrun/config.ron
}

_install_gradience() {
    _log "[ i ] Installing gradience"
    cd $t
    git clone https://github.com/GradienceTeam/Gradience.git
    cd Gradience
    git submodule update --init --recursive
    meson setup builddir
    meson configure builddir -Dprefix=/usr/local
    sudo ninja -C builddir install
}

_exec_manualinstaller() {
    _log "[ ! ] Now manual installer of end-4/dots will be started."
    read -p "[ ? ] Press 'Enter' to continue"
    cd $t
    cd dots-hyprland
    ./manual-install-helper.sh
}

#_fix_shadows() {# WIP}

_program() {
    _cleanup
    mkdir -p $t
    _install_deps
    _fetch_configs
    _fetch_fonts
    #_fetch_cursor   # Work in progress
    _install_cliphist
    _install_ydotool
    _install_dartsass
    _install_hyprutils
    _install_hyprpicker
    _install_hyprlock
    _install_wlogout
    _install_anyrun
    _install_gradience
    _exec_manualinstaller
    #_fix_shadows    # Work in progress
}

_program
