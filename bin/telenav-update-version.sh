#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

if [[ ! "$#" -eq 3 ]]; then

    echo "telenav-update-version.sh [scope] [replacement-version] [replacement-branch-name]"
    exit 1

fi

resolve_scope "$1"
replacement_version=$2
replacement_branch_name=$3

if [[ "$resolved_family" == "" ]]; then

    echo "Must specify a project family: all, all-project-families, kivakit, mesakit or lexakai"
    exit 1

fi

cd_workspace
mvn --quiet \
    -Dcactus.scope="$resolved_scope" \
    -Dcactus.family="$resolved_family" \
    -Dcactus.replacement-version="$replacement_version" \
    -Dcactus.replacement-branch-name="$replacement_branch_name" \
    com.telenav.cactus:cactus-maven-plugin:1.4.12:replace || exit 1
