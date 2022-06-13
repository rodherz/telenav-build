#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 || "$1" == "all" ]]; then

    echo "telenav-git-start-release.sh [project-family-name] [version]"
    exit 1

fi

scope=$(resolve_scope "$1")
version=$2

cd_workspace
mvn --quiet $scope -DincludeRoot=false -Doperation=start -DbranchType=release -DbranchName="$version" com.telenav.cactus:cactus-build-maven-plugin:git-flow || exit 1

telenav-update-version.sh "$1" "release/$version" || exit 1
