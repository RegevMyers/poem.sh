jq -r ".[$(shuf -i 0-80 -n 1)] | to_entries.[0] | \"\u001b[1m\(.key)\u001b[0m\n\n\(.value)\"" data/gia-fu-feng.json
