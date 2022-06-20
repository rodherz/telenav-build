################ VARIABLES ################################################################################################

export NORMAL='\033[0m'
export ATTENTION='\033[1;32m'

if [[ "$OSTYPE" == "darwin"* ]]; then

    export HISTCONTROL=ignoreboth:erasedups

fi

################ BUILD ##################################################################################################

cd_workspace()
{
    if [[ "$TELENAV_WORKSPACE" == "" ]]; then
        echo "TELENAV_WORKSPACE must be defined"
        exit 1
    fi

    cd "$TELENAV_WORKSPACE" || exit 1
}

show_workspace()
{
    echo " "
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ Telenav Workspace ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┋"
    echo "┋        TELENAV_WORKSPACE: $TELENAV_WORKSPACE"

    if [[ -d "$KIVAKIT_HOME" ]]; then

        echo "┋"
        echo "┋             KIVAKIT_HOME: $KIVAKIT_HOME"
        echo "┋          KIVAKIT_VERSION: $KIVAKIT_VERSION"
        echo "┋       KIVAKIT_CACHE_HOME: $KIVAKIT_CACHE_HOME"
        echo "┋      KIVAKIT_ASSETS_HOME: $KIVAKIT_ASSETS_HOME"
        echo "┋     KIVAKIT_JAVA_OPTIONS: $KIVAKIT_JAVA_OPTIONS"

    fi

    if [[ -d "$MESAKIT_HOME" ]]; then

        echo "┋"
        echo "┋             MESAKIT_HOME: $MESAKIT_HOME"
        echo "┋          MESAKIT_VERSION: $MESAKIT_VERSION"
        echo "┋       MESAKIT_CACHE_HOME: $MESAKIT_CACHE_HOME"
        echo "┋      MESAKIT_ASSETS_HOME: $MESAKIT_ASSETS_HOME"
        echo "┋     MESAKIT_JAVA_OPTIONS: $MESAKIT_JAVA_OPTIONS"

    fi

    echo "┋"
    echo "┋                JAVA_HOME: $JAVA_HOME"
    echo "┋"
    echo "┋                  M2_HOME: $M2_HOME"
    echo "┋"
    perl -e 'print "┋                     PATH: " . join("\n┋                           ", split(":", $ENV{"PATH"})) . "\n"'
    echo "┋"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo " "
}

scoped_folders()
{
    pattern=$1

    if [[ $pattern == "all" ]]; then
        pattern="kivakit|mesakit|cactus|lexakai"
    fi

    cd_workspace
    folders=()
    for folder in */; do
        if [[ "$folder" =~ $pattern ]]; then
            if [[ ! "$folder" == *"-assets"* ]]; then
                folders+=("$folder")
            fi
        fi
    done
}

resolved_scope=""
resolved_family=""
export resolved_scope
export resolved_family

resolve_scope()
{
    scope=$1

    case "${scope}" in

    "all")
        resolved_scope="all"
        resolved_family=""
        ;;

    "all-project-families")
        resolved_scope="all-project-families"
        resolved_family=""
        ;;

    "this")
        resolved_scope="just-this"
        resolved_family=""
        ;;

    "just-this")
        resolved_scope="just-this"
        resolved_family=""
        ;;

    *)
        if [[ "${scope}" == "" ]]; then

            if [[ "${TELENAV_SCOPE}" == "" ]]; then
                resolved_scope="all-project-families"
                resolved_family=""
            else
                resolved_scope="$TELENAV_SCOPE"
                resolved_family="$TELENAV_FAMILY"
            fi

        else
            resolved_scope="family"
            resolved_family="${scope}"
        fi
        ;;

    esac
}

