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
echo mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.target-branch="$branch" \
    -Dcactus.update-root=true \
    -Dcactus.create-branches=false \
    -Dcactus.push=false \
    -Dcactus.permit-local-changes=true \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":checkout || exit 1
