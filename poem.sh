function build_format {
  local title_style="\u001b[1m"
  local content_style="\u001b[0m"
  local separator='\n\n'

  local title="\(.key)"
  local content="\(.value)"

  local format="\"$title_style$title$separator$content_style$content\""

  echo $format
}

function print_poem {
  local index=$(shuf -i 0-80 -n 1)
  jq -r ".Content.[$index] | to_entries.[0] | $(build_format)" $(dirname $0)/books/dao-de-jing.json
}

print_poem

