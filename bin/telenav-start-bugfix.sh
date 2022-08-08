#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

branch_type=bugfix
branch_name=$(get_optional_argument "Branch name? " "$@")

if [[ -z "$branch_name" ]]; then
    usage "[branch_name]"
else
    cd_workspace
    cbranch --new "$branch_type/$branch_name" || exit 1
fi
