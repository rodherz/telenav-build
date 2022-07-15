#!/bin/bash

##############################################################################
# Settings
##############################################################################

# Set this to whatever profile makes the right GPG keys available, from your ~/.m2/settings.xml
export GPG_PROFILE=gpg

# This should be 'release' when really releasing or something else when testing
export RELEASE_BRANCH_PREFIX=release

# Project families that can be released
export VALID_PROJECT_FAMILIES=(kivakit lexakai mesakit)



##############################################################################
# Check for any arguments (publish, quiet)
##############################################################################

export PUBLISH_RELEASE=false
# shellcheck disable=SC2155
export RELEASE_BRANCH_PREFIX=$(date '+%s')-test-release
unset QUIET
unset SKIP_REVIEW
unset FAST

for argument in "$@"
do
    if [ "$argument" == "publish" ]; then
        export PUBLISH_RELEASE=true
        export RELEASE_BRANCH_PREFIX=release
    fi
    if [ "$argument" == "quiet" ]; then
        export QUIET="--quiet"
    fi
    if [ "$argument" == "skip-review" ]; then
        export SKIP_REVIEW=true
    fi
    if [ "$argument" == "fast" ]; then
        export FAST="--threads 12"
    fi
    if [ "$argument" == "help" ]; then
        echo " "
        echo "release.sh [publish|skip-review|quiet|fast|help]*"
        echo " "
        exit 0
    fi
done



##############################################################################
# Find original workspace (where this script resides)
##############################################################################

# shellcheck disable=SC2046
ORIGINAL_WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)



##############################################################################
# Find the previous cactus version (can't build against the current one)
##############################################################################

# shellcheck disable=SC2002
# shellcheck disable=SC2155
export CACTUS_PLUGIN_VERSION=$(cat "${ORIGINAL_WORKSPACE}"/cactus/pom.xml | grep -Eow "<cactus\.previous\.version>(.*?)</cactus\.previous\.version>" | sed -E 's/.*>(.*)<.*/\1/')



##############################################################################
# Determine project families to release
##############################################################################

echo " "
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Cactus ${CACTUS_PLUGIN_VERSION}"
echo "┋"

read -r -p "┋ What project families do you want to release [kivakit,lexakai,mesakit]? "
if [[ -z "${REPLY}" ]]; then
    export PROJECT_FAMILIES='kivakit,lexakai,mesakit'
else
    export PROJECT_FAMILIES=$REPLY
fi



##############################################################################
# Determine the release type (major, minor, dot, none) for each family
##############################################################################

MAJOR_REVISION_FAMILIES=()
MINOR_REVISION_FAMILIES=()
DOT_REVISION_FAMILIES=()

for family in ${PROJECT_FAMILIES//,/ }
do
    # shellcheck disable=SC2076
    if [[ " ${VALID_PROJECT_FAMILIES[*]} " =~ " ${family} " ]]; then
        read -r -p "┋ Release type for $family (major, minor, dot, none) [none]? "
        if [[ -z "${REPLY}" ]]; then
            release_type="none"
        else
            release_type="$REPLY"
        fi
        case $release_type in
        major)
            MAJOR_REVISION_FAMILIES+=("$family")
            ;;
        minor)
            MINOR_REVISION_FAMILIES+=("$family")
            ;;
        dot)
            DOT_REVISION_FAMILIES+=("$family")
            ;;
        none)
            NONE_REVISION_FAMILIES+=("$family")
            ;;
        *)
            echo "$release_type is not a valid release type"
            exit 1
        esac
    else
        echo "$family is not a valid project family"
        exit 1
    fi
done



##############################################################################
# Show settings before we start building
##############################################################################

echo "┋"
echo "┋ Quiet: $QUIET"
echo "┋ Publish: ${PUBLISH_RELEASE}"
echo "┋ Project families: ${PROJECT_FAMILIES}"
echo "┋ None releases: ${NONE_REVISION_FAMILIES[*]}"
echo "┋ Dot releases: ${DOT_REVISION_FAMILIES[*]}"
echo "┋ Minor releases: ${MINOR_REVISION_FAMILIES[*]}"
echo "┋ Major releases: ${MAJOR_REVISION_FAMILIES[*]}"
echo "┋ Original workspace: ${WORKSPACE}"
echo "┋ Release branch prefix: ${RELEASE_BRANCH_PREFIX}"
echo "┋ "



