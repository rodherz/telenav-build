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
    echo "$(script) [project-family] [release-version]"
    exit 1
}

#
# Check that there are two parameters and get them
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
# Build the release
#

cd_workspace
telenav-build.sh "$resolved_scope" release || exit 1

#
# Finish the release branch
#

telenav-git-release-finish.sh "$scope" "release/$version"

echo " "
echo "Next Steps:"
echo " "
echo "  - Sign into [OSSRH](http://s01.oss.sonatype.org) and push the build to Maven Central."
echo " "
