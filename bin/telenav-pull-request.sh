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

if [[ ! "$#" -eq 2 ]]; then

    usage "[title] [body]"

fi

title=$1
body=$2

cactus_all git-pull-request \
    -Dcactus.authentication-token="$TELENAV_GIT_AUTHENTICATION_TOKEN" \
    -Dcactus.title="$title" \
    -Dcactus.body="$body" \
    -Dcactus.reviewers="rodherz,sunshine-syz,timboudreau,wenjuanj,jonathanl-telenav,haifeng-z" || exit 1
