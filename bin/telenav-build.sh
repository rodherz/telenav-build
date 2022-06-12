#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source telenav-library-functions.sh

echo " "
check_tools
require_variable TELENAV_WORKSPACE "Must set TELENAV_WORKSPACE"
cd_workspace

allowed_scopes=(all this kivakit mesakit lexakai cactus-build)
allowed_build_types=(compile release release-local tools dmg javadoc lexakai-documentation help)
allowed_build_modifiers=(attach-jars clean clean-all clean-sparkling debug debug-tests dry-run no-javadoc no-tests quick-tests quiet verbose single-threaded tests)

build_types=()
build_modifiers=()

for argument in "$@"
do
    if [[ " ${allowed_scopes[*]} " =~ ${argument} ]]; then
        build_scope=$argument
    fi
    if [[ " ${allowed_build_types[*]} " =~ ${argument} ]]; then
        build_types+=("$argument")
    fi
    if [[ " ${allowed_build_modifiers[*]} " =~ ${argument} ]]; then
        build_modifiers+=("$argument")
    fi
done

if [[ -z "$build_scope" ]]; then
    build_scope="all"
fi

if [[ ${#build_types[@]} -eq 0 ]]; then
    build_types=(default)
fi

if [[ ${#build_types[@]} -gt 1 ]]; then
    echo "No more than one build type is allowed: ${build_types[*]}"
    exit 1
fi

usage()
{
    echo " "
    echo "Usage: telenav-build.sh [build-scope] [build-type] [build-modifiers]*"
    echo " "
    echo "  BUILD SCOPES"
    echo " "
    echo "                all - build all projects"
    echo "       cactus-build - build only the cactus-build project"
    echo "            kivakit - build only the kivakit project"
    echo "            lexakai - build only the lexakai project"
    echo "            mesakit - build only the mesakit project"
    echo "               this - build only the project in the current folder"
    echo " "
    echo "  BUILD TYPES"
    echo " "
    echo "           [default] - compile, shade and run all tests"
    echo "             compile - compile and shade (no tests)"
    echo "                 dmg - compile, shade, run tests, build tools, build dmg"
    echo "             javadoc - compile and build javadoc"
    echo "             release - clean-sparkling, compile, run tests, build javadoc, attach jars, sign artifacts and deploy to OSSRH"
    echo "       release-local - clean-sparkling, compile, run tests, build javadoc, attach jars, sign artifacts and deploy to local Maven repository"
    echo "               tools - compile, shade, run tests, build tools"
    echo " "
    echo "  BUILD MODIFIERS"
    echo " "
    echo "         attach-jars - attach source and javadoc jars to maven artifacts"
    echo "               clean - prompt to remove cached and temporary files"
    echo "           clean-all - prompt to remove cached and temporary files and kivakit artifacts from ~/.m2"
    echo "     clean-sparkling - prompt to remove entire .m2 repository and all cached and temporary files"
    echo "               debug - turn maven debug mode on"
    echo "         debug-tests - stop in debugger on surefire tests"
    echo "             dry-run - show maven command line but don't build"
    echo "          no-javadoc - do not build javadoc"
    echo "            no-tests - do not run tests"
    echo "         quick-tests - run only quick tests"
    echo "             verbose - build with full output"
    echo "     single-threaded - build with only one thread"
    echo "               tests - run all tests"
    echo " "
    exit 1
}

maven_switches=(--no-transfer-progress --batch-mode)
build_arguments=()
build_modifiers+=(quiet)
threads="12"

case "${build_types[0]}" in

    "compile")
        build_arguments+=(clean compile)
        build_modifiers+=(multi-threaded no-tests shade no-javadoc)
        ;;

    "default")
        build_arguments+=(clean install)
        build_modifiers+=(multi-threaded tests shade no-javadoc)
        ;;

    "dmg")
        build_arguments+=(clean install)
        build_modifiers+=(multi-threaded tests shade tools dmg no-javadoc)
        ;;

    "help")
        usage
        ;;

    "javadoc")
        build_arguments+=(clean install)
        build_modifiers+=(multi-threaded no-tests javadoc)
        ;;

    "lexakai-documentation")
        build_modifiers+=(lexakai-documentation)
        ;;

    "release")
        build_arguments+=(clean deploy)
        build_modifiers+=(multi-threaded clean-sparkling javadoc lexakai-documentation tests attach-jars sign-artifacts)
        ;;

    "release-local")
        build_arguments+=(clean install)
        build_modifiers+=(multi-threaded clean-sparkling javadoc lexakai-documentation tests attach-jars sign-artifacts)
        ;;

    "test")
        build_arguments+=(clean install)
        build_modifiers+=(single-threaded tests no-javadoc)
        ;;

    "tools")
        build_arguments+=(clean install)
        build_modifiers+=(multi-threaded tests shade tools no-javadoc)
        ;;

    "verbose")
        build_modifiers=("${build_modifiers[@]//quiet}")
        ;;

    *)
        echo "Unrecognized build type: ${build_types[0]}"
        usage

