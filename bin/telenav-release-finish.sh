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
resolved_scope=""

source telenav-library-functions.sh
source telenav-release-library-functions.sh

#
# 1. Build and publish the release
#

echo "Building $family $version release"

telenav-build.sh "$resolved_scope" release || exit 1

#
# 2. Finish the release branch
#

telenav-git-release-finish.sh "$scope" "release/$version"

#
# 3. Show final step
#

echo " "
echo "Next Steps:"
echo " "
echo "  - Sign into [OSSRH](http://s01.oss.sonatype.org) and push the build to Maven Central."
echo " "
