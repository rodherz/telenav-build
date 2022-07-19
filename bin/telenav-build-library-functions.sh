#!/bin/bash

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#
#  © 2011-2021 Telenav, Inc.
#  Licensed under Apache License, Version 2.0
#
#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

source "${TELENAV_WORKSPACE}/bin/telenav-library-functions.sh"

allowed_scopes=(all this telenav-superpom kivakit mesakit lexakai)
allowed_build_types=(compile release release-local tools dmg javadoc lexakai-documentation help)
allowed_build_modifiers=(attach-jars clean clean-forced clean-sparkling debug debug-tests dry-run no-javadoc no-tests quick-tests quiet verbose single-threaded tests)

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
            build_folders=("$TELENAV_WORKSPACE/telenav-superpom" "$TELENAV_WORKSPACE/kivakit" "$TELENAV_WORKSPACE/lexakai" "$TELENAV_WORKSPACE/mesakit")
            ;;

        "this")
            build_folders=("$TELENAV_WORKSPACE/telenav-superpom" .)
            ;;

        *)
            # shellcheck disable=SC2034
            build_folders=("$TELENAV_WORKSPACE/telenav-superpom" "$TELENAV_WORKSPACE/${build_scope}")
            ;;

    esac
}

telenav_end_build()
{
    echo "┋"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Built $build"
    echo " "
}

telenav_start_build()
{
    build=$(project_build)

    folder_list=""
    for folder in "${build_folders[@]}"
    do
        :
        folder_list="$folder_list\n┋              -"
        folder_list="$folder_list $folder"
    done

    echo " "
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Building $build"
    echo "┋"
    # shellcheck disable=SC2154
    echo "┋            Build Scope: ${build_scope}"
    echo "┋             Build Type: ${build_types[*]}"
    echo "┋        Build Modifiers: ${build_modifiers[*]}"
    echo "┋"
    # shellcheck disable=SC2154
    echo -e "┋          Build Folders:\n┋$folder_list"
    echo "┋"
    echo "┋         Build Switches: ${build_switches[*]}"
    # shellcheck disable=SC2154
    echo "┋   Build Scope Switches: ${resolved_scope_switches[*]}"
    echo "┋        Build Arguments: ${build_arguments[*]}"
    echo "┋"
    echo "┋              Workspace: $TELENAV_WORKSPACE"
    echo "┋"
    # shellcheck disable=SC2154
    echo "┋     mvn ${resolved_scope_switches[*]} ${build_switches[*]} ${build_arguments[*]}"
    echo "┋"
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
                clean_script="telenav-clean.sh"
                ;;

            "clean-forced")
                clean_script="telenav-clean-forced.sh"
                ;;

            "clean-force")
                clean_script="telenav-clean-forced.sh"
                ;;

            "clean-sparkling")
                # shellcheck disable=SC2034
                clean_script="telenav-clean-sparkling.sh"
                ;;

            "debug")
                build_switches+=(--debug)
                ;;

            "debug-tests")
                build_switches+=(-Dmaven.surefire.debug)
                ;;

            "dmg")
                build_switches+=(-P dmg)
                ;;

            "docker")
                build_switches+=(-P docker)
                ;;

            "documentation")
                build_switches+=(-P release)
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
                build_switches+=("-Dmaven.javadoc.skip=true")
                ;;

            "no-tests")
                build_switches+=("-Dmaven.test.skip=true")
                ;;

            "quick-tests")
                build_switches+=(-P test-quick)
                ;;

            "quiet")
                build_switches+=(--quiet "-Dsurefire.printSummary=false" "-DKIVAKIT_LOG_LEVEL=Warning")
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
                build_switches+=(-P tools)
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
    echo "               clean - prompt to remove cached and temporary files and telenav artifacts from ~/.m2"
    echo "        clean-forced - remove cached and temporary files and telenav artifacts from ~/.m2"
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

################ CLEAN ################################################################################################

allow_cleaning()
{
    if [ -z "$ALLOW_CLEANING" ]; then

        ALLOW_CLEANING=true

    fi

    if [ "$ALLOW_CLEANING" == "true" ]; then

        return 0

    else

        return 1

    fi
}

telenav_clean_caches()
{
    if allow_cleaning; then

        KIVAKIT_VERSION=$(project_version kivakit)
        telenav_clean_cache "$HOME/.kivakit/$KIVAKIT_VERSION"

        MESAKIT_VERSION=$(project_version mesakit)
        telenav_clean_cache "$HOME/.mesakit/$MESAKIT_VERSION"

    fi
}

telenav_clean_caches_forced()
{
    if allow_cleaning; then

        KIVAKIT_VERSION=$(project_version kivakit)
        telenav_clean_cache_forced "$HOME/.kivakit/$KIVAKIT_VERSION"

        MESAKIT_VERSION=$(project_version mesakit)
        telenav_clean_cache_forced "$HOME/.mesakit/$MESAKIT_VERSION"

    fi
}

telenav_clean_cache()
{
    cache=$1

    if [ -d "$cache" ]; then

        if yes_no "┋ Remove ALL cached files in $cache"; then

            telenav_clean_cache_forced "$cache"

        fi
    fi
}

telenav_clean_cache_forced()
{
    cache=$1
    rm -rf "$cache"
}

telenav_clean_maven_repository()
{
    if allow_cleaning; then

        project_home=$1
        name=$(basename -- "$project_home")

        if yes_no "┋ Remove all $name artifacts from $HOME/.m2/repository"; then

            telenav_clean_maven_repository_forced "$name"

        fi

    fi
}

telenav_clean_maven_repository_forced()
{
    name=$1
    rm -rf "$HOME/.m2/repository/com/telenav/$name"
}

telenav_clean_maven_repository_telenav()
{
    if allow_cleaning; then

        if [[ -d "$HOME/.m2/repository/com/telenav" ]]; then

            if yes_no "┋ Remove all Telenav artifacts from $HOME/.m2/repository"; then

                rm -rf "$HOME/.m2/repository/com/telenav"

            fi

        fi
    fi
}

telenav_clean_temporary_files()
{
    project_home=$1

    if allow_cleaning; then

        if yes_no "┋ Remove transient files from $project_home tree"; then

            telenav_clean_temporary_files_forced "$project_home"

        fi
    fi
}

telenav_clean_temporary_files_forced()
{
    project_home=$1

    # shellcheck disable=SC2038
    find "$project_home" \( -name \.DS_Store -o -name \.metadata -o -name \.classpath -o -name \.project -o -name \*\.hprof -o -name \*~ \) | xargs rm
}

remove_maven_repository()
{
    if allow_cleaning; then

        if [ -d "$HOME/.m2/repository" ]; then

            if yes_no "┋ Remove ALL artifacts in $HOME/.m2/repository"; then

                rm -rf "$HOME/.m2/repository"

            fi
        fi
    fi
}
