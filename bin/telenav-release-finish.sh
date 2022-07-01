#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh
source telenav-release-library-functions.sh

#
# Build the release
#

echo "Building $family $version release"

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
