#! /bin/bash
#
# CONCURRENT HASHING TEST SCRIPT
#
# Copyright (c) 2010 The PyroScope Project <pyroscope.project@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Do a self-referential listing for piping to pastee
cat $0; echo; echo "~~~ Start of test run ~~~"

# Preparation
cd $(dirname $(dirname $0))
test ! -f fifotest.torrent || rm fifotest.torrent
test ! -e fifotest.fifo || rm fifotest.fifo
mkfifo fifotest.fifo

# Start hashing process
mktor -r concurrent -o fifotest fifotest.fifo OBT -v 2>&1 | sed -e s:$HOME:~: &

# Start filename emitting process (fake .25 sec latency)
( for file in $(find tests/ -name "*.py"); do
    echo >&2 "$(date -u +'%T.%N') $file is complete!"
    echo $file
    sleep .25
done ) >fifotest.fifo &

# Wait for hashing to complete
while test ! -f fifotest.torrent; do
    echo "$(date -u +'%T.%N') Waiting for metafile..."
    sleep .1
done
echo

# Show the result
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
lstor -q fifotest.torrent

# Clean up
rm fifotest.*
