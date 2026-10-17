#!/bin/ksh

PAYLOAD="$1"
EXPECTED_MU="$2"
INSTRUMENT="$3"
VERSION="V70-PLAINTEXT-TOOLBOX-1.1.0"

if ! command -v awk >/dev/null 2>&1; then
    AWK="${PAYLOAD%/mod/carplay_maps_vc/payload}/apps/sbin/awk"
else
    AWK="awk"
fi

fail() {
    echo "CPMAP_INSTALL_FAIL=$1"
    exit 1
}

if [ -z "$PAYLOAD" ] || [ -z "$EXPECTED_MU" ] || [ -z "$INSTRUMENT" ]; then
    fail "INVALID_ARGUMENTS"
fi

case "$EXPECTED_MU:$INSTRUMENT" in
    MU1102:791|MU1102:790|MU1367:791|MU1367:790|MU1440:790|MU1447:790) ;;
    *) fail "UNSUPPORTED_PROFILE" ;;
esac

if [ -n "${CPMAP_TEST_ROOT:-}" ] && [ -s "$CPMAP_TEST_ROOT/ifs/lsd.jxe" ] && [ -d "$CPMAP_TEST_ROOT/mnt/app" ]; then
    MMX="$CPMAP_TEST_ROOT"
elif [ -s /ifs/lsd.jxe ] && [ -d /mnt/app ]; then
    MMX=""
elif [ -s /net/mmx/ifs/lsd.jxe ] && [ -d /net/mmx/mnt/app ]; then
    MMX="/net/mmx"
else
    fail "MMX_FILESYSTEM_NOT_FOUND"
fi

APP="$MMX/mnt/app"
JXE="$MMX/ifs/lsd.jxe"
DIO="$APP/eso/bin/apps/dio_manager"
LSD="$APP/eso/hmi/lsd/lsd.sh"
JARS="$APP/eso/hmi/lsd/jars"
ROOT="$APP/carplaymaps"
NEW="$APP/.carplaymaps-new-$$"
OLD="$APP/.carplaymaps-old-$$"
STAGE="$MMX/ramdisk/.cpmap-plaintext-stage-$$"
[ -n "$MMX" ] || STAGE="/ramdisk/.cpmap-plaintext-stage-$$"

if [ ! -s "$JXE" ] || [ ! -s "$DIO" ] || [ ! -s "$LSD" ]; then
    fail "REQUIRED_FACTORY_FILE_MISSING"
fi
if [ -z "${CPMAP_TEST_ROOT:-}" ] && [ ! -x "$DIO" ]; then
    fail "DIO_MANAGER_NOT_EXECUTABLE"
fi

line=`ls -ln "$JXE" 2>/dev/null` || fail "JXE_STAT_FAILED"
set -- $line
JXE_SIZE="$5"
case "$JXE_SIZE" in
    55915411) DETECTED_MU="MU1102" ;;
    55840541) DETECTED_MU="MU1367" ;;
    55840933) DETECTED_MU="MU1440" ;;
    55712574) DETECTED_MU="MU1447" ;;
    *) fail "UNSUPPORTED_JXE_SIZE_$JXE_SIZE" ;;
esac

if [ "$DETECTED_MU" != "$EXPECTED_MU" ]; then
    fail "PROFILE_MISMATCH_${DETECTED_MU}_EXPECTED_${EXPECTED_MU}"
fi
if [ "$DETECTED_MU" = "MU1440" ] && [ "$INSTRUMENT" != "790" ]; then
    fail "MU1440_REQUIRES_790"
elif [ "$DETECTED_MU" = "MU1447" ] && [ "$INSTRUMENT" != "790" ]; then
    fail "MU1447_REQUIRES_790"
fi

CORE="$PAYLOAD/profiles/$EXPECTED_MU/$INSTRUMENT/core.so"
WRAPPER="$PAYLOAD/common/dio_manager.wrapper.sh"
CONTROL_JAR="$PAYLOAD/common/CarPlayClusterControls.jar"
if [ "$EXPECTED_MU" = "MU1440" ] && [ -s "$PAYLOAD/common/CarPlayClusterControls_MU1440.jar" ]; then
    CONTROL_JAR="$PAYLOAD/common/CarPlayClusterControls_MU1440.jar"
fi
NAV_JAR="$PAYLOAD/common/CarPlayNavigationPatch.jar"
NAV_TARGET="$JARS/CarPlayNavigationPatch.jar"
BRIDGE="$PAYLOAD/common/altscreen-most-bridge"
SUPERVISOR="$PAYLOAD/common/carplay-cluster-supervisor"
SEC="$PAYLOAD/common/libcarplay-security-bridge.so"
PAIR_HELPER="$PAYLOAD/common/carplay-pairing-helper"
PAIR_CORE="$PAYLOAD/common/libCarPlayPairingCore.so"

