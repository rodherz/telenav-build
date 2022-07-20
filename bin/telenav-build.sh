#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source "${TELENAV_WORKSPACE}/bin/telenav-build-library-functions.sh"

threads="12"
build_javadoc=false

build_types=()
build_modifiers=()
build_arguments=()
build_switches=(--no-transfer-progress)
build_modifiers=(quiet)
build_scope=""

resolved_scope_switches=()

export build_types
export build_modifiers

cd_workspace

telenav_build_check_prerequisites
telenav_build_parse_arguments "$@"
telenav_build_parse_build_types
telenav_build_parse_build_modifiers

resolve_scope_switches "$build_scope"

if [ -z "$KIVAKIT_DEBUG" ]; then
    KIVAKIT_DEBUG="\!Debug"
fi

build_switches+=(-DKIVAKIT_DEBUG=\""$KIVAKIT_DEBUG"\")
build_switches+=(--threads "$threads")

telenav_start_build

if [[ "$build_javadoc" == "true" ]]; then
    bash telenav-build-javadoc.sh "${build_scope}"
fi

if [ -z "$dry_run" ]; then

    if [ -n "$clean_script" ]; then
        bash "$clean_script"
    fi

    echo "┋ Building"

    mvn --quiet -f telenav-superpom/pom.xml clean install

    # shellcheck disable=SC2086
    # shellcheck disable=SC2154
    mvn ${resolved_scope_switches[*]} ${build_switches[*]} ${build_arguments[*]} 2>&1
    if [ "${PIPESTATUS[0]}" -ne "0" ]; then
        echo "Build failed."
        exit 1
    fi

fi

telenav_end_build
