#!/bin/sh
set -e

SRC="public/japan_munis_simplified.geojson"
DST="public/munis"

# 県別ファイル
for code in $(seq -w 01 47); do
  mapshaper "$SRC" \
    -filter "String(N03_007).slice(0,2) === '$code'" \
    -simplify 2% keep-shapes \
    -o "${DST}/pref_${code}.geojson"
done

# 県境インデックス（1 行で）
mapshaper "$SRC" \
  -each 'pref_code=String(N03_007).slice(0,2)' -dissolve2 pref_code \
  -simplify 2% keep-shapes -o "${DST}/pref_index.geojson"

echo "✅ Prefecture files & index generated in ${DST}"
