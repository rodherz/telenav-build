#!/bin/bash

set -x

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ -z "$TELENAV_WORKSPACE" ]]; then
    export TELENAV_WORKSPACE=$SCRIPT_PATH
fi

source "$TELENAV_WORKSPACE"/bin/telenav-library-functions.sh

branch_name=$1
caller=$2

check_tools "$caller"

#
# Set HOME for continuous integration build
#

if [[ "$caller" == "ci-build" ]]; then

    HOME=$(pwd)
    export HOME

fi

#
# Determine branch to set up
#

# shellcheck disable=SC2039
if [[ -z "$branch_name" ]]; then

    read -p "Branch [develop] ? " -r
    echo " "

    branch_name=$REPLY

    if [[ -z "$branch_name" ]]; then

        branch_name=develop

    fi
fi

#
# Initialize submodules
#

echo "Initializing submodules"
git submodule init || exit 1

#
# Clone repositories
#

echo "Cloning repositories"
if [[ "$caller" == "ci-build" ]]; then

    git submodule update --depth 1 || exit 1

else

    git submodule update || exit 1

fi

#
# Configure repositories
#

echo "Configuring repositories"
if [[ "$caller" == "ci-build" ]]; then

    echo "Creating temporary folder"
    export TMPDIR=./temporary/
    mkdir -p $TMPDIR

else

    echo "Configuring git repositories"
    git config pull.ff only || exit 1

    # shellcheck disable=SC2016
    git submodule foreach 'git config pull.ff only && echo "Configuring $name"' || exit 1

    echo "Initializing git flow"
    # shellcheck disable=SC2016
    git submodule foreach '[[ "$path" == *-assets ]] || git flow init -f -d --feature feature/ --bugfix bugfix/ --release release/ --hotfix hotfix/ --support support/ -t \"\"' || exit 1

fi

#
# Install superpoms
#

echo "Installing superpom"
mvn --batch-mode --quiet -f telenav-superpom/pom.xml clean install || exit 1

#
# Configure environment
#

echo "Configuring environment"
# shellcheck disable=SC2039
source ./source-me || exit 1

#
# Check out branch
#

echo "Checking out branch $branch_name"
if [[ $(git rev-parse --verify $branch_name) ]]; then

    echo "Checking out telenav-build:$branch_name"
    git checkout --quiet $branch_name || { echo "Ignoring: No branch of telenav-build called $branch_name"; exit 1; }

fi

echo "Checking out branches"
git submodule --quiet foreach "/bin/bash -c \"cd $TELENAV_WORKSPACE/\$path && if [[ \$path == *\"assets\" ]]; then git checkout publish; else git checkout $branch_name; fi\"" || exit 1

#
# Build cactus
#

clean_caches
clean_maven_repository_telenav

if [[ -d cactus ]]; then

    echo " "
    echo "Building cactus"
    mvn --batch-mode --quiet -f cactus clean install || exit 1

fi

#
# Build
#

echo "Building"
mvn --batch-mode --quiet clean install || exit 1
echo "Done."
