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
mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.operation=finish \
    -Dcactus.branch-type=bugfix \
    -Dcactus.branch="$branch" \
    com.telenav.cactus:cactus-maven-plugin:1.4.12:git-flow || exit 1
