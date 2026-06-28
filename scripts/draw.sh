#!/usr/bin/env bash
# Regenerate keymap-drawer yaml + svg from the keymap.
#
# keymap-drawer emits UTF-8 without an XML encoding declaration, so standalone
# viewers that assume Latin-1 mangle umlauts (ä -> Ã¤). This script converts all
# non-ASCII characters to XML numeric entities and prepends an XML declaration,
# making the SVG render correctly in any viewer. Run after editing the keymap.
set -euo pipefail
cd "$(dirname "$0")/.."

CFG=keymap_drawer.config.yaml
KEYMAP=config/crosses.keymap
INFO=config/info.json
LAYOUT=gggw_crosses_36_layout
OUT=keymap-drawer

uvx --from keymap-drawer keymap -c "$CFG" parse -z "$KEYMAP" > "$OUT/crosses.yaml"
uvx --from keymap-drawer keymap -c "$CFG" draw -j "$INFO" -l "$LAYOUT" "$OUT/crosses.yaml" > "$OUT/crosses.svg"

python3 - "$OUT/crosses.svg" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = "".join(c if ord(c) < 128 else "&#%d;" % ord(c) for c in s)
if not s.startswith("<?xml"):
    s = '<?xml version="1.0" encoding="UTF-8"?>\n' + s
open(p, "w", encoding="utf-8").write(s)
PY

echo "wrote $OUT/crosses.yaml and $OUT/crosses.svg (ASCII-safe)"
