#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

usage()
{
    echo "$(script) [project-family] [version]"
    exit 1
}

#
# Check that there are two arguments and get them
#

if [[ ! "$#" -eq 2 ]]; then
    usage
fi

scope=$1
version=$2

#
# Check that the scope is a project family
#

resolve_scope "$scope"
# shellcheck disable=SC2154
if [[ ! "$resolved_scope" == "family" ]]; then
    usage
fi

#
# Check that the project is on the 'develop' branch
#

cd_workspace
branch_name=$(git_branch_name "$1")

if [[ ! "$branch_name" == "develop" ]]; then
    echo "Must be on develop branch to start a release"
    usage
fi

#
# Check that the change log has been updated
#

if ! grep -q "Version $version" "$scope/change-log.md"; then
    echo "Please update $scope/change-log.md before releasing"
    usage
fi

#
# Start a release branch
#

telenav-git-release-start.sh "$scope" "$version" || exit 1

#
# Update version information
#

telenav-update-version.sh "$1" "release/$version" || exit 1

#
# Build the release into the local repository
#

telenav-build.sh "$scope" "release-local" || exit 1

#
# Describe the next steps to take
#

echo " "
echo "Next Steps:"
echo " "
echo "  - Inspect the release"
echo "  - Run telenav-release-finish.sh $scope $version"
echo " "
