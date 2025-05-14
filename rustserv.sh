#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing rcon password!"
    exit 1
fi

IDENTITY="rustserv"
RUSTDIR="$HOME/rust"
SERVERDIR="$RUSTDIR/server/$IDENTITY"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RUSTDIR/RustDedicated_Data/Plugins:$RUSTDIR/RustDedicated_Data/Plugins/x86_64"

server_wipe() {
	if [ -z "$1"]; then
		return 1
	fi

	case "$1" in
		map)
			rm -f "$SERVERDIR"/procedural* "$SERVERDIR/logs"/*
			;;
		full)
			"$HOME/steamcmd/steamcmd.sh" +force_install_dir "$RUSTDIR" +login anonymous +app_update 258550 validate +quit
			rm -f "$SERVERDIR"/procedural* "$SERVERDIR"/*db* "$SERVERDIR/logs"/*
			;;
	esac

	SEED=$(shuf -i 0-2147483647 -n 1)
	NEXTWIPE=$( [ "$1" == "map" ] && echo "FULL" || echo "MAP" )
	WIPESTAMP="last wipe: ${1^^} $(date)\\\\nnext wipe: $NEXTWIPE $(date -d "+14 days")\\\\n\\\\n\\\\n\\\\n\\\\n\\\\n\\\\n\\\\n\\\\n"

	sed -i "1s/.*/server.seed $SEED/" "$SERVERDIR/cfg/server.cfg"
	sed -i "2s/.*/server.description \"$WIPESTAMP\"/" "$SERVERDIR/cfg/server.cfg"
}

server_start() {
	if [ ! -d "$SERVERDIR/logs" ]; then
		mkdir -p "$SERVERDIR/logs"
	fi
	LOGFILE="$SERVERDIR/logs/server_$(date +%Y-%m-%d_%H-%M-%S).log"

	"$RUSTDIR/RustDedicated" -batchmode +rcon.password "$1" +server.identity "$IDENTITY" -logfile 2>&1 | tee "$LOGFILE"
}

while true; do
	echo "Do you want to wipe server? (map/full)"
	read -t 10 WIPE
	server_wipe "$WIPE"

	server_start "$1"

	echo "Do you want to keep server down? (y)"
	read -t 10 DOWN
	if [[ "$DOWN" == "y" ]]; then
		echo "Server will stay down. Manual start required"
		break
	fi
done
