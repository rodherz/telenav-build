#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 2 ]]; then

    echo "telenav-git-start-hotfix.sh [scope] [branch-name]"

fi

scope=$(resolve_scope "$1")
branch_name=$2

cd_workspace
mvn --quiet "$scope" -Doperation=start -Dbranch-type=hotfix -Dbranch-name="$branch_name" com.telenav.cactus:cactus-build-maven-plugin:git-flow || exit 1