check_tools()
{
    caller=$1

    if [[ ! "$caller" == "ci-build" ]]; then
        require_variable M2_HOME "Must set M2_HOME"
        require_variable JAVA_HOME "Must set JAVA_HOME"
    fi

    #
    # Check tools
    #

    # 1) Parse Java version from output like: openjdk version "17.0.3" 2022-04-19 LTS
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

    # 2) Parse Maven version from output like: Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
    maven_version=$(mvn -version 2>&1 | awk -F ' ' '/Apache Maven/ {print $3}')

    # 3) Parse Git version from output like: git version 2.36.1
    git_version=$(git --version 2>&1 | awk -F' ' '{print $3}')

    # 4) Parse Git flow version from output like: 1.12.3 (AVH Edition)
    if [[ ! "$caller" == "ci-build" ]]; then
        git_flow_version=$(git flow version)
    fi

    # Check Java version
    if [[ ! "$java_version" == "17."* ]]; then
        echo "Telenav Open Source projects require Java 17"
        echo "To install: https://jdk.java.net/archive/"
        exit 1
    else
        echo "Java $java_version"
    fi

    # Check Maven version
    if [[ ! $maven_version =~ 3\.8\.[5-9][0-9]* ]]; then
        echo "Telenav Open Source projects require Maven 3.8.5 or higher"
        echo "To install: https://maven.apache.org/download.cgi"
        exit 1
    else
        echo "Maven $maven_version"
    fi

    # Check Git version
    if [[ ! $git_version =~ 2\.3[0-9]\. ]]; then
        echo "Telenav Open Source projects require Git version 2.30 or higher"
        exit 1
    else
        echo "Git $git_version"
    fi

    # Check Git Flow version

    if [[ ! "$caller" == "ci-build" ]]; then
        if [[ ! $git_flow_version =~ 1.1[2-9]\..*\(AVH\ Edition\) ]]; then
            echo "Telenav Open Source projects require Git Flow (AVH Edition) version 1.12 or higher"
            echo "To install on macOS: brew install git-flow-avh"
            exit 1
        else
            echo "Git Flow $git_flow_version"
        fi
    fi
}

project_version()
{
    project_home=$1

    pushd "$project_home" 1>/dev/null || exit 1
    mvn -q -DforceStdout org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version || exit 1
    popd 1>/dev/null || exit 1
}

project_name()
{
    project_home=$1

    # shellcheck disable=SC2046
    # shellcheck disable=SC2005
    echo $(basename -- "$project_home")
}

project_build()
{
    project_home=$1

    build_properties="$KIVAKIT_HOME/kivakit-core/target/classes/build.properties"

    if [ -e "$build_properties" ]; then

        build_name=$(property_value "$build_properties" build-name)
        build_number=$(property_value "$build_properties" build-number)
        build_date=$(property_value "$build_properties" build-date)

        branch_name=$(git_branch_name "$project_home")

        echo "$branch_name build #$build_number [$build_name] on $build_date"

    fi
}

