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
    branch=$1

elif [[ "$#" -eq 2 ]]; then

    scope=$1
    branch=$2

else

    echo "$(script) [scope]? [branch-name]"
    exit 1

fi

cd_workspace
resolve_scope "$scope"
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Dcactus.base-branch="$branch" \
    -Dcactus.update-root=true \
    -Dcactus.permit-local-changes=true \
    com.telenav.cactus:cactus-maven-plugin:1.4.12:checkout || exit 1
