#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

family=""
version=""

source telenav-library-functions.sh
source telenav-release-library-functions.sh

echo "Releasing $family $version"

#
# Check that the project family is on the 'develop' branch
#

echo " - Checking project branches"

if [[ ! $(git_check_branch_name "$family" develop)  ]]; then
    echo "Must be on develop branch to start a release"
    usage
fi

#
# Check that the change log has been updated
#

echo " - Checking change log"

if ! grep -q "## Version $version" "$family/change-log.md"; then
    echo "Please update $family/change-log.md before releasing"
    usage
fi

#
# Start a release branch
#

echo " - Creating release branch"

# TODO: need to check branch inside the start/finish scripts

telenav-git-release-start.sh "$family" "$version" || exit 1

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

telenav-build.sh "$family" "release-local" || exit 1

echo " - Local release built successfully"

#
# Describe the next steps to take
#

echo " "
echo "Next Steps:"
echo " "
echo "  - Check the release carefully"
echo "  - Run \"telenav-release-finish.sh $family $version\""
echo " "
