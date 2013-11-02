#!/bin/bash

# This file is part of Updater.
# 
# Updater is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Updater is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with Updater.  If not, see <http://www.gnu.org/licenses/>.

set -e

# Commands used.
DIRNAME_CMD=/usr/bin/dirname
GIT_CMD=/usr/bin/git
PATCH_CMD=/usr/bin/patch

# VERBOCITY
# 0 = silent
# 1 = minimal
# 2 = progress
# 3 = debug
VERBOCITY=3

minimal() {
    if [ $VERBOCITY -ge 1 ] ; then
        echo "$1"
    fi
}

progress() {
    if [ $VERBOCITY -ge 2 ] ; then
        echo "  $1"
    fi
}

debug() {
    if [ $VERBOCITY -ge 3 ] ; then
        echo "  DEBUG: $1"
    fi
}

minimal "Checking for updates ... "

# CALL_DIR - directory in which call was made.
CALL_DIR="$PWD"

# SCRIPT_DIR - directory in which script resides.
cd "$("$DIRNAME_CMD" "$0")"
SCRIPT_DIR="$PWD"
cd "$CALL_DIR"

# PROJECT_DIR - root directory of project (contains $SCRIPT_DIR and VERSION).
cd "$SCRIPT_DIR/../.."
PROJECT_DIR="$PWD"
cd "$CALL_DIR"
debug "Project directory: $PROJECT_DIR"

# Goto project directory.
cd "$PROJECT_DIR"

# Apply patch.
progress "Applying patch ... "
"$GIT_CMD" apply "$1"

minimal "Done."
