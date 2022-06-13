#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

folders=()

source telenav-library-functions.sh

scope=$1

allowed_scopes=(all this kivakit mesakit lexakai cactus)

if [[ ! " ${allowed_scopes[*]} " == *" ${scope} "* ]]; then
    echo "Invalid scope"
    exit 1
fi

require_variable TELENAV_WORKSPACE "Must set TELENAV_WORKSPACE"
cd_workspace

javadoc()
{
    folder=$1
    cd "$TELENAV_WORKSPACE/$folder" || exit
    echo "┋ ================= $folder"
    mvn --no-transfer-progress --batch-mode -q -Dsurefire.printSummary=false -DKIVAKIT_LOG_LEVEL=Warning -Dmaven.test.skip=true -DKIVAKIT_DEBUG="!Debug" --threads 12 javadoc:aggregate || exit 1
}

build_javadoc()
{
    scope=$1

    scoped_folders "$scope"
    for folder in "${folders[@]}";
    do
        javadoc "$folder"
    done
}

build_javadoc "$scope"