for required in "$CORE" "$WRAPPER" "$CONTROL_JAR" "$NAV_JAR" "$BRIDGE" "$SUPERVISOR" "$SEC" "$PAIR_HELPER" "$PAIR_CORE"; do
    [ -s "$required" ] || fail "PAYLOAD_MISSING_`basename "$required"`"
done

# ZIP central-directory entry names are plaintext even for compressed classes.
# Check the seven navigation-ignore classes, not just the JAR filename. This
# also recognizes a navigation patch merged with another user's metadata JAR.
has_navigation_patch() {
    [ -s "$1" ] || return 1
    local found_any=0
    
    for nav_class in \
        de/esolutions/fw/comm/dsi/carplay/impl/DSICarplayProxy.class \
        de/esolutions/fw/dsi/androidauto2/DSIAndroidAuto2Dispatcher.class \
        de/esolutions/fw/dsi/androidauto/DSIAndroidAutoDispatcher.class \
        de/vw/mib/asl/internal/androidauto/target/NavigationListener.class \
        de/vw/mib/asl/internal/androidauto/target/RequestHandler.class \
        de/vw/mib/asl/internal/carplay/common/CarPlayModeHandling.class \
        de/vw/mib/asl/internal/exboxm/api/impl/guidance/ExboxGuidanceManagerImpl.class; do
        
        if grep -q "$nav_class" "$1" 2>/dev/null; then
            echo "found: $nav_class"
            found_any=1
        fi
    done
    
    [ "$found_any" -eq 1 ] && return 1
    return 0
}

