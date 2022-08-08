#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ -z "$TELENAV_GIT_AUTHENTICATION_TOKEN" ]]; then

    echo "Must set TELENAV_GIT_AUTHENTICATION_TOKEN environment variable to create pull requests"
    exit 1

fi

if [[ "$#" -eq 0 ]]; then

    branch_name=$(branch_name "$KIVAKIT_HOME")

elif [[ "$#" -eq 1 ]]; then

    branch_name=$1

else

    usage "[branch_name]?"

fi

cactus_all git-merge-pull-request \
    -Dcactus.authentication-token="$TELENAV_GIT_AUTHENTICATION_TOKEN" \
    -Dcactus.branch-name="$branch_name" || exit 1
