#!/bin/sh

if ! command -v gcc > /dev/null
then
	echo "$0: no gcc"
	exit 1
fi

if [ -z "$1" ]
then
	echo "$0: no file specified"
	exit 1
fi

in="$1"

if [ ! -f "$in" ]
then
	echo "$0: file not found: '$in'"
	exit 1
fi

debug=false
DDEBUG=""
if [ -n "$2" ]
then
	debug=true
	DDEBUG="-D DEBUG"
fi



out="../$(basename "$in")"
echo "Writing to $out ..."
(
	echo "#!/usr/bin/env lua"
	echo "------------------------------------------"
	echo "-- GENERATED FILE, DO NOT EDIT DIRECTLY --"
	echo "------------------------------------------"

	# - Use gcc preprocessor to handle #include
	# - Strip lua output comments
	# - Convert gcc comments to lua comments
	# - Strip spaces at start of lines
	# - Delete empty lines

#	| ( $debug || sed 's/^#/--/g'             ) \

	cat "$in" \
	| gcc -E - $DDEBUG \
	| grep -v '^#' \
	| if $debug
	then
		cat
	else
		cat \
		| sed 's/^[[:space:]]*//g' \
		| grep -v '^--' \
		| sed '/^$/d' \
		| grep -v '^DEBUG'
	fi

) > "$out"


for copycommand in "/mnt/c/Windows/System32/clip.exe" "pbcopy"
do
	if command -v "$copycommand" > /dev/null
	then
		echo "Copying to clipboard ($copycommand) ..."
		cat "$out" | $copycommand
	fi
done
