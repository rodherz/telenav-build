#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

scope=""
branch=""
resolved_scope_switches=()
get_scope_and_branch_arguments "$@"

cd_workspace
resolve_scope_switches "$scope"
mvn --quiet \
    "${resolved_scope_switches[@]}" \
    -Dcactus.target-branch="$branch" \
    -Dcactus.update-root=true \
    -Dcactus.create-branches=false \
    -Dcactus.push=false \
    -Dcactus.permit-local-changes=true \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":checkout || exit 1
