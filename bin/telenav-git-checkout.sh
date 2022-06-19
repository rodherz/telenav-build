#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

#
# checkout
#

if [[ "$#" -eq 0 ]]; then

    read -p "Branch? " -r
    scope="all-project-families"
    branch=$REPLY

fi

#
# checkout [branch]
#

if [[ "$#" -eq 1 ]]; then
    scope="all-project-families"
    branch=$1
fi

#
# checkout [scope] [branch]
#

if [[ "$#" -eq 2 ]]; then
    scope=$1
    branch=$2
fi

cd_workspace
scope=$(resolve_scope "$scope")
mvn --quiet "$scope" \
    -Dcactus.base-branch="$branch" \
    -Dcactus.update-root=true \
    -Dcactus.permit-local-changes=true \
    com.telenav.cactus:cactus-maven-plugin:1.4.11:checkout || exit 1
