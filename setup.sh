#!/bin/bash

branch_name=$1
caller=$2

#
# Set HOME for continuous integration build
#

if [[ "$caller" == "ci-build" ]]; then

    HOME=$(pwd)
    export HOME

fi

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
if [[ ! "$caller" == "ci-build" ]]; then
    git_flow_version=$(git flow version)
fi

# Check Java version
if [[ ! "$java_version" == "17."* ]]; then
    echo "Telenav Open Source projects require Java 17"
    echo "To install: https://jdk.java.net/archive/"
    exit 1
else
    echo "Java $java_version"
fi

# Check Maven version
if [[ ! $maven_version =~ 3\.8\.[5-9][0-9]* ]]; then
    echo "Telenav Open Source projects require Maven 3.8.5 or higher"
    echo "To install: https://maven.apache.org/download.cgi"
    exit 1
else
    echo "Maven $maven_version"
fi

# Check Git version
if [[ ! $git_version =~ 2\.3[0-9]\. ]]; then
    echo "Telenav Open Source projects require Git version 2.30 or higher"
    exit 1
else
    echo "Git $git_version"
fi

# Check Git Flow version

if [[ ! "$caller" == "ci-build" ]]; then
    if [[ ! $git_flow_version =~ 1.1[2-9]\..*\(AVH\ Edition\) ]]; then
        echo "Telenav Open Source projects require Git Flow (AVH Edition) version 1.12 or higher"
        echo "To install on macOS: brew install git-flow-avh"
        exit 1
    else
        echo "Git Flow $git_flow_version"
    fi
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
# Install super-poms
#

echo "Installing super-pom"
mvn --batch-mode -f telenav-superpom/pom.xml clean install || exit 1

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
git checkout --quiet $branch_name || echo "Ignoring: No branch of telenav-build called $branch_name" || exit 1
# shellcheck disable=SC2016
git submodule --quiet foreach '[[ ! "$path" == *-assets ]] || git checkout publish' || exit 1
git submodule --quiet foreach "[[ \"\$path\" == *-assets ]] || git checkout $branch_name" || exit 1

#
# Clear cache folders
#

project_version()
{
    project_home=$1

    pushd "$project_home" 1>/dev/null || exit 1
    mvn -q -DforceStdout org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version || exit 1
    popd 1>/dev/null || exit 1
}

KIVAKIT_VERSION=$(project_version kivakit)
echo "Removing ~/.kivakit/$KIVAKIT_VERSION"
rm -rf "$HOME/.kivakit/$KIVAKIT_VERSION"

MESAKIT_VERSION=$(project_version mesakit)
echo "Removing $HOME/.mesakit/$MESAKIT_VERSION"
rm -rf "$HOME/.mesakit/$MESAKIT_VERSION"

#
# Build cactus
#

if [[ -d cactus-build ]]; then

    echo "Building cactus"
    mvn --batch-mode -f cactus-build clean install || exit 1

fi

#
# Build
#

echo "Building"
mvn --batch-mode clean install || exit 1

#
# Done
#

echo "Done."
