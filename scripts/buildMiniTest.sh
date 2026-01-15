#!/usr/bin/env bash
set -e

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

build_from_root() {
    local TEST_ROOT
    TEST_ROOT="$(realpath "$1")"
    local BUILD_ROOT="$SCRIPT_ROOT/../Build"

    if [[ -d "$BUILD_ROOT" ]]; then
        rm -rf "$BUILD_ROOT"
    fi
    mkdir -p "$BUILD_ROOT"

    echo "Building from $TEST_ROOT"
    echo "Output to      $BUILD_ROOT"
    echo ""

    for folder in "$TEST_ROOT"/*/; do
        [[ -d "$folder" ]] || continue

        local package_name
        package_name="$(basename "$folder")"
        echo "== Package: $package_name =="

        find "$folder" -type f | while IFS= read -r src; do
            rel="${src#$folder}"
            dst="$BUILD_ROOT/$rel"
            dst_dir="$(dirname "$dst")"

            mkdir -p "$dst_dir"

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
}

build_from_root "$SCRIPT_ROOT/../src"

build_from_root "$SCRIPT_ROOT/../test"
