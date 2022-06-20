#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 ]]; then

    echo "telenav-git-start-feature.sh [scope] [branch-name]"

fi

resolve_scope "$1"
branch_name=$2

cd_workspace
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Doperation=telenav.start \
    -Dcactus.branch-type=feature \
    -Dcactus.branch="$branch_name" \
    com.telenav.cactus:cactus-maven-plugin:git-flow || exit 1