esac

for modifier in "${build_modifiers[@]}"; do

    case "$modifier" in

        "attach-jars")
            # To attach jars, we have to build the javadoc for the jars
            build_arguments+=(-P attach-jars)
            ;;

        "clean")
            clean_script="kivakit-clean.sh"
            ;;

        "clean-all")
            clean_script="kivakit-clean-all.sh"
            ;;

        "clean-sparkling")
            clean_script="kivakit-clean-sparkling.sh"
            ;;

        "debug")
            maven_switches+=(--debug)
            ;;

        "lexakai-documentation")
            build_arguments+=(com.telenav.cactus:cactus-build-maven-plugin:lexakai)
            ;;

        "debug-tests")
            maven_switches+=(-Dmaven.surefire.debug)
            ;;

        "dmg")
            maven_switches+=(-P dmg)
            ;;

        "docker")
            maven_switches+=(-P docker)
            ;;

        "javadoc")
            build_arguments+=(javadoc:aggregate)
            ;;

        "multi-threaded")
            ;;

        "no-javadoc")
            maven_switches+=("-Dmaven.javadoc.skip=true")
            ;;

        "no-tests")
            maven_switches+=("-Dmaven.test.skip=true")
            ;;

        "quick-tests")
            maven_switches+=(-P test-quick)
            ;;

        "quiet")
            maven_switches+=(-q "-Dsurefire.printSummary=false" "-DKIVAKIT_LOG_LEVEL=Warning")
            ;;

        "shade")
            maven_switches+=(-P shade)
            ;;

        "dry-run")
            dry_run="true"
            ;;

        "sign-artifacts")
            build_arguments+=(-P sign-artifacts)
            ;;

        "single-threaded")
            threads="1"
            ;;

        "tests")
            ;;

        "tools")
            maven_switches+=(-P tools)
            ;;

        *)
            echo " "
            echo "Build modifier '$modifier' is not recognized"
            usage
            ;;

    esac
    shift

done

if [ -z "$KIVAKIT_DEBUG" ]; then
    KIVAKIT_DEBUG="!Debug"
fi

maven_switches+=(-DKIVAKIT_DEBUG=\""$KIVAKIT_DEBUG"\")
maven_switches+=(--threads "$threads")

build=$(project_build)

echo " "
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Building $build"
echo "┋"
echo "┋          Build-Scope: ${build_scope}"
echo "┋           Build-Type: ${build_types[0]}"
echo "┋      Build-Modifiers: ${build_modifiers[*]}"
echo "┋   Maven Command Line: mvn  ${maven_switches[*]} ${build_arguments[*]}"
echo "┋            Workspace: $TELENAV_WORKSPACE"
echo "┋"

if [ -z "$dry_run" ]; then

    if [ -n "$clean_script" ]; then
        bash "$clean_script"
    fi

    # shellcheck disable=SC2086
    "$M2_HOME/bin/mvn" "$(resolve_scope $build_scope)" ${maven_switches[*]} ${build_arguments[*]} 2>&1

    if [ "${PIPESTATUS[0]}" -ne "0" ]; then
        echo "Build failed."
        exit 1
    fi

fi

echo "┋"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Built $build"
echo " "
