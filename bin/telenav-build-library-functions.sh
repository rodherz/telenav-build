#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

allowed_scopes=(all this telenav-superpom kivakit mesakit lexakai cactus)
allowed_build_types=(compile release release-local tools dmg javadoc lexakai-documentation help)
allowed_build_modifiers=(attach-jars clean clean-all clean-sparkling debug debug-tests dry-run no-javadoc no-tests quick-tests quiet verbose single-threaded tests)

telenav_build_check_prerequisites()
{
    echo " "
    check_tools
    require_variable TELENAV_WORKSPACE "Must set TELENAV_WORKSPACE"
}

telenav_resolve_build_folders()
{
    case "${build_scope}" in

        "all")
            build_folders=("$TELENAV_WORKSPACE/telenav-superpom" "$TELENAV_WORKSPACE/cactus" "$TELENAV_WORKSPACE/kivakit" "$TELENAV_WORKSPACE/lexakai" "$TELENAV_WORKSPACE"/mesakit)
            ;;

        "this")
            build_folders=("$TELENAV_WORKSPACE/telenav-superpom" "$TELENAV_WORKSPACE/cactus" .)
            ;;

        *)
            # shellcheck disable=SC2034
            build_folders=("$TELENAV_WORKSPACE/telenav-superpom" "$TELENAV_WORKSPACE/cactus" "$TELENAV_WORKSPACE/${build_scope}")
            ;;

    esac
}


telenav_run_maven_build()
{
    folder="$1"

    echo "┋ Building $folder"
    cd "$folder" || exit 1

    # shellcheck disable=SC2086
    "$M2_HOME/bin/mvn" "$(resolve_scope $build_scope)" ${maven_switches[*]} ${build_arguments[*]} 2>&1

    if [ "${PIPESTATUS[0]}" -ne "0" ]; then
        echo "Build failed."
        exit 1
    fi
}

telenav_build_parse_build_modifiers()
{
    for modifier in "${build_modifiers[@]}"; do

        case "$modifier" in

            "attach-jars")
                # To attach jars, we have to build the javadoc for the jars
                build_arguments+=(-P attach-jars)
                ;;

            "clean")
                clean_script="kivakit-clean.sh"
                ;;

            "clean-sparkling")
                # shellcheck disable=SC2034
                clean_script="kivakit-clean-sparkling.sh"
                ;;

            "debug")
                maven_switches+=(--debug)
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

            "documentation")
                maven_switches+=(-P release)
                ;;

            "dry-run")
                # shellcheck disable=SC2034
                dry_run="true"
                ;;

            "javadoc")
                # shellcheck disable=SC2034
                build_javadoc=true
                ;;

            "lexakai-documentation")
                build_arguments+=(com.telenav.cactus:cactus-maven-plugin:lexakai)
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
                maven_switches+=(--quiet "-Dsurefire.printSummary=false" "-DKIVAKIT_LOG_LEVEL=Warning")
                ;;

            "sign-artifacts")
                build_arguments+=(-P sign-artifacts)
                ;;

            "single-threaded")
                # shellcheck disable=SC2034
                threads="1"
                ;;

            "tests")
                ;;

            "tools")
                maven_switches+=(-P tools)
                ;;

            "verbose")
                build_modifiers=("${build_modifiers[@]//quiet}")
                ;;

            *)
                echo " "
                echo "Build modifier '$modifier' is not recognized"
                telenav_build_usage
                ;;

        esac
        shift

    done
}

telenav_build_parse_arguments()
{
    arguments=("$@")

    for argument in "${arguments[@]}"
    do
        if [[ " ${allowed_scopes[*]} " =~ ${argument} ]]; then
            build_scope=$argument
        elif [[ " ${allowed_build_types[*]} " =~ ${argument} ]]; then
            build_types+=("$argument")
        elif [[ " ${allowed_build_modifiers[*]} " =~ ${argument} ]]; then
            build_modifiers+=("$argument")
        else
            echo "Invalid argument: ${argument}"
            exit 1
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
}

telenav_build_parse_build_types()
{
    case "${build_types[0]}" in

        "compile")
            build_arguments+=(clean compile)
            build_modifiers+=(multi-threaded no-tests no-javadoc)
            ;;

        "default")
            build_arguments+=(clean install)
            build_modifiers+=(multi-threaded tests no-javadoc)
            ;;

        "dmg")
            build_arguments+=(clean install)
            build_modifiers+=(multi-threaded tests tools dmg no-javadoc)
            ;;

        "help")
            telenav_build_usage
            ;;

        "javadoc")
            build_modifiers+=(multi-threaded no-tests javadoc)
            ;;

        "lexakai-documentation")
            build_modifiers+=(lexakai-documentation)
            ;;

        "release")
            build_arguments+=(clean install com.telenav.cactus:cactus-maven-plugin:check-published nexus-staging:deploy)
            build_modifiers+=(single-threaded clean-sparkling documentation attach-jars sign-artifacts)
            ;;

        "release-local")
            build_arguments+=(clean install)
            build_modifiers+=(single-threaded clean-sparkling documentation tests attach-jars sign-artifacts)
            ;;

        "test")
            build_arguments+=(clean install)
            build_modifiers+=(single-threaded tests no-javadoc)
            ;;

        "tools")
            build_arguments+=(clean install)
            build_modifiers+=(multi-threaded tests tools no-javadoc)
            ;;

        *)
            echo "Unrecognized build type: ${build_types[0]}"
            telenav_build_usage

    esac
}

telenav_build_usage()
{
    echo " "
    echo "Usage: telenav-build.sh [build-scope] [build-type] [build-modifiers]*"
    echo " "
    echo "  BUILD SCOPES"
    echo " "
    echo "                all - build all projects"
    echo "             cactus - build only the cactus project"
    echo "            kivakit - build only the kivakit project"
    echo "            lexakai - build only the lexakai project"
    echo "            mesakit - build only the mesakit project"
    echo "               this - build only the project in the current folder"
    echo " "
    echo "  BUILD TYPES"
    echo " "
    echo "           [default] - compile and run all tests"
    echo "             compile - compile (no tests)"
    echo "                 dmg - compile, run tests, build tools, build dmg"
    echo "             javadoc - build javadoc documentation"
    echo "             release - clean-sparkling, compile, run tests, build javadoc, attach jars, sign artifacts and deploy to OSSRH"
    echo "       release-local - clean-sparkling, compile, run tests, build javadoc, attach jars, sign artifacts and deploy to local Maven repository"
    echo "               tools - compile, run tests, build tools"
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
    echo "             javadoc - build javadoc documentation"
    echo "          no-javadoc - do not build javadoc"
    echo "            no-tests - do not run tests"
    echo "         quick-tests - run only quick tests"
    echo "             verbose - build with full output"
    echo "     single-threaded - build with only one thread"
    echo "               tests - run all tests"
    echo " "
    exit 1
}
