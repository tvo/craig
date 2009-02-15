#!/bin/bash
# Author: Tobi Vollebregt
# License: GNU General Public License v2
#
# Copies SVN version of all files currently in git repo,
# to the git repo.  "../S44LiteRelease.sdd/" must exist!
#

if ! git diff --quiet; then
	echo "Local modifications present, aborted"
	exit 1
fi

# '*' instead of '.' to exclude .git
for dst in `find * -type f ! -name modinfo.lua`; do
	src="../S44LiteRelease.sdd/$dst"
	[ -f "$src" ] && cp "$src" "$dst" && dos2unix "$dst"
done

# Enable debugging.
sed -i 's/^local CRAIG_Debug_Mode = 0/local CRAIG_Debug_Mode = 1/g' \
	LuaRules/Gadgets/craig/main.lua
