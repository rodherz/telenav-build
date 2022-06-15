#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 ]]; then

    echo "telenav-git-finish-feature.sh [scope] [branch-name]"
    exit 1

fi

scope=$(resolve_scope "$1")
branch_name=$2

cd_workspace
mvn --quiet "$scope" -Dtelenav.operation=finish -Dtelenav.branch-type=feature -Dtelenav.branch="$branch_name" com.telenav.cactus:cactus-maven-plugin:git-flow || exit 1