has_navigation_patch "$NAV_JAR" || fail "NAVIGATION_PAYLOAD_INVALID"
NAV_INSTALL=yes
NAV_EXISTING=""
BOOT_JARS=`$AWK '
    /^[ \t]*#/ { next }
    {
        line=$0
        while (match(line, /-Xbootclasspath\/p:[^" \t]+/)) {
            value=substr(line, RSTART+18, RLENGTH-18)
            gsub(/:/, " ", value)
            print value
            line=substr(line, RSTART+RLENGTH)
        }
    }
' "$LSD"`
NAV_CONFLICT=no
for boot_jar in $BOOT_JARS; do
    case "$boot_jar" in
        '$BASE_DIR/'*) boot_file="$APP/eso/hmi/${boot_jar#\$BASE_DIR/}" ;;
        '${BASE_DIR}/'*) boot_file="$APP/eso/hmi/${boot_jar#\$\{BASE_DIR\}/}" ;;
        /mnt/app/*) boot_file="$MMX$boot_jar" ;;
        *) continue ;;
    esac
    if has_navigation_patch "$boot_file"; then
        NAV_INSTALL=no
        NAV_EXISTING="$boot_jar"
        break
    fi
    if [ -s "$boot_file" ] && grep -q 'de/esolutions/fw/comm/dsi/carplay/impl/DSICarplayProxy.class' "$boot_file" 2>/dev/null; then
        NAV_CONFLICT=yes
    fi
done
if [ "$NAV_INSTALL" = yes ] && [ "$NAV_CONFLICT" = yes ]; then
    fail "CUSTOM_CARPLAY_PATCH_REQUIRES_REVIEW"
fi
if [ "$NAV_INSTALL" = no ]; then
    echo "CPMAP_NAVIGATION_PATCH=KEEP_EXISTING ($NAV_EXISTING)"
else
    echo "CPMAP_NAVIGATION_PATCH=INSTALL_MISSING"
fi

echo "CarPlay Maps VC"
echo "Free open-source project by omonob (QCDWJ)"
echo "Detected firmware: $DETECTED_MU (lsd.jxe $JXE_SIZE bytes)"
echo "Selected cluster: $INSTRUMENT"
echo "Scope: CarPlay map video and steering-wheel map controls only"
echo "No music metadata, navigation text, startup animation, device binding, or watchdog"

if [ -n "${CPMAP_TEST_ROOT:-}" ]; then
    :
elif [ -n "$MMX" ]; then
    on -f mmx mount -uw /mnt/app >/dev/null 2>&1 || fail "APP_REMOUNT_FAILED"
    on -f mmx slay -f cpmap-guard >/dev/null 2>&1 || true
    on -f mmx slay -f carplay-cluster-supervisor >/dev/null 2>&1 || true
    on -f mmx slay -f altscreen-most-bridge >/dev/null 2>&1 || true
    on -f mmx slay -f carplay-pairing-helper >/dev/null 2>&1 || true
else
    mount -uw /mnt/app >/dev/null 2>&1 || fail "APP_REMOUNT_FAILED"
    slay -f cpmap-guard >/dev/null 2>&1 || true
    slay -f carplay-cluster-supervisor >/dev/null 2>&1 || true
    slay -f altscreen-most-bridge >/dev/null 2>&1 || true
    slay -f carplay-pairing-helper >/dev/null 2>&1 || true
fi

rm -rf "$STAGE" "$NEW" "$OLD" 2>/dev/null
mkdir -p "$STAGE" "$NEW/stock_first" "$NEW/rollback" "$NEW/security_bridge" || fail "STAGE_CREATE_FAILED"
cp "$LSD" "$STAGE/lsd.sh.current" || fail "CURRENT_LSD_SNAPSHOT_FAILED"
cp "$DIO" "$STAGE/dio_manager.current" || fail "CURRENT_DIO_SNAPSHOT_FAILED"
if [ -s "$JARS/CarPlayClusterControls.jar" ]; then
    cp "$JARS/CarPlayClusterControls.jar" "$STAGE/control.current" || fail "CURRENT_CONTROL_SNAPSHOT_FAILED"
fi
if [ -s "$NAV_TARGET" ]; then
    cp "$NAV_TARGET" "$STAGE/nav.current" || fail "CURRENT_NAV_SNAPSHOT_FAILED"
fi

STOCK=""
for candidate in \
    "$ROOT/stock_first/dio_manager.real" \
    "$ROOT/rollback/dio_manager" \
    "$APP/carplaymaps-open/stock_first/dio_manager.real" \
    "$APP/carplaymaps-open/rollback/dio_manager" \
    "$APP/eso/bin/apps/dio_manager.stock"; do
    if [ -s "$candidate" ]; then
        size=`ls -ln "$candidate" 2>/dev/null`; set -- $size; size="$5"
        if [ "${size:-0}" -gt 500000 ] 2>/dev/null; then
            STOCK="$candidate"
            break
        fi
    fi
done
if [ -z "$STOCK" ]; then
    size=`ls -ln "$DIO" 2>/dev/null`; set -- $size; size="$5"
    if [ "${size:-0}" -gt 500000 ] 2>/dev/null; then
        STOCK="$DIO"
    fi
fi
[ -n "$STOCK" ] || fail "FACTORY_DIO_MANAGER_NOT_FOUND"

LSD_BASE="$LSD"
for candidate in "$ROOT/map_control_rollback/lsd.sh" "$ROOT/rollback/lsd.sh" "$APP/carplaymaps-open/rollback/lsd.sh"; do
    if [ -s "$candidate" ] && ! grep -q 'CarPlayClusterControls.jar' "$candidate" 2>/dev/null; then
        LSD_BASE="$candidate"
        break
    fi
done

cp "$STOCK" "$NEW/stock_first/dio_manager.real" || fail "STOCK_COPY_FAILED"
cp "$LSD_BASE" "$NEW/rollback/lsd.sh" || fail "LSD_BACKUP_FAILED"
if [ -e "$ROOT/rollback/JAR_ABSENT" ]; then
    touch "$NEW/rollback/JAR_ABSENT" || fail "JAR_ABSENT_MARK_FAILED"
elif [ -s "$ROOT/rollback/CarPlayClusterControls.jar" ]; then
    cp "$ROOT/rollback/CarPlayClusterControls.jar" "$NEW/rollback/CarPlayClusterControls.jar" || fail "JAR_BACKUP_FAILED"
elif [ -s "$JARS/CarPlayClusterControls.jar" ]; then
    cp "$JARS/CarPlayClusterControls.jar" "$NEW/rollback/CarPlayClusterControls.jar" || fail "JAR_BACKUP_FAILED"
else
    touch "$NEW/rollback/JAR_ABSENT" || fail "JAR_ABSENT_MARK_FAILED"
fi

if [ -e "$ROOT/rollback/NAV_JAR_ABSENT" ]; then
    touch "$NEW/rollback/NAV_JAR_ABSENT" || fail "NAV_ABSENT_MARK_FAILED"
elif [ -s "$ROOT/rollback/CarPlayNavigationPatch.jar" ]; then
    cp "$ROOT/rollback/CarPlayNavigationPatch.jar" "$NEW/rollback/CarPlayNavigationPatch.jar" || fail "NAV_BACKUP_FAILED"
elif [ -s "$NAV_TARGET" ]; then
    cp "$NAV_TARGET" "$NEW/rollback/CarPlayNavigationPatch.jar" || fail "NAV_BACKUP_FAILED"
else
    touch "$NEW/rollback/NAV_JAR_ABSENT" || fail "NAV_ABSENT_MARK_FAILED"
fi

COUNT=`grep -c 'CarPlayClusterControls.jar' "$LSD" 2>/dev/null`
[ "$COUNT" -le 1 ] || fail "DUPLICATE_CONTROL_JAR_REFERENCE"
ADD_CLASSPATH=""
[ "$COUNT" -eq 1 ] || ADD_CLASSPATH='$BASE_DIR/lsd/jars/CarPlayClusterControls.jar'
NAV_COUNT=`grep -c 'CarPlayNavigationPatch.jar' "$LSD" 2>/dev/null`
[ "$NAV_COUNT" -le 1 ] || fail "DUPLICATE_NAVIGATION_JAR_REFERENCE"
if [ "$NAV_INSTALL" = yes ] && [ "$NAV_COUNT" -eq 0 ]; then
    [ -z "$ADD_CLASSPATH" ] || ADD_CLASSPATH="$ADD_CLASSPATH:"
    ADD_CLASSPATH="$ADD_CLASSPATH"'$BASE_DIR/lsd/jars/CarPlayNavigationPatch.jar'
fi
if [ -z "$ADD_CLASSPATH" ]; then
    cp "$LSD" "$STAGE/lsd.sh.patched" || fail "LSD_STAGE_FAILED"
else
    # Extend the existing prepend option if present. Do not emit a second
    # -Xbootclasspath/p option: some J9 builds keep only its last occurrence.
    # On a stock script, add one line immediately before J9 instead.
    $AWK -v prepend="$ADD_CLASSPATH" '
        BEGIN { done=0 }
        {
            if (!done && $0 ~ /^[ \t]*BOOTCLASSPATH="\$BOOTCLASSPATH -Xbootclasspath\/p:/) {
                sub(/-Xbootclasspath\/p:/, "-Xbootclasspath/p:" prepend ":")
                done=1
            }
            if (!done && $0 ~ /^[ \t]*\$J9[ \t]/) {
                print "BOOTCLASSPATH=\"$BOOTCLASSPATH -Xbootclasspath/p:" prepend "\""
                done=1
            }
            print
        }
        END { if (!done) exit 9 }
    ' "$LSD" > "$STAGE/lsd.sh.patched" || fail "BOOTCLASSPATH_STRUCTURE_UNSUPPORTED"
fi

if [ -n "${CPMAP_TEST_ROOT:-}" ]; then
    /bin/sh -n "$STAGE/lsd.sh.patched" >/dev/null 2>&1 || fail "PATCHED_LSD_SYNTAX_FAILED"
else
    /bin/ksh -n "$STAGE/lsd.sh.patched" >/dev/null 2>&1 || fail "PATCHED_LSD_SYNTAX_FAILED"
fi

cp "$CORE" "$NEW/core.so" || fail "CORE_COPY_FAILED"
cp "$WRAPPER" "$NEW/dio_manager.wrapper.sh" || fail "WRAPPER_COPY_FAILED"
cp "$BRIDGE" "$NEW/altscreen-most-bridge" || fail "BRIDGE_COPY_FAILED"
cp "$SUPERVISOR" "$NEW/carplay-cluster-supervisor" || fail "SUPERVISOR_COPY_FAILED"
cp "$SEC" "$NEW/libcarplay-security-bridge.so" || fail "SESSION_BRIDGE_COPY_FAILED"
cp "$PAIR_HELPER" "$NEW/security_bridge/carplay-pairing-helper" || fail "PAIR_HELPER_COPY_FAILED"
cp "$PAIR_CORE" "$NEW/security_bridge/libCarPlayPairingCore.so" || fail "PAIR_CORE_COPY_FAILED"
echo "$VERSION" > "$NEW/VERSION"
echo "$DETECTED_MU/$INSTRUMENT" > "$NEW/PROFILE"
touch "$NEW/CLUSTER_AUTO_ENABLE"

chmod 755 "$NEW/dio_manager.wrapper.sh" "$NEW/altscreen-most-bridge" "$NEW/carplay-cluster-supervisor" "$NEW/security_bridge/carplay-pairing-helper" "$NEW/stock_first/dio_manager.real"
chmod 644 "$NEW/core.so" "$NEW/libcarplay-security-bridge.so" "$NEW/security_bridge/libCarPlayPairingCore.so" "$NEW/VERSION" "$NEW/PROFILE" "$NEW/CLUSTER_AUTO_ENABLE"

cp "$CONTROL_JAR" "$JARS/CarPlayClusterControls.jar.new" || fail "CONTROL_JAR_STAGE_FAILED"
cp "$STAGE/lsd.sh.patched" "$LSD.cpmap-new" || fail "LSD_ACTIVATION_STAGE_FAILED"
chmod 644 "$JARS/CarPlayClusterControls.jar.new"
chmod 755 "$LSD.cpmap-new"
if [ "$NAV_INSTALL" = yes ]; then
    cp "$NAV_JAR" "$NAV_TARGET.new" || fail "NAV_JAR_STAGE_FAILED"
    chmod 644 "$NAV_TARGET.new"
fi

if [ -d "$ROOT" ]; then
    mv "$ROOT" "$OLD" || fail "OLD_ROOT_MOVE_FAILED"
fi
mv "$NEW" "$ROOT" || {
    [ -d "$OLD" ] && mv "$OLD" "$ROOT" 2>/dev/null
    fail "NEW_ROOT_ACTIVATION_FAILED"
}

rollback_commit() {
    cp "$STAGE/dio_manager.current" "$DIO" 2>/dev/null || true
    cp "$STAGE/lsd.sh.current" "$LSD" 2>/dev/null || true
    if [ -s "$STAGE/control.current" ]; then
        cp "$STAGE/control.current" "$JARS/CarPlayClusterControls.jar" 2>/dev/null || true
    else
        rm -f "$JARS/CarPlayClusterControls.jar" 2>/dev/null
    fi
    if [ -s "$STAGE/nav.current" ]; then
        cp "$STAGE/nav.current" "$NAV_TARGET" 2>/dev/null || true
    else
        rm -f "$NAV_TARGET" 2>/dev/null
    fi
    rm -rf "$ROOT" 2>/dev/null
    [ -d "$OLD" ] && mv "$OLD" "$ROOT" 2>/dev/null
}

mv "$JARS/CarPlayClusterControls.jar.new" "$JARS/CarPlayClusterControls.jar" || { rollback_commit; fail "CONTROL_JAR_ACTIVATION_FAILED"; }
if [ "$NAV_INSTALL" = yes ]; then
    mv "$NAV_TARGET.new" "$NAV_TARGET" || { rollback_commit; fail "NAV_JAR_ACTIVATION_FAILED"; }
fi
mv "$LSD.cpmap-new" "$LSD" || { rollback_commit; fail "LSD_ACTIVATION_FAILED"; }
cp "$ROOT/dio_manager.wrapper.sh" "$DIO.new" || { rollback_commit; fail "DIO_WRAPPER_STAGE_FAILED"; }
chmod 755 "$DIO.new"
mv "$DIO.new" "$DIO" || { rollback_commit; fail "DIO_WRAPPER_ACTIVATION_FAILED"; }

rm -f "$ROOT/cpmap-guard" "$ROOT/cpmap-auth" "$ROOT/cpmap-provision" "$ROOT/intro.eft" "$ROOT"/*.eft "$ROOT"/k1 "$ROOT"/k2 2>/dev/null

[ -s "$DIO" ] || fail "DIO_WRAPPER_VERIFY_FAILED"
[ -s "$ROOT/core.so" ] || fail "CORE_VERIFY_FAILED"
[ -s "$ROOT/stock_first/dio_manager.real" ] || fail "STOCK_VERIFY_FAILED"
[ -s "$JARS/CarPlayClusterControls.jar" ] || fail "CONTROL_JAR_VERIFY_FAILED"
[ `grep -c 'CarPlayClusterControls.jar' "$LSD" 2>/dev/null` -eq 1 ] || fail "BOOTCLASSPATH_VERIFY_FAILED"
if [ "$NAV_INSTALL" = yes ]; then
    has_navigation_patch "$NAV_TARGET" || { rollback_commit; fail "NAVIGATION_VERIFY_FAILED"; }
    [ `grep -c 'CarPlayNavigationPatch.jar' "$LSD" 2>/dev/null` -eq 1 ] || { rollback_commit; fail "NAVIGATION_CLASSPATH_VERIFY_FAILED"; }
fi
rm -rf "$OLD" "$STAGE" 2>/dev/null

sync 2>/dev/null || true
echo "$VERSION"
echo "CPMAP_PROFILE=$DETECTED_MU/$INSTRUMENT"
echo "CPMAP_PLAINTEXT_ROOT=/mnt/app/carplaymaps"
echo "CPMAP_INSTALL_OK"
echo "A full unit reboot is required."
exit 0
