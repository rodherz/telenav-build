#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 3 ]]; then

    echo "telenav-release-update-version.sh [repository-family] [version] [branch]"
    exit 1

fi

family=$1
version=$2
branch=$3

if [[ "$family" == "all" || "$family" == "this" ]]; then

    echo "Must specify a repository family, like kivakit, mesakit or lexakai"
    exit 1

fi


#
# telenav-release-update-version.sh [repository-family]? [version] [branch-name]
#

cd_workspace
scope=$(repository_scope "$1")
mvn --quiet "$scope" -Dtelenav.version="$version" -Dtelenav.branch-name="$branch" com.telenav.cactus:cactus-build-maven-plugin:replace || exit 1
