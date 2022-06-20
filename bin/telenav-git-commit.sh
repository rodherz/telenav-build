#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

#
# telenav-git-commit.sh [scope]? [message]
#

if [[ "$#" -eq 1 ]]; then

    scope="all-project-families"
    message=$1

elif [[ "$#" -eq 2 ]]; then

    scope=$1
    message=$2

else

    echo "$(script) [scope]? [branch]"

fi

cd_workspace
resolve_scope "$scope"
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Dcactus.commit-message=\""$message"\" \
    -Dcactus.update-root=true \
    com.telenav.cactus:cactus-maven-plugin:1.4.12:commit || exit 1
