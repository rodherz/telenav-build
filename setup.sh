#!/bin/bash

# Determine the branch to set up
branch_name=$1
build=$2

# shellcheck disable=SC2039
if [[ -z "$branch_name" ]]; then

    read -p "Branch [develop] ? " -r
    echo " "

    branch_name=$REPLY

    if [[ -z "$branch_name" ]]; then

        branch_name=develop

    fi
fi

echo "Setting up to build branch $branch_name"
git submodule init || exit 1

echo "Cloning git repositories"
git submodule update || exit 1

if [[ "$build" == "ci-build" ]]; then

    export TMPDIR=temporary
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

echo "Configuring environment"
# shellcheck disable=SC2039
source ./source-me || exit 1

echo "Switching to branch $branch_name"
kivakit-git-switch-branch.sh "$branch_name" || exit 1

echo "Installing super pom"
mvn -f telenav-superpom/pom.xml clean install

echo "Running master build"
mvn clean install

echo "Done."
