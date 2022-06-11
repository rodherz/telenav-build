#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

#
# telenav-git-pull-request.sh [scope] [authentication-token] [title] [body]
#
# scope = { all, this, [family-name] }
#

if [[ ! "$#" -eq 4 ]]; then

    echo "telenav-git-pull-request.sh [scope] [authentication-token] [title] [body]"
    exit 1

fi

scope=$(repository_scope "$1")
authentication_token=$2
title=$3
body=$4

cd_workspace
mvn --quiet "$scope" -DauthenticationToken="$authentication_token" -Dtitle="$title" -Dbody="$body" com.telenav.cactus:cactus-build-maven-plugin:git-pull-request || exit 1
