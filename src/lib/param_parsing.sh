# shellcheck shell=bash

set_repo_path_arg() {
    # check CLI arguments and environment variables to determine repository path
    #
    # expected params: either `from_positional` or `from_option`, depending on whether the CLI
    #     parameter is a positional or option flag
    #
    # precondition: an `args` associative array should be defined, with OPTIONAL repo path arg name
    # postcondition: new `repository_path` variable will be defined

    local arg_name
    local human_friendly_arg_name

    case "${1}" in
        from_option)
            arg_name="--repo"
            human_friendly_arg_name="--repo"
        ;;
        from_positional)
            arg_name="repository_path"
            human_friendly_arg_name="REPOSITORY_PATH"  # same as what help messages display
        ;;
        *)
            panic "expected only from_option or from_positional as parameters"
        ;;
    esac

    repository_path="${args["${arg_name}"]:-}"
    if [ "${repository_path}" == "" ]; then
        repository_path="${GRAMPS_DEFAULT_REPO:-}"
    fi

    test "${repository_path}" != "" || panic "Must specify a repository path via ${human_friendly_arg_name} parameter or GRAMPS_DEFAULT_REPO env variable."

    if [ "${repository_path}" == "." ]; then
        repository_path="$(readlink --canonicalize "${repository_path}")"
    fi
}
