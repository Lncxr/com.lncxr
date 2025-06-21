#!/bin/sh
set -eu

DEPENDENCIES_DIR="dependencies"
FRAGMENTS_DIR="fragments"
HTML_DIR="html"
OUTPUT_FILE="index.html"

# Sanity check

[ -d "$DEPENDENCIES_DIR" ] || { echo "Missing $DEPENDENCIES_DIR"; exit 1; }
[ -d "$FRAGMENTS_DIR" ] || { echo "Missing $FRAGMENTS_DIR"; exit 1; }
[ -d "$HTML_DIR" ] || { echo "Missing $HTML_DIR"; exit 1; }

# Inline dependencies

awk -v depdir="$DEPENDENCIES_DIR" '
  {
    if ($0 ~ /<!-- CDN -->/) {
      cmd = "find \"" depdir "\" -type f | sort"
      while ((cmd | getline depfile) > 0) {
        while ((getline dep_line < depfile) > 0) print dep_line
        close(depfile)
      }
      close(cmd)
      next
    }
    print
  }
' "$HTML_DIR/head.html" >"$OUTPUT_FILE"

printf '  <ul>\n' >>"$OUTPUT_FILE"

find "$FRAGMENTS_DIR" -name '*.html' | sort -r | while read -r FILE; do
    FILENAME=$(basename "$FILE")
    DATE="${FILENAME%%-*}-$(echo "$FILENAME" | cut -d'-' -f2-3)"
    TITLE="$(echo "$FILENAME" | cut -d'-' -f4- | sed 's/\.html$//' | tr '-' ' ')"

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