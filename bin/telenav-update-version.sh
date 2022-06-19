#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 ]]; then

    echo "telenav-update-version.sh [scope] [version]"
    exit 1

fi

scope=$(resolve_scope "$1")
version=$2

if [[ "$family" == "all" || "$family" == "this" ]]; then

    echo "Must specify a scope, like all, kivakit, mesakit or lexakai"
    exit 1

fi

cd_workspace
mvn --quiet "$scope" -Dcactus.version="$version" -Dcactus.branch-name="$version" com.telenav.cactus:cactus-maven-plugin:replace || exit 1
