#!/bin/bash -eu

ROOTDIR=$(pwd)
if ! expr "$ROOTDIR" : '.*/Brew$' &> /dev/null; then
	error "Please run this script from the Brew directory."
	exit 1
fi

ADIUM="`dirname $0`/../.."

for file in "$ROOTDIR"/Frameworks/*.subproj
do
	proj=$(basename $file)
	framework="${proj%.*}"
	rm -Rf "$ADIUM/Frameworks/$framework.framework" || true
	cp -Rf $file/$framework.framework "$ADIUM/Frameworks/"
done

echo "Done - now build Adium"
