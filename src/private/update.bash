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

################################################################
# update.bash - A simple update script for git-based projects
# Copyright 2013 - Stoney Jackson <dr.stoney@gmail.com>
# License: LGPL v3 - http://www.gnu.org/licenses/lgpl.html
#
# INSTALLING
# 1. Place update.bash anywhere in project.
# 2. Add VERSION to project root containing version number.
# 3. Add REPOSITORY to project root containing URL to repo.
# 4. Use tag releases on master with version number.
#
# USING
# 1. Bump version in repository.
#     $ echo 3.1.2 > VERSION
#     $ git commit -a 'Bump version.'
#     $ git tag 3.1.2
# 2. Run update.bash on each deployed project.

# Exit if any command fails.
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
cd "$SCRIPT_DIR"
while [ ! -e VERSION -a "$PWD" != "/" ] ; do
    cd ..
done
if [ "$PWD" = "/" -a ! -e VERSION ] ; then
    echo "ERROR: No project found." 1>&2
    exit 1
fi
PROJECT_DIR="$PWD"
cd "$CALL_DIR"
debug "Project directory: $PROJECT_DIR"

# CURRENT_VERSION - current version of project.
progress "Reading VERSION ... "
CURRENT_VERSION="$(cat "$PROJECT_DIR/VERSION")"
debug "Current version: $CURRENT_VERSION"

# REPOSITORY_URL - URL of repository.
progress "Reading REPOSITORY ... "
REPOSITORY_URL="$(cat "$SCRIPT_DIR/REPOSITORY")"
debug "Repository URL: $REPOSITORY_URL"

# BRANCH - Branch of repository to get tag from.
progress "Reading BRANCH ... "
BRANCH="$(cat "$SCRIPT_DIR/BRANCH")"
debug "Branch: $REPOSITORY_URL"

# Prepare tmp directory.
rm -rf "$SCRIPT_DIR/tmp"
mkdir -p "$SCRIPT_DIR/tmp"

# Clone git repository.
progress "Cloning repository ... "
# Tell git to use ssh.bash instead of ssh so we can pass options to ssh.
export GIT_SSH="$SCRIPT_DIR/ssh.bash"
ssh-agent bash -c "ssh-add $SCRIPT_DIR/deployment-key ; $GIT_CMD clone $REPOSITORY_URL $SCRIPT_DIR/tmp/repo"

# Move into git repository.
cd "$SCRIPT_DIR/tmp/repo"

    # Repository version.
    progress "Get repository version ... "
    "$GIT_CMD" checkout "$BRANCH"
    REPOSITORY_VERSION="$("$GIT_CMD" describe --abbrev=0)"
    debug "Repository version: $REPOSITORY_VERSION"

    # Do nothing if versions are the same.
    if [ "$REPOSITORY_VERSION" = "$CURRENT_VERSION" ] ; then
        minimal "No new updates."

	# Clean up.
	progress "Cleaning up ... "
	rm -rf "$SCRIPT_DIR/tmp"
	minimal "Done."
        exit 0
    fi

    minimal "Updating from $CURRENT_VERSION to $REPOSITORY_VERSION ... "

    # Create patch.
    progress "Creating patch ... "
    "$GIT_CMD" diff "$CURRENT_VERSION" "$REPOSITORY_VERSION" -- > "$SCRIPT_DIR/tmp/patch"

# Goto project directory.
cd "$PROJECT_DIR"

    # Apply patch.
    progress "Applying patch ... "
    "$GIT_CMD" apply "$SCRIPT_DIR/tmp/patch"

# Clean up.
progress "Cleaning up ... "
rm -rf "$SCRIPT_DIR/tmp"

minimal "Done."
