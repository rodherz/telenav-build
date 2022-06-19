#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 || "$1" == "all" ]]; then

    echo "telenav-release.sh [project-family-name] [version]"
    exit 1

fi

scope=$(resolve_scope "$1")
version=$2

cd_workspace

branch_name=$(git_branch_name "$1")
if [[ ! "$branch_name" == "develop" ]]; then
    echo "Must be on develop branch to start a release"
    exit 1
fi


# shellcheck disable=SC2086
mvn --quiet $scope -Dcactus.include-root=false -Dcactus.operation=start -Dcactus.branch-type=release -Dcactus.branch="$version" com.telenav.cactus:cactus-maven-plugin:git-flow || exit 1

telenav-update-version.sh "$1" "release/$version" || exit 1

echo " "
echo "Next Steps:"
echo " "
echo "  1. Update change-log.md"
echo "  2. Build the release branch: telenav-build [project-family] release-local"
echo "  3. Complete the release branch: telenav-release-finish.sh [project-family] [project-version]"
echo " "
