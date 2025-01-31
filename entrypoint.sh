#!/bin/bash

# Remove X1 lock file if it exists
remove_x1_lock() {
    if [ -f /tmp/.X1-lock ]; then 
        rm /tmp/.X1-lock 
    fi
}

# Start Xvfb
start_xvfb() {
    export DISPLAY=:1 
    Xvfb :1 -ac -screen 0 1920x1080x24 & 
    sleep 5 
}

# Set permissions for /dev/pts/0
set_terminal_permissions() {
    chmod a+rw /dev/pts/0
}

# Start Steam as user
start_steam() {
    #runuser -u root -- xterm -maximized &
    runuser -u steam -- steam & 
}

# Start x11vnc
start_x11vnc() {
    x11vnc -display :1 -nopw -listen localhost -xkb -ncache_cr -forever & 
}

# Create symlink for noVNC
create_novnc_symlink() {
    if [ ! -e /usr/share/novnc/index.html ]; then 
        ln -s /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html 
    fi
}

# Start noVNC proxy
start_novnc_proxy() {
    /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 
}

# Main script execution
main() {
    remove_x1_lock
    start_xvfb
    set_terminal_permissions
    start_steam
    start_x11vnc
    create_novnc_symlink
    start_novnc_proxy    
}

# Call main
main