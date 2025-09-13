#!/bin/sh

. /opt/muos/script/var/func.sh

NAME=$1
CORE=$2
FILE=${3%/}

(
	LOG_INFO "$0" 0 "Content Launch" "DETAIL"
	LOG_INFO "$0" 0 "NAME" "$NAME"
	LOG_INFO "$0" 0 "CORE" "$CORE"
	LOG_INFO "$0" 0 "FILE" "$FILE"
) &

HOME="$(GET_VAR "device" "board/home")"
export HOME

SETUP_SDL_ENVIRONMENT

SET_VAR "system" "foreground_process" "retroarch"

RA_CONF="/opt/muos/share/info/config/retroarch.cfg"
RA_ARGS=$(CONFIGURE_RETROARCH "$RA_CONF")

IS_SWAP=$(DETECT_CONTROL_SWAP)

/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" start

if [ "$(echo "$FILE" | awk -F. '{print $NF}')" = "zip" ]; then
	nice --20 retroarch -v -f -c "$RA_CONF" $RA_ARGS -L "/opt/muos/share/core/easyrpg_libretro.so" "$FILE"
	rm -Rf "$FILE.save"
else
	F_PATH=$(echo "$FILE" | awk -F'/' '{NF--; print}' OFS='/')
	ERPC=$(sed <"$FILE.cfg" 's/[[:space:]]*$//')

	SUB_FOLDER="$NAME"
	[ -d "$F_PATH/.$NAME" ] && SUB_FOLDER=".$NAME"

	nice --20 retroarch -v -f -c "$RA_CONF" $RA_ARGS -L "/opt/muos/share/core/easyrpg_libretro.so" "$F_PATH/$SUB_FOLDER/$ERPC"
fi

for RF in ra_no_load ra_autoload_once.cfg; do
	[ -e "/tmp/$RF" ] && ENSURE_REMOVED "/tmp/$RF"
done

[ "$IS_SWAP" -eq 1 ] && DETECT_CONTROL_SWAP

unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" stop
