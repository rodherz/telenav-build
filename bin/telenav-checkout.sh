#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

branch_name=$(get_optional_argument "Branch name? " "$@")

if [[ -z "$branch_name" ]]; then
    usage "[branch_name]"
fi

cactus_all checkout \
    -Dcactus.target-branch="$branch_name" \
    -Dcactus.update-root=true \
    -Dcactus.create-branches="false" \
    -Dcactus.push=false \
    -Dcactus.permit-local-changes=true || exit 1
