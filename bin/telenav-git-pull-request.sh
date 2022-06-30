#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 4 ]]; then

    echo "telenav-git-pull-request.sh [scope] [authentication-token] [title] [body]"
    exit 1

fi

scope=$1
authentication_token=$2
title=$3
body=$4

cd_workspace
mvn --quiet \
    "$(resolve_scope_switches "$scope")" \
    -Dcactus.authentication-token="$authentication_token" \
    -Dcactus.title="$title" \
    -Dcactus.body="$body" \
    com.telenav.cactus:cactus-maven-plugin:"$(cactus_version)":git-pull-request || exit 1
