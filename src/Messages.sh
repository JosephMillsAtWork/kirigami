#! /usr/bin/env bash
$EXTRACT_TR_STRINGS `find . -name \*.qml` -o $podir/libkirigamiplugin_qt.pot
rm -f rc.cpp

