#!/bin/bash
# Author: Tobi Vollebregt
# License: GNU General Public License v2
#
# Makes a release of the AI by creating mutator for
# current stable Spring: 1944 release.
#

mkdir .tmp
cp -r * .tmp/
rm -rf .tmp/mutator.zip .tmp/mutator.sdz .tmp/tools/

# Generate modinfo.lua for Operation Konstantin (v0.92)
cat > .tmp/modinfo.lua << EOD
-- Author: Tobi Vollebregt
-- License: GNU General Public License v2

local modinfo = {
	name = "Imperial Winter 1.5.051 beta + C.R.A.I.G. (v2.3 alpha)",
	shortname = "SWIW",
	game = "Star Wars: Imperial Winter",
	shortgame = "SWIW",
	mutator = "AI for SWIW",
	description = "AI for Spring: 1944 hastily bodged into SWIW",
	url = "www.meatspin.com",
	modtype = "1",
	depend = {
		"sws.v051.sdz",
	}
}

return modinfo
EOD

# Disable debugging.
sed -i 's/^local CRAIG_Debug_Mode = 1/local CRAIG_Debug_Mode = 0/g' \
	.tmp/LuaRules/Gadgets/craig/main.lua

# Zip it & cleanup.
cd .tmp &&
zip -r ../mutator.zip * &&
cd .. &&
rm -rf .tmp &&
mv mutator.zip mutator.sdz

echo "==> Mutator created in mutator.sdz <=="
