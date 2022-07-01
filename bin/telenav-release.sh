#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

family=""
version=""
scope=""

source telenav-library-functions.sh
source telenav-release-library-functions.sh

echo "Releasing $family $version"
cd_workspace

#
# Check that the project family is on the 'develop' branch
#

echo " - Checking project family branches"

if [[ ! "$(git_branch_name "$family")" == "develop" ]]; then
    echo "Must be on develop branch to start a release"
    usage
fi

#
# Check that the change log has been updated
#

echo " - Checking change log"

if ! grep -q "## Version $version" "$scope/change-log.md"; then
    echo "Please update $scope/change-log.md before releasing"
    usage
fi

#
# Start a release branch
#

echo " - Creating release branch"

telenav-git-release-start.sh "$scope" "$version" || exit 1

exit 1

#
# Update version information
#

echo " - Updating version to $version"

telenav-update-version.sh "$version" "release/$version" || exit 1

#
# Build the release into the local repository
#

echo " - Building local release"

telenav-build.sh "$scope" "release-local" || exit 1

echo " - Local release built successfully"

#
# Describe the next steps to take
#

echo " "
echo "Next Steps:"
echo " "
echo "  - Check the release carefully"
echo "  - Run \"telenav-release-finish.sh $scope $version\""
echo " "
