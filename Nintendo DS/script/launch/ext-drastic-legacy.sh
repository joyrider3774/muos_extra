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

DRASTIC_BIN="drastic"
SET_VAR "system" "foreground_process" "$DRASTIC_BIN"

EMUDIR="$MUOS_SHARE_DIR/emulator/drastic-legacy"

chmod +x "$EMUDIR"/$DRASTIC_BIN
cd "$EMUDIR" || exit

GPTOKEYB "$DRASTIC_BIN" "$CORE"
HOME="$EMUDIR" SDL_ASSERT=always_ignore ./$DRASTIC_BIN "$FILE"
