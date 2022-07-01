#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

branch=""
scope=""
type="feature"

source telenav-library-functions.sh

get_scope_and_branch_arguments "$@"

if [[ ! $(git_check_branch_name "$scope" $type/"$branch")  ]]; then
    echo "Must be on $type/$branch branch to finish it"
    exit 1
fi

# 1. Merge branch to develop
# need to understand attempt-merge and finish-attempt-merge

# 2. Remove branch
# TODO

# 3. Switch back to develop
telenav-git-checkout.sh "$scope" develop || exit 1


cd_workspace
mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.branch-type=feature \
    -Dcactus.branch="$branch" \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":attempt-merge || exit 1
