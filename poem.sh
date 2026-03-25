#!/usr/bin/env bash

declare config_format
declare -A style
declare -A args

function unescape-quotes {
    sed -E 's|^"(.*)"$|\1|g' | sed -E 's|\\"|"|g'
}

function populate_config {
    config_file="${XDG_CONFIG_HOME:-$HOME/.config}/poem/config.json"
    
    if [ ! -f $config_file ]; then
        cp "$(dirname $0)/default-config.json" "$config_file"
    fi

    config_format=$(jq ".format" "$config_file" | unescape-quotes)
    style=(
        [default]=$(jq -r ".style.default" "$config_file")
        [book]=$(jq -r ".style.book" "$config_file")
        [author]=$(jq -r ".style.author" "$config_file")
        [translator]=$(jq -r ".style.translator" "$config_file")
        [title]=$(jq -r ".style.title" "$config_file")
        [content]=$(jq -r ".style.content" "$config_file")
    )
}

function print_poem {
    # TODO: match author too
    if [[ ${args[book]} ]]; then
        for book in "$(dirname $0)"/books/*; do
            current_book=$(jq -r ".book" "$book")
            if [[ $current_book = ${args[book]} ]]; then
                book_file=$book
                break
            fi
        done
        if [[ -z $book_file ]]; then
            echo -e "\033[00m[ \033[31m!\033[00m ] Book '${args[book]}' not found"
            exit 1
        fi
    else
        book_file="$(dirname $0)/books/dao-de-jing.json"  #TODO: Make random
    fi

    local n_texts=$(jq -r ".text | length - 1" "$book_file")
    
    if [[ ${args[index]} && ${args[name]} ]]; then
        echo -e "\033[00m[ \033[31m!\033[00m ] Can't specify both '--index' and '--name'"
        exit 1
    fi

    if [[ ${args[index]} ]]; then
        index=$((${args[index]} - 1))

        if [[ $index -lt 0 ]]; then
            echo -e "\033[00m[ \033[31m!\033[00m ] Index ${args[index]} is too small"
            exit 1
        fi

        if [[ $index -gt $n_texts ]]; then
            echo -e "\033[00m[ \033[31m!\033[00m ] Index ${args[index]} too large; There are only $n_texts texts"
            exit 1
        fi
    else
        index=$(shuf -i 0-$n_texts -n 1)
    fi

    if [[ ${args[name]} ]]; then
        index=$(jq -r "first(.text | to_entries[] | select(.value | has(\"${args[name]}\")) | .key)" $book_file)

        if [[ -z $index ]]; then
            echo -e "\033[00m[ \033[31m!\033[00m ] Text '${args[name]}' not found"
            exit 1
        fi
    fi

    local book=$(jq ".book" "$book_file" | unescape-quotes)
    local author=$(jq ".author" "$book_file" | unescape-quotes)
    local translator=$(jq ".translator" "$book_file" | unescape-quotes)
    local title=$(jq ".text[$index] | to_entries[0] | .key" "$book_file" | unescape-quotes)
    local content=$(jq ".text[$index] | to_entries[0] | .value" "$book_file" | unescape-quotes)
    
    declare -A placeholders=(
        ["#B"]="${style[book]}$book${style[default]}"
        ["#A"]="${style[author]}$author${style[default]}"
        ["#R"]="${style[translator]}$translator${style[default]}"
        ["#T"]="${style[title]}$title${style[default]}"
        ["#C"]="${style[content]}$content${style[default]}"
    )

    output="${style[default]}$config_format${style[default]}"
    for placeholder in ${!placeholders[@]}; do
        output="${output//"$placeholder"/${placeholders[$placeholder]}}"
    done

    echo -e $output
}

function parse_command_line {
    vars=$(getopt -o '' --long 'book:,author:,name:,index:' -n 'poem' -- "$@") || exit 1
    eval set -- "$vars"
    
    while true; do
        case "$1" in
            '--book')
                args[book]="$2"
                shift 2
                ;;
            '--author')
                args[author]="$2"
                shift 2
                ;;
            '--name')
                args[name]="$2"
                shift 2
                ;;
            '--index')
                args[index]="$2"
                shift 2
                ;;
            '--')
                shift 1
                break
                ;;
            *)
                echo -e "\033[00m[ \033[31m!\033[00m ] Bad parameter '$1'"
                ;;
        esac
    done
}

function main {
    parse_command_line "$@"
    populate_config
    print_poem
}

main "$@"
