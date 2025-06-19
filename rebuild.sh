#!/bin/sh
set -eu

FRAGMENTS_DIR="fragments"
HTML_DIR="html"
OUTPUT_FILE="index.html"

awk -v bootstrap="$HTML_DIR/bootstrap.html" '
  {
    if (match($0, /\{\{BOOTSTRAP_CDN_LINK\}\}/)) {
      while ((getline line < bootstrap) > 0) print line
      close(bootstrap)
      next
    }
    print
  }
' "$HTML_DIR/head.html" >"$OUTPUT_FILE"

printf '  <ul>\n' >>"$OUTPUT_FILE"

find "$FRAGMENTS_DIR" -name '*.html' -print0 | sort -zr | while IFS= read -r -d '' FILE; do
    FILENAME=$(basename "$FILE")
    DATE=${FILENAME%%-*}-$(echo "$FILENAME" | cut -d'-' -f2-3)
    TITLE=$(echo "$FILENAME" | cut -d'-' -f4- | sed 's/\.html$//' | tr '-' ' ')

    awk -v title="$TITLE" -v date="$DATE" -v file="$FILE" '
    {
      gsub(/\{\{TITLE\}\}/, title)
      gsub(/\{\{DATE\}\}/, date)
      if (/\{\{CONTENT\}\}/) {
        sub(/\{\{CONTENT\}\}/, "")
        print
        while ((getline line < file) > 0) print line
        close(file)
      } else print
    }
  ' "$HTML_DIR/content.html" >>"$OUTPUT_FILE"
done

printf '  </ul>\n' >>"$OUTPUT_FILE"
cat "$HTML_DIR/tail.html" >>"$OUTPUT_FILE"