show_version()
{
    project_home=$1
    project_name=$(project_name "$project_home")
    project_version=$(project_version "$project_home")

    echo -e "${ATTENTION}$project_name $project_version $(project_build "$project_home")${NORMAL}"
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


clean_caches()
{
    if allow_cleaning; then

        KIVAKIT_VERSION=$(project_version kivakit)
        clean_cache "$HOME/.kivakit/$KIVAKIT_VERSION"

        MESAKIT_VERSION=$(project_version mesakit)
        clean_cache "$HOME/.mesakit/$MESAKIT_VERSION"

    fi
}

clean_cache()
{
    cache=$1

    if [ -d "$cache" ]; then

        if yes_no "┋ Remove ALL cached files in $cache"; then

            rm -rf "$cache"

        fi
    fi
}

clean_maven_repository()
{
    if allow_cleaning; then

        project_home=$1
        name=$(basename -- "$project_home")

        if yes_no "┋ Remove all $name artifacts from $HOME/.m2/repository"; then

            rm -rf "$HOME/.m2/repository/com/telenav/$name"

        fi

    fi
}

clean_maven_repository_telenav()
{
    if allow_cleaning; then

        if [[ -d "$HOME/.m2/repository/com/telenav" ]]; then

            if yes_no "┋ Remove all Telenav artifacts from $HOME/.m2/repository"; then
                rm -rf "$HOME/.m2/repository/com/telenav"
            fi

        fi
    fi
}

clean_temporary_files()
{
    project_home=$1

    if allow_cleaning; then

        if yes_no "┋ Remove transient files from $project_home tree"; then

        # shellcheck disable=SC2038
        find "$project_home" \( -name \.DS_Store -o -name \.metadata -o -name \.classpath -o -name \.project -o -name \*\.hprof -o -name \*~ \) | xargs rm

        fi
    fi
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

################ GIT ################################################################################################

git_branch_name()
{
    project_home=$1

    cd "$project_home" || exit
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    echo "$branch_name"
}

################ UTILITY ################################################################################################

script()
{
    # shellcheck disable=SC2046
    # shellcheck disable=SC2005
    echo $(basename -- "$0")
}

usage()
{
    argument_help=$1

    echo "Usage: $(script) $argument_help"
    exit 1
}

require_variable()
{
    variable=$1
    argument_help=$2

    if [[ -z "${!variable}" ]]; then

        if [[ "$argument_help" == *"["* ]]; then
            usage "$argument_help"
        else
            echo "$argument_help"
        fi

        exit 1

    fi
}

require_folder()
{
    variable=$1
    argument_help=$2

    if [[ ! -e "${!variable}" ]]; then

        echo "Folder '${!variable}' does not exist"
        exit 1

    fi
}

append_path()
{
    export PATH="$PATH:$1"
}

prepend_path()
{
    export PATH="$1:$PATH"
}

system_variable()
{
    variable=$1
    value=$2
    temporary="${TMPDIR}export.txt"

    echo "export $variable=\"$value\"" >"$temporary"
    # shellcheck disable=SC1090
    source "$temporary"

    if is_mac; then

        launchctl setenv "$variable" "$value"

    fi
}

is_mac()
{
    if [[ "$OSTYPE" == "darwin"* ]]; then
        true
    else
        false
    fi
}

lexakai()
{
    lexakai_download_version="1.0.7"
    lexakai_download_name="lexakai-1.0.7.jar"

    lexakai_downloads="$HOME/.lexakai/downloads"

    if [[ "$lexakai_download_version" == *"SNAPSHOT"* ]]; then

        lexakai_snapshot_repository="https://s01.oss.sonatype.org/content/repositories/snapshots/com/telenav/lexakai/lexakai"
        lexakai_url="$lexakai_snapshot_repository/${lexakai_download_version}/${lexakai_download_name}"
        lexakai_jar="${lexakai_downloads}/${lexakai_download_name}"

    else

        lexakai_url="https://repo1.maven.org/maven2/com/telenav/lexakai/lexakai/${lexakai_download_version}/lexakai-${lexakai_download_version}.jar"
        lexakai_jar="${lexakai_downloads}/lexakai-${lexakai_download_version}.jar"

    fi

    mkdir -p "${lexakai_downloads}"

    if [ ! -e "$lexakai_jar" ]; then

        echo "$lexakai_jar doesn't exist"

        wget $lexakai_url --output-document="$lexakai_jar"

    fi

    # -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=1044
    echo "java -jar $lexakai_jar $*"

    # shellcheck disable=SC2068
    java -jar "$lexakai_jar" $@
}

property_value()
{
    file=$1
    key=$2

    # shellcheck disable=SC2002
    cat "$file" | grep "$key" | cut -d'=' -f2 | xargs echo
}

bracket()
{
    name=$1
    shift

    echo " " && echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫ \$name && $*" && echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && echo " "

}

yes_no()
{
    if [ -z "${NO_PROMPT}" ]; then

        prompt=$1

        echo " "
        read -p "$prompt (y/n)? " -n 1 -r

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            true
        else
            false
        fi

    else

        true

    fi
}

#####################################################################################################################
