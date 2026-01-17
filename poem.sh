declare config_format
declare -A style

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
        [title]=$(jq -r ".style.title" "$config_file")
        [content]=$(jq -r ".style.content" "$config_file")
    )
}

function print_poem {
    local index=$(shuf -i 0-80 -n 1)

    local book_file="$(dirname $0)/books/dao-de-jing.json"

    local book=$(jq -r ".book" "$book_file")
    local author=$(jq -r ".author" "$book_file")
    local title=$(jq -r ".text[$index] | to_entries[0] | .key" "$book_file")
    local content=$(jq ".text[$index] | to_entries[0] | .value" "$book_file" | unescape-quotes)
    
    declare -A placeholders=(
        ["#B"]="${style[book]}$book${style[default]}"
        ["#A"]="${style[author]}$author${style[default]}"
        ["#T"]="${style[title]}$title${style[default]}"
        ["#C"]="${style[content]}$content${style[default]}"
    )

    output=${style[default]}$config_format${style[default]}
    for placeholder in ${!placeholders[@]}; do
        output="${output//"$placeholder"/${placeholders[$placeholder]}}"
    done

    echo -e $output
}

populate_config
print_poem
