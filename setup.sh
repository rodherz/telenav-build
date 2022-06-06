#!/bin/bash

branch_name=$1
caller=$2

#
# Check tools
#

# 1) Parse Java version from output like: openjdk version "17.0.3" 2022-04-19 LTS
java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

# 2) Parse Maven version from output like: Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
maven_version=$(mvn -version 2>&1 | awk -F ' ' '/Apache Maven/ {print $3}')

# 3) Parse Git version from output like: git version 2.36.1
git_version=$(git --version 2>&1 | awk -F' ' '{print $3}')

# 4) Parse Git flow version from output like: 1.12.3 (AVH Edition)
git_flow_version=$(git flow version)

# Check Java version
if [[ ! "$java_version" == "17."* ]]; then
    echo "Telenav Open Source projects require Java 17"
    echo "To install: https://jdk.java.net/archive/"
    exit 1
else
    echo "Using Java $java_version"
fi

# Check Maven version
if [[ ! $maven_version =~ 3\.8\.[5-9][0-9]* ]]; then
    echo "Telenav Open Source projects require Maven 3.8.5 or higher"
    echo "To install: https://maven.apache.org/download.cgi"
    exit 1
else
    echo "Using Maven $maven_version"
fi

# Check Git version
if [[ ! $git_version =~ 2\.3[0-9]\. ]]; then
    echo "Telenav Open Source projects require Git version 2.30 or higher"
    exit 1
else
    echo "Using Git $git_version"
fi

if [[ ! $git_flow_version =~ 1.1[2-9]\..*\(AVH\ Edition\) ]]; then
    echo "Telenav Open Source projects require Git Flow (AVH Edition) version 1.12 or higher"
    echo "To install on macOS: brew install git-flow-avh"
    exit 1
else
    echo "Using Git Flow $git_flow_version"
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
    git submodule foreach '[[ "$path" == *-assets* ]] || git flow init -f -d --feature feature/ --bugfix bugfix/ --release release/ --hotfix hotfix/ --support support/ -t \"\"' || exit 1

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
git checkout --quiet $branch_name || echo "Ignoring: No branch of telenav-build called $branch_name"
export branch_name
# shellcheck disable=SC2016
git submodule --quiet foreach 'echo $path' | grep assets | xargs -I FOLDER echo "cd FOLDER && git checkout publish"
# shellcheck disable=SC2016
git submodule --quiet foreach 'echo $path' | grep -v assets | xargs -I FOLDER echo "cd FOLDER && git checkout $branch_name"

#
# Build
#

HOME=$(pwd)
export HOME

echo "Installing superpom"
mvn --batch-mode -f telenav-superpom/pom.xml clean install

if [[ -d cactus-build ]]; then

    echo "Building maven plugin"
    mvn --batch-mode -f cactus-build/maven-plugin clean install

fi

echo "Building"
mvn --batch-mode clean install

#
# Setup complete
#

echo "Done."
