#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ "$#" -eq 1 ]]; then

    scope="all-project-families"
    branch_name=$1

elif [[ "$#" -eq 2 ]]; then

    scope=$1
    branch_name=$2

else

    echo "$(script) [scope]? [branch-name]"
    exit 1

fi

resolve_scope "$scope"

cd_workspace
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Dcactus.operation=finish \
    -Dcactus.branch-type=feature \
    -Dcactus.branch="$branch_name" \
    com.telenav.cactus:cactus-maven-plugin:1.4.12:git-flow || exit 1
