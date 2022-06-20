#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

#
# telenav-git-commit.sh [message]?
#

#
# Get message
#

message=$1

if [[ "$message" == "" ]]; then

    read -p "Commit message? " -r
    message=$REPLY

fi

#
# Commit
#

cd_workspace
resolve_scope=$(scope)
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Dcactus.commit-message=\""$message"\" \
    -Dcactus.update-root=true \
    com.telenav.cactus:cactus-maven-plugin:commit || exit 1
