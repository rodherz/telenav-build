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
    message=$1

elif [[ "$#" -eq 2 ]]; then

    scope=$1
    message=$2

else

    echo "$(script) [scope]? [message]"

fi

cd_workspace
mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.commit-message=\""$message"\" \
    -Dcactus.update-root=true \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":commit || exit 1
