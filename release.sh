#!/bin/bash

##############################################################################
#
# Configuration
#

# Version of the Cactus Maven plugin to use
export CACTUS_PLUGIN_VERSION=1.5.5

# Set this to whatever profile makes the right GPG keys available, from your ~/.m2/settings.xml
export GPG_PROFILE=gpg

# This should be 'release' when really releasing or something else when testing
export RELEASE_BRANCH_PREFIX=great_googly_moogly

##############################################################################
#
# Determine the workspace to release
#

setopt interactivecomments

# shellcheck disable=SC2164
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ -z "$TELENAV_WORKSPACE" ]]; then
    export TELENAV_WORKSPACE=$SCRIPT_PATH
fi

##############################################################################
#
# Determine what project families to release
#

ask "What project families do you want to release [kivakit,lexakai,mesakit]? "
if [[ -z "$REPLY" ]]; then
    export FAMILIES_TO_RELEASE='kivakit,lexakai,mesakit'
else
    export FAMILIES_TO_RELEASE=$REPLY
fi

##############################################################################
#
# Check installed tools and clean out caches
#

source "$TELENAV_WORKSPACE"/bin/telenav-library-functions.sh

check_tools
clean_caches

##############################################################################
#
# Maven options we will need. Note the system property cactus.release.branch.prefix --
# this lets us create test release branches without squatting the real release branch,
# so we can even test pushing the branch before we commit to a release.
#

export MAVEN_OPTS="-XX:+UseG1GC \
    -Dcactus.debug=false \
    -DreleasePush=true \
    -Dmaven.repo.local=\"${MAVEN_REPOSITORY}\" \
    --add-opens=java.base/java.util=ALL-UNNAMED \
    --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
    --add-opens=java.base/java.text=ALL-UNNAMED \
    --add-opens=java.desktop/java.awt.font=ALL-UNNAMED \
    -Dcactus.release.branch.prefix=\"${RELEASE_BRANCH_PREFIX}\""

##############################################################################
#
# Use a temporary Maven repository for the release to ensure it's a fresh build
#

export MAVEN_REPOSITORY=$TMPDIR/release-maven-repository
rm -rf "$MAVEN_REPOSITORY"

##############################################################################
#
# 1. Clone the develop branch
#

cd "$TMPDIR" || exit
rm -Rf release-workspace
cp -Ra "$TELENAV_WORKSPACE" release-workspace
cd release-workspace || exit

##############################################################################
#
# 2. Build the workspace
#

mvn -f telenav-superpom/pom.xml install
mvn clean install -Dmaven.test.skip=true

##############################################################################
#
# 3. Update versions appropriately - kivakit gets a major rev, the rest minor ones.
# For testing, so we don't have to delete branches later, we are overriding the release-branch
# prefix - just remove -Dcactus.release.branch.prefix= for a real release
#

mvn -P release-phase-1 \
    -Denforcer.skip=true \
    -Dcactus.expected.branch=develop \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dcactus.families="${FAMILIES_TO_RELEASE}" \
    -Dcactus.release.branch.prefix="$RELEASE_BRANCH_PREFIX" \
    -Dmaven.test.skip=true \
        clean \
        validate

##############################################################################
#
# 4. Rebuild everything now that some things have new versions
#

mvn -f telenav-superpom/pom.xml install
mvn clean install -Dmaven.test.skip=true

##############################################################################
#
# 5. Update the docs
#

mvn -P release-phase-2 \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dcactus.families="${FAMILIES_TO_RELEASE}" \
    -Dcactus.release.branch.prefix="$RELEASE_BRANCH_PREFIX" \
    -Dmaven.test.skip=true \
        clean \
        install \
        org.apache.maven.plugins:maven-site-plugin:4.0.0-M1:site verify

##############################################################################
#
# 6. Review the release
#

echo " "
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Review ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┋"
echo "┋ Review the release now:"
echo "┋"
echo "┋    1. Check the documentation, including links and diagrams"
echo "┋    2. Check that version numbers and branch names were updated as expected"
echo "┋"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo " "

while
    ask "When ready to continue, type 'release': "
    [[ "$REPLY" == "release" ]]
do true; done

##############################################################################
#
# 7. Commit the docs changes, build the release and publish to Nexus / OSSRH
#

mvn -P release-phase-3 \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -P ${GPG_PROFILE} \
    -Dcactus.families="${FAMILIES_TO_RELEASE}" \
    -Dcactus.release.branch.prefix="$RELEASE_BRANCH_PREFIX" \
    -Dmaven.test.skip=true \
        deploy


##############################################################################
#
# 8. Merge changes back to develop and update released stuff to a new snapshot version
#

mvn -P release-phase-4 \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dcactus.families="${FAMILIES_TO_RELEASE}" \
    -Dmaven.test.skip=true \
    generate-resources
