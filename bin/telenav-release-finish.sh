#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 || "$1" == "all" ]]; then

    echo "telenav-git-finish-release.sh [project-family-name] [version]"
    exit 1

fi

scope=$(resolve_scope "$1")
version=$2

cd_workspace
mvn --quiet "$scope" -Doperation=finish -Dbranch-type=release -Dbranch-name="$version" com.telenav.cactus:cactus-maven-plugin:git-flow || exit 1

echo " "
echo "Next Steps:"
echo " "
echo "  1. Build the release and push to OSSRH (Maven Central Staging): telenav-build.sh [project-family] release"
echo "  2. Sign into [OSSRH](http://s01.oss.sonatype.org) and push the build to Maven Central."
echo " "
echo "Done."
echo " "