##############################################################################
# RELEASE PHASE 0 - Check the workspace to make sure it is ready to be
# released, then clone the develop branch into a temporary workspace,
# whose location we parse from the output of the plugin.
##############################################################################

echo "┋ Installing superpoms"

cd "${ORIGINAL_WORKSPACE}" || exit 1

MAVEN_ARGUMENTS="$QUIET $FAST"

echo mvn "${MAVEN_ARGUMENTS}" \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -f telenav-superpom/pom.xml \
    install || exit 1

mvn "${MAVEN_ARGUMENTS}" \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -f telenav-superpom/pom.xml \
    install || exit 1

echo "┋ "
echo "┋━━━━━━━ PHASE 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┋ Cloning develop branch for release... (this may take a while)"

unset MESAKIT_ASSETS_HOME
unset KIVAKIT_ASSETS_HOME
unset CACTUS_ASSETS_HOME
unset LEXAKAI_ASSETS_HOME
unset CACTUS_HOME
unset KIVAKIT_HOME
unset MESAKIT_HOME
unset LEXAKAI_HOME

output=$(mvn \
    -P release-phase-0 \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dcactus.families="${PROJECT_FAMILIES}" \
        validate)

root=$(echo "$output" | grep "checkout-root: ")

if [[ ! $root == *"checkout-root: "* ]]; then
    echo "$output"
    echo " "
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ ERROR!"
    echo "┋ "
    echo "┋ PHASE 0 - Release checkout failed. Please check your workspace."
    echo "┋ All projects should be on their 'develop' branches with no modified files."
    echo "┋"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " "
    exit 1
fi

