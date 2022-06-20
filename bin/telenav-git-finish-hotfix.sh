#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 ]]; then

    echo "telenav-git-finish-hotfix.sh [scope] [branch-name]"

fi

resolve_scope "$1"
branch_name=$2

cd_workspace
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Dcactus.operation=finish \
    -Dcactus.branch=hotfix \
    -Dcactus.branch="$branch_name" \
    com.telenav.cactus:cactus-maven-plugin:1.4.12:git-flow || exit 1
