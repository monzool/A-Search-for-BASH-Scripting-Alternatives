#!/usr/bin/env bash

set -euo pipefail


# ① Enter script directory

readonly script_dir=$(dirname "$0")
cd "${script_dir}"


# ② Parse arguments

show_help() {
    cat << EOF
Usage: ./sample.bash [options]

Options:
    --list-dir <directory>      Directory to list. Default: test
    --no-color                  Disable color output. Default: false
    -h, --help                  Show help
EOF
}

option_list_dir="test"
option_color=true
setup_options() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --list-dir)
                option_list_dir="${2}"
                shift 2
                ;;

            --no-color)
                option_color=""
                shift
                ;;

            -h|--help|*)
                show_help
                exit 0
                ;;
        esac
    done
}


# ③ Get file list

file_list=()
get_file_list() {
    local dir="${1}"

    while IFS= read -r -d '' file; do
        file_list+=("${file}")
    done < <(find "${dir}" -type f -print0)
}


# ④ Split file names

get_extension() {
    local file="${1}"
    echo "${file##*.}"
}

get_filename() {
    local file="${1}"

    local base_name="${file##*/}"
    local file_name="${base_name%.*}"
    echo "${file_name}"
}


# ⑤ Categorize files by extension

declare -A file_categories
categorize_files_by_extension() {
    local file_list=("${@}")
    for file in "${file_list[@]}"; do
        local extension=$(get_extension "${file}")
        local filename=$(get_filename "${file}")

        if [[ -n "${file_categories[${extension}]-}" ]]; then
            file_categories["${extension}"]+=$'\n'"${filename}"
        else
            file_categories["${extension}"]="${filename}"
        fi
    done
}


# ⑥ Get a random number

get_random_number() {
    local upper="${1}"
    echo $((RANDOM % upper)) # [0; upper-1]
}


# ⑦ Search text in a file

search_text_in_file() {
    local file="${1}"
    local text="${2}"

    if grep -q "${text}" "${file}"; then
        echo "true"
    else
        echo "false"
    fi
}


# ⑧ Print results

readonly yellow="\e[33m"
readonly blue="\e[34m"
readonly light_red="\e[91m"
readonly light_green="\e[92m"
readonly light_cyan="\e[96m"
readonly magenta_bg="\e[45m"
readonly color_reset="\e[0m"

make_printer() {
    local fn_name=${1}
    local use_color=${2}

    local fn=$(
        cat <<EOF
        function ${fn_name}() {
            local color=\${1};
            local text="\${2}";

            if [[ -z "${use_color}" || "${use_color}" == "false" ]]; then
                printf "\${text}";
            else
                printf "\${color}%s${color_reset}" "\${text}";
            fi
        }
EOF
    )

    eval ${fn}
}

print_category() {
    local print_fn="${1}"
    declare -n file_category_ref="${2}"

    local filenames=( "${file_category_ref[@]}" )
    local count="${#filenames[@]}"

    printf "Extension: %s\n" "$( ${print_fn} "${blue}" "${extension}" )"
    printf "Count: %s\n" "$( ${print_fn} "${light_cyan}" "${count}" )"
    printf "Files:\n"
    for filename in "${filenames[@]}"; do
        printf "  %s\n" "$( ${print_fn} "${magenta_bg}" "${filename}" )"
    done
    printf "\n"
}

print_search() {
    local print_fn="${1}"
    declare -n search_result_ref="${2}"

    local search_file="${search_result_ref[0]}"
    local has_search_match="${search_result_ref[1]}"

    local found="Yes"
    local found_color="${light_green}"
    if [[ "${has_search_match}" != "true" ]]; then
        found="No"
        found_color="${light_red}"
    fi

    printf "Search result:\n"
    printf "  File: %s\n" "$( ${print_fn} "${yellow}" "${search_file}" )"
    printf "  Has search hit: %s\n" "$( ${print_fn} "${found_color}" "${found}" )"
}


# Main function

main() {
    setup_options ${@}
    make_printer color_print "${option_color}"
    get_file_list "${option_list_dir}"

    # Categories
    categorize_files_by_extension "${file_list[@]}"
    local file_category=
    deserialize_array() {
        local serialized="${1}"
        IFS=$'\n' read -r -d '' -a file_category <<< "${serialized}" || :
    }
    for extension in "${!file_categories[@]}"; do
        serialized="${file_categories[${extension}]}"
        deserialize_array "${serialized}"
        print_category color_print file_category
    done

    # Search
    local random_number=$(get_random_number "${#file_list[@]}")
    local search_file="${file_list[random_number]}"
    local has_search_match=$(search_text_in_file "${search_file}" "monzool")
    local search_result=( "${search_file}" "${has_search_match}" )
    print_search color_print search_result
}

main ${@}
