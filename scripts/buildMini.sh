#!/usr/bin/env bash
set -e

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TEST_ROOT="$(realpath "$SCRIPT_ROOT/../src")"
BUILD_ROOT="$SCRIPT_ROOT/../Build"

if [[ -d "$BUILD_ROOT" ]]; then
    rm -rf "$BUILD_ROOT"
fi
mkdir -p "$BUILD_ROOT"

echo "Building from $TEST_ROOT"
echo "Output to      $BUILD_ROOT"
echo ""

for folder in "$TEST_ROOT"/*/; do
    [[ -d "$folder" ]] || continue

    folder_root="$folder"
    package_name="$(basename "$folder_root")"
    echo "== Package: $package_name =="

    find "$folder_root" -type f | while IFS= read -r src; do
        rel="${src#$folder_root}"
        dst="$BUILD_ROOT/$rel"
        dst_dir="$(dirname "$dst")"

        if [[ ! -d "$dst_dir" ]]; then
            mkdir -p "$dst_dir"
        fi

        echo "Processing: $rel"

        header="$(head -n 3 "$src" 2>/dev/null || true)"

        if echo "$header" | grep -q -- "--:Minify:--"; then
            echo "  > Minifying"
            luamin -f "$src" > "$dst"
        else
            echo "  > Copying"
            cp -f "$src" "$dst"
        fi
    done

    echo ""
done

echo "Build complete."
