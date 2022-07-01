
usage()
{
    echo "$(script) [project-family] [release-version]"
    exit 1
}

#
# Check that there are two arguments and get them
#

if [[ ! "$#" -eq 2 ]]; then
    usage
fi

scope=$1
version=$2
resolved_families=()
export scope
export version
export resolved_families

#
# Check that the scope is a single project family
#

resolve_scope "$scope"

# shellcheck disable=SC2154
if [[ ! "$resolved_scope" == "family" ]]; then
    usage
fi

if [[ ! ${#resolved_families[@]} -eq 1 ]]; then
    usage
fi

family=${resolved_families[0]}
export family
