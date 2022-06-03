#!/bin/bash

branch_name=$1
caller=$2

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

echo "Cloning git repositories"
if [[ "$caller" == "ci-build" ]]; then

    git submodule update --depth 1 || exit 1

else

    git submodule update || exit 1

fi

#
# Configure repositories
#

echo "Configuring build"

if [[ "$caller" == "ci-build" ]]; then

    echo "Creating temporary folder"
    export TMPDIR=./temporary/
    mkdir $TMPDIR

else

    echo "Configuring git repositories"
    git config pull.ff only || exit 1

    # shellcheck disable=SC2016
    git submodule foreach 'git config pull.ff only && echo "Configuring $name"' || exit 1

    echo "Initializing git flow"
    # shellcheck disable=SC2016
    git submodule foreach '[[ "$path" == *-assets* ]] || git flow init -f -d --feature feature/ --bugfix bugfix/ --release release/ --hotfix hotfix/ --support support/ -t ''' || exit 1

fi

#
# Configure environment
#

echo "Configuring environment"
# shellcheck disable=SC2039
source ./source-me || exit 1

#
# Check out branch
#

echo "Switching to branch $branch_name"
export branch_name
# shellcheck disable=SC2016
git submodule --quiet foreach 'echo $path' | grep assets | xargs -I FOLDER echo "cd FOLDER && git checkout publish"
# shellcheck disable=SC2016
git submodule --quiet foreach 'echo $path' | grep -v assets | xargs -I FOLDER echo "cd FOLDER && git checkout $branch_name"

#
# Build
#

echo "Building"
mvn --batch-mode -f telenav-superpom/pom.xml clean install
mvn --batch-mode clean install

#
# Setup complete
#

echo "Done."
