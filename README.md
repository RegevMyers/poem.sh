# poem.sh

`poem.sh` is a bash script to format and print poems.

## Usage

Run `poem.sh` to print a random poem from `books/` to the terminal.

Use `--book` to specify the book name (`fzf`), `--name` or `--index` to specify the poem.

Use `--read-book` to read an entire book poem-by-poem.

## Config

The output format and be configured using the `poem.config` file found at `$XDG_CONFIG_HOME/poem/`.

In the "format" value you can use placeholders as follows:

- `#B` - Book Name
- `#A` - Author
- `#R` - Translator
- `#T` - Title
- `#C` - Content

You may additionally specify a style for each.

> See `default-config.json` for an example

## Books

Each book is a `json` file in `books/`, in the following format:

``` json
{
  "book": "Book Name",
  "author": "Author",
  "translator": "Translator"
  "text": [
    {
      "text1_title": "text1_content"
    }
  ]
}
```
