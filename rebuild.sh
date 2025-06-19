#!/bin/sh
set -eu

FRAGMENTS_DIR="fragments"
HTML_DIR="html"

HEAD_HTML_TEMPLATE="$HTML_DIR/head.html"
TAIL_HTML_TEMPLATE="$HTML_DIR/tail.html"
CONTENT_HTML_TEMPLATE="$HTML_DIR/content.html"
BOOTSTRAP_HTML_TEMPLATE="$HTML_DIR/bootstrap.html"

OUTPUT_FILE="index.html"

BOOTSTRAP_CDN_LINK=$(cat "$BOOTSTRAP_HTML_TEMPLATE")
HEAD_HTML=$(sed "s|{{BOOTSTRAP_CDN_LINK}}|$BOOTSTRAP_CDN_LINK|" "$HEAD_HTML_TEMPLATE")

printf '%s\n' "$HEAD_HTML" > "$OUTPUT_FILE"
printf '  <ul>\n' >> "$OUTPUT_FILE"

for FILE in $(ls "$FRAGMENTS_DIR"/*.html | sort -r); do
  FILENAME=$(basename "$FILE")
  DATE=$(printf '%s' "$FILENAME" | cut -d'-' -f1-3)
  TITLE=$(printf '%s' "$FILENAME" | cut -d'-' -f4- | sed 's/\.html$//' | tr '-' ' ')
  CONTENT=$(cat "$FILE")

  CONTENT_HTML=$(cat "$CONTENT_HTML_TEMPLATE" \
    | sed "s|{{TITLE}}|$TITLE|" \
    | sed "s|{{DATE}}|$DATE|" \
    | sed "s|{{CONTENT}}|$CONTENT|")

  printf '%s\n' "$CONTENT_HTML" >> "$OUTPUT_FILE"
done

printf '  </ul>\n' >> "$OUTPUT_FILE"
cat "$TAIL_HTML_TEMPLATE" >> "$OUTPUT_FILE"
