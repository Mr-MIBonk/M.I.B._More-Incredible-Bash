#!/bin/ksh

find_cpmap_payload() {
    for medium in /fs/sda0 /fs/sdb0 /net/mmx/fs/sda0 /net/mmx/fs/sdb0 /media/mp000 /media/mp001 /media/mp002; do
        candidate="$medium/mod/carplay_maps_vc/payload"
        if [ -s "$candidate/common/install-carplay-maps.sh" ]; then
            CPMAP_PAYLOAD="$candidate"
            export CPMAP_PAYLOAD
            return 0
        fi
    done
    echo "FAIL: mod/carplay_maps_vc/payload was not found on SD media"
    return 1
}

detect_cpmap_mu() {
    if [ -s /ifs/lsd.jxe ]; then
        jxe=/ifs/lsd.jxe
    elif [ -s /net/mmx/ifs/lsd.jxe ]; then
        jxe=/net/mmx/ifs/lsd.jxe
    else
        echo "FAIL: /ifs/lsd.jxe was not found"
        return 1
    fi
    line=`ls -ln "$jxe" 2>/dev/null` || return 1
    set -- $line
    case "$5" in
        55915411) CPMAP_MU="MU1102" ;;
        55840541) CPMAP_MU="MU1367" ;;
        55840933) CPMAP_MU="MU1440" ;;
        55712574) CPMAP_MU="MU1447" ;;
        *) echo "FAIL: unsupported lsd.jxe size $5"; return 1 ;;
    esac
    export CPMAP_MU
    return 0
}
