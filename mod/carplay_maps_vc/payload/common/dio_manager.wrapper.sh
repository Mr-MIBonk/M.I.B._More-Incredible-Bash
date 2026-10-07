#!/bin/sh

ROOT=/mnt/app/carplaymaps
REAL="$ROOT/stock_first/dio_manager.real"
CORE="$ROOT/core.so"
SEC="$ROOT/libcarplay-security-bridge.so"
PAIR_ROOT="$ROOT/security_bridge"
PAIR_HELPER="$PAIR_ROOT/carplay-pairing-helper"
PAIR_CORE="$PAIR_ROOT/libCarPlayPairingCore.so"
SUPERVISOR="$ROOT/carplay-cluster-supervisor"
BRIDGE="$ROOT/altscreen-most-bridge"
LOG=/ramdisk/carplaymaps-launcher.log
PIDFILE=/ramdisk/carplay-dio-manager.pid

log_line() {
    echo "$1" >> "$LOG" 2>/dev/null || true
}

if test ! -x "$REAL" || test ! -r "$CORE"; then
    log_line "fatal=runtime-missing"
    exit 127
fi

export IPL_CONFIG_DIR=/etc/eso/production
export IPL_CONFIG_DIR_DIO_MANAGER=/etc/eso/production
export PATH=/proc/boot:/sbin:/bin:/usr/bin:/usr/sbin:/armle/usr/bin:/armle/usr/sbin:/armle/sbin:/armle/bin
export LD_LIBRARY_PATH=/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
export CARPLAY_ALTSCREEN_ENABLE=1
export CARPLAY_ALTSCREEN_LOG=/ramdisk/carplaymaps-video.log
export CARPLAY_ALTSCREEN_CAPTURE_DIR=/ramdisk
unset CARPLAY_CLUSTER_INTRO
unset CARPLAY_CLUSTER_INTRO_FPS

echo $$ > "$PIDFILE" 2>/dev/null || true

if test -x "$SUPERVISOR" && test -x "$BRIDGE"; then
    (
        unset LD_PRELOAD
        "$SUPERVISOR" >/dev/null 2>&1
    ) &
    log_line "cluster-supervisor=start-requested"
fi

PRELOAD="$CORE"
if test -r "$SEC"; then
    PRELOAD="$CORE:$SEC"
    export CARPLAY_SECURITY_BRIDGE_LOG=/ramdisk/carplay-maps-session.log
    if test -x "$PAIR_HELPER" && test -r "$PAIR_CORE"; then
        (
            unset LD_PRELOAD
            export LD_LIBRARY_PATH="$PAIR_ROOT:$LD_LIBRARY_PATH"
            export CARPLAY_PAIRING_STORE="$PAIR_ROOT"
            "$PAIR_HELPER" --server >/dev/null 2>&1
        ) &
        log_line "pairing-helper=start-requested"
    fi
fi

export LD_PRELOAD="$PRELOAD"
log_line "launch=carplay-maps-video-only"
exec "$REAL" "$@"

log_line "fatal=dio-manager-exec-failed"
exit 126