TEMPORARY_WORKSPACE=${root#*checkout-root: }

echo "┋ Temporary workspace: ${TEMPORARY_WORKSPACE}"



##############################################################################
# Create temporary maven repository to ensure a clean build
##############################################################################

export MAVEN_REPOSITORY=/tmp/maven-repository
rm -rf ${MAVEN_REPOSITORY} 1> /dev/null

echo "┋ Maven repository: ${MAVEN_REPOSITORY}"



##############################################################################
# Define Maven JVM options. The system property cactus.release.branch.prefix
# lets us create test release branches without stepping the real release.
##############################################################################

export MAVEN_OPTS="-XX:+UseG1GC \
    -Dcactus.debug=false \
    -DreleasePush=${PUBLISH_RELEASE} \
    -Dmaven.repo.local=${MAVEN_REPOSITORY} \
    --add-opens=java.base/java.util=ALL-UNNAMED \
    --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
    --add-opens=java.base/java.text=ALL-UNNAMED \
    --add-opens=java.desktop/java.awt.font=ALL-UNNAMED \
    -Dcactus.release.branch.prefix=${RELEASE_BRANCH_PREFIX}"



##############################################################################
# Check installed tools and clean out project caches
##############################################################################

source "${ORIGINAL_WORKSPACE}"/bin/telenav-library-functions.sh

echo "┋ Removing project caches"
rm -rf ~/.kivakit/
rm -rf ~/.mesakit/



##############################################################################
# Install superpoms and build the workspace without tests enabled
##############################################################################

cd "${TEMPORARY_WORKSPACE}" || exit 1

echo '┋ Installing superpoms'
mvn "${MAVEN_ARGUMENTS}" \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -f telenav-superpom/pom.xml install \
    || exit 1

echo '┋ Checking build (no tests)'
mvn "${MAVEN_ARGUMENTS}" \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dmaven.test.skip=true clean install || exit 1

echo "┋━━━━━━━ PHASE 0 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"



##############################################################################
# RELEASE PHASE 1 - Update versions and branch references
##############################################################################

echo "┋ "
echo "┋━━━━━━━ PHASE 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┋ Updating versions and branch references"

mvn -Dcactus.verbose=true \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -P release-phase-1 \
    -Denforcer.skip=true \
    -Dcactus.expected.branch=develop \
    -Dcactus.major.bump.families=\""${MAJOR_REVISION_FAMILIES[*]}"\" \
    -Dcactus.minor.bump.families=\""${MINOR_REVISION_FAMILIES[*]}"\" \
    -Dcactus.dot.bump.families=\""${DOT_REVISION_FAMILIES[*]}"\" \
    -Dcactus.no.bump.families=\""${NONE_REVISION_FAMILIES[*]}"\" \
    -Dcactus.families="${PROJECT_FAMILIES}" \
    -Dcactus.version.flavor.change=to-release \
    -Dcactus.release.branch.prefix="${RELEASE_BRANCH_PREFIX}" \
    -Dmaven.test.skip=true \
        clean validate || exit 1


##############################################################################
# Rebuild everything with tests now that some things have new versions
##############################################################################

echo "┋ Installing superpoms"
mvn "${MAVEN_ARGUMENTS}" \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -f telenav-superpom/pom.xml install || exit 1

echo "┋ Checking build (tests enabled)"
mvn "${MAVEN_ARGUMENTS}" \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    clean install || exit 1

echo "┋━━━━━━━ PHASE 1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"



##############################################################################
# RELEASE PHASE 2 - Build documentation
##############################################################################

echo "┋ "
echo "┋━━━━━━━ PHASE 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┋ Building documentation"

# shellcheck disable=SC2086
mvn -P release-phase-2 \
    ${MAVEN_ARGUMENTS} \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dcactus.families="${PROJECT_FAMILIES}" \
    -Dcactus.release.branch.prefix="${RELEASE_BRANCH_PREFIX}" \
    -Dmaven.test.skip=true \
    -DreleasePush=$PUBLISH_RELEASE \
    -Dcactus.push=$PUBLISH_RELEASE \
        install \
        javadoc:javadoc \
        javadoc:aggregate \
        javadoc:jar \
        org.apache.maven.plugins:maven-site-plugin:4.0.0-M1:site verify || exit 1

echo "┗━━━━━━━ PHASE 2 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"



##############################################################################
# Review the release (unless skip-review is specified)
##############################################################################

if [ ! "$SKIP_REVIEW" == "true" ]; then

    echo " "
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Review ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┋"
    echo "┋ Release is ready for you to review now:"
    echo "┋"
    echo "┋    1. Check the documentation, including links and diagrams"
    echo "┋    2. Check that version numbers and branch names were updated correctly"
    echo "┋"
    echo "┋ The release is in ${TEMPORARY_WORKSPACE}"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo " "

    unset REPLY
    while [[ ! "${REPLY}" == "publish" ]]
    do
        read -r -p "When ready to publish to Nexus / OSSRH staging for Maven Central, type 'publish': "
    done

fi



##############################################################################
# RELEASE PHASE 3 - Commit documentation changes, build the release and
# publish to Nexus / OSSRH (https://s01.oss.sonatype.org/)
##############################################################################


echo "┏━━━━━━━ PHASE 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┋ Publishing release..."

mvn -P release-phase-3 \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -P ${GPG_PROFILE} \
    -Dcactus.families="${PROJECT_FAMILIES}" \
    -Dcactus.release.branch.prefix="${RELEASE_BRANCH_PREFIX}" \
    -Dmaven.test.skip=true \
        deploy || exit 1

echo "┗━━━━━━━ PHASE 3 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"



##############################################################################
# RELEASE PHASE 4 - Merge changes back to develop and release/current and
# update the develop branch to the next snapshot version
##############################################################################

echo "┏━━━━━━━ PHASE 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┋ Merging release and updating to next snapshot version..."

mvn -P release-phase-4 \
    -Dcactus.maven.plugin.version="${CACTUS_PLUGIN_VERSION}" \
    -Dcactus.families="${PROJECT_FAMILIES}" \
    -Dmaven.test.skip=true \
    generate-resources || exit 1

echo "┗━━━━━━━ PHASE 4 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"



##############################################################################
# END
##############################################################################

echo "┋"
echo "┋ Release of ${PROJECT_FAMILIES} complete!"
echo "┋"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
