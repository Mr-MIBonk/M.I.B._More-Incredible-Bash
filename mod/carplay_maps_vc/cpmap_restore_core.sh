#!/bin/ksh

if [ -n "${CPMAP_TEST_ROOT:-}" ] && [ -d "$CPMAP_TEST_ROOT/mnt/app" ] && [ -s "$CPMAP_TEST_ROOT/ifs/lsd.jxe" ]; then
    MMX="$CPMAP_TEST_ROOT"
elif [ -d /mnt/app ] && [ -s /ifs/lsd.jxe ]; then
    MMX=""
elif [ -d /net/mmx/mnt/app ] && [ -s /net/mmx/ifs/lsd.jxe ]; then
    MMX="/net/mmx"
else
    echo "CPMAP_RESTORE_FAIL=MMX_FILESYSTEM_NOT_FOUND"
    exit 1
fi

APP="$MMX/mnt/app"
ROOT="$APP/carplaymaps"
DIO="$APP/eso/bin/apps/dio_manager"
LSD="$APP/eso/hmi/lsd/lsd.sh"
JAR="$APP/eso/hmi/lsd/jars/CarPlayClusterControls.jar"

[ -s "$ROOT/stock_first/dio_manager.real" ] || { echo "CPMAP_RESTORE_FAIL=STOCK_MISSING"; exit 1; }
[ -s "$ROOT/rollback/lsd.sh" ] || { echo "CPMAP_RESTORE_FAIL=LSD_BACKUP_MISSING"; exit 1; }

if [ -n "${CPMAP_TEST_ROOT:-}" ]; then
    :
elif [ -n "$MMX" ]; then
    on -f mmx mount -uw /mnt/app >/dev/null 2>&1 || exit 1
    on -f mmx slay -f cpmap-guard >/dev/null 2>&1 || true
    on -f mmx slay -f carplay-cluster-supervisor >/dev/null 2>&1 || true
    on -f mmx slay -f altscreen-most-bridge >/dev/null 2>&1 || true
    on -f mmx slay -f carplay-pairing-helper >/dev/null 2>&1 || true
else
    mount -uw /mnt/app >/dev/null 2>&1 || exit 1
    slay -f cpmap-guard >/dev/null 2>&1 || true
    slay -f carplay-cluster-supervisor >/dev/null 2>&1 || true
    slay -f altscreen-most-bridge >/dev/null 2>&1 || true
    slay -f carplay-pairing-helper >/dev/null 2>&1 || true
fi

cp "$ROOT/stock_first/dio_manager.real" "$DIO.restore" || exit 1
cp "$ROOT/rollback/lsd.sh" "$LSD.restore" || exit 1
chmod 755 "$DIO.restore" "$LSD.restore"
mv "$DIO.restore" "$DIO" || exit 1
mv "$LSD.restore" "$LSD" || exit 1

if [ -s "$ROOT/rollback/CarPlayClusterControls.jar" ]; then
    cp "$ROOT/rollback/CarPlayClusterControls.jar" "$JAR.restore" || exit 1
    chmod 644 "$JAR.restore"
    mv "$JAR.restore" "$JAR" || exit 1
elif [ -e "$ROOT/rollback/JAR_ABSENT" ]; then
    rm -f "$JAR"
fi

rm -rf "$ROOT"
sync 2>/dev/null || true
echo "CPMAP_RESTORE_OK"
echo "A full unit reboot is required."
exit 0
