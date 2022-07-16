#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

scope=""
branch=""
type="bugfix"

source telenav-library-functions.sh

get_scope_and_branch_arguments "$@"

if [[ ! $(git_check_branch_name "$scope" develop)  ]]; then
    echo "Must be on 'develop' branch to start a $type"
    exit 1
fi

git_checkout_branch "$scope" "$type/$branch" true || exit 1
