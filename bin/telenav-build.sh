#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source "${TELENAV_WORKSPACE}/bin/telenav-library-functions.sh"
source "${TELENAV_WORKSPACE}/bin/telenav-build-library-functions.sh"

telenav_build_check_prerequisites

cd_workspace

build_types=()
build_modifiers=()

telenav_build_parse_arguments "$@"

maven_switches=(--no-transfer-progress)
build_arguments=()
build_modifiers+=(quiet)
threads="12"

telenav_build_parse_build_types

build_javadoc=false

telenav_build_parse_build_modifiers

if [ -z "$KIVAKIT_DEBUG" ]; then
    KIVAKIT_DEBUG="\!Debug"
fi

maven_switches+=(-DKIVAKIT_DEBUG=\""$KIVAKIT_DEBUG"\")
maven_switches+=(--threads "$threads")

build=$(project_build)

telenav_resolve_build_folders

echo " "
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Building $build"
echo "┋"
# shellcheck disable=SC2154
echo "┋          Build-Scope: ${build_scope}"
# shellcheck disable=SC2154
echo "┋        Build-Folders: ${build_folders[*]}"
echo "┋           Build-Type: ${build_types[0]}"
echo "┋      Build-Modifiers: ${build_modifiers[*]}"
echo "┋   Maven Command Line: mvn  ${maven_switches[*]} ${build_arguments[*]}"
echo "┋            Workspace: $TELENAV_WORKSPACE"
echo "┋"

if [[ "$build_javadoc" == "true" ]]; then
    bash telenav-build-javadoc.sh "${build_scope}"
fi

if [ -z "$dry_run" ]; then

    if [ -n "$clean_script" ]; then
        bash "$clean_script"
    fi

    # shellcheck disable=SC2086
    if [[ ${#build_arguments[@]} -gt 0 ]]; then

        # shellcheck disable=SC2154
        for folder in "${build_folders[@]}"
        do
            :
            telenav_run_maven_build "$folder"
        done

    fi

fi

echo "┋"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Built $build"
echo " "
