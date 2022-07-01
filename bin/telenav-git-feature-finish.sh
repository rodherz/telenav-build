#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

branch=""
scope=""
get_scope_and_branch_arguments "$@"

# 1. Merge branch to develop

# 2. Remove branch

# 3. Switch back to develop

cd_workspace
mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.branch-type=feature \
    -Dcactus.branch="$branch" \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":attempt-merge || exit 1
