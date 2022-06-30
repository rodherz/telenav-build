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

cd_workspace
git_repository_initialize
mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.operation=start \
    -Dcactus.branch-type=feature \
    -Dcactus.branch="$branch" \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":git-flow || exit 1
