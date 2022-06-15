#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 || "$1" == "all" ]]; then

    echo "telenav-release-finish.sh [project-family-name] [version]"
    exit 1

fi

scope=$(resolve_scope "$1")
version=$2

cd_workspace

telenav-build.sh "$scope" release || exit 1

# shellcheck disable=SC2086
mvn --quiet $scope -Dtelenav.operation=finish -Dtelenav.branch-type=release -Dtelenav.branch="$version" com.telenav.cactus:cactus-maven-plugin:git-flow || exit 1

echo " "
echo "Next Steps:"
echo " "
echo "  1. Sign into [OSSRH](http://s01.oss.sonatype.org) and push the build to Maven Central."
echo "  2. Done."
echo " "
