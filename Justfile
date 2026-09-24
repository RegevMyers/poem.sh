set shell := [ "bash", "-cu" ]

@__default:
    just --list --unsorted
    echo

@install:
    sudo install -D --mode=755 poem.sh "/usr/bin/poem"
    sudo install -D --mode=755 default-config.json "$XDG_DATA_HOME/poem/default-config.json"
    sudo install -D --mode=755 books/* -t "$XDG_DATA_HOME/poem/books"

