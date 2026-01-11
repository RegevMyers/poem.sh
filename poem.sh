function print_poem {
  local title_style="\u001b[1m"
  local reset_style="\u001b[0m"

  local index=$(shuf -i 0-80 -n 1)
  
  local format="\"$title_style\(.key)\n\n$reset_style\(.value)\""

  jq -r ".[$index] | to_entries.[0] | $format" data/gia-fu-feng.json
}

print_poem

