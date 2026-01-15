#!/usr/bin/env bash
set -e

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TEST_ROOT="$(realpath "$SCRIPT_ROOT/../src")"
BUILD_ROOT="$(realpath "$SCRIPT_ROOT/../Build" 2>/dev/null || echo "$SCRIPT_ROOT/../Build")"

if [[ -d "$BUILD_ROOT" ]]; then
    rm -rf "$BUILD_ROOT"
fi
mkdir -p "$BUILD_ROOT"

echo "Building from $TEST_ROOT"
echo "Output to      $BUILD_ROOT"
echo ""

for folder in "$TEST_ROOT"/*/; do
    [[ -d "$folder" ]] || continue

    package_name="$(basename "$folder")"
    echo "== Package: $package_name =="

    find "$folder" -type f | while read -r src; do
        rel="${src#$folder}"
        dst="$BUILD_ROOT/$rel"
        dst_dir="$(dirname "$dst")"

        mkdir -p "$dst_dir"

        echo "Processing: $rel"
        echo "  > Copying"
        cp -f "$src" "$dst"
    done

    echo ""
done

echo "Build complete."

TEST_ROOT="$(realpath "$SCRIPT_ROOT/../test")"
BUILD_ROOT="$(realpath "$SCRIPT_ROOT/../Build" 2>/dev/null || echo "$SCRIPT_ROOT/../Build")"

echo "Building from $TEST_ROOT"
echo "Output to      $BUILD_ROOT"
echo ""

for folder in "$TEST_ROOT"/*/; do
    [[ -d "$folder" ]] || continue

    package_name="$(basename "$folder")"
    echo "== Package: $package_name =="

    find "$folder" -type f | while read -r src; do
        rel="${src#$folder}"
        dst="$BUILD_ROOT/$rel"
        dst_dir="$(dirname "$dst")"

        mkdir -p "$dst_dir"

        echo "Processing: $rel"
        echo "  > Copying"
        cp -f "$src" "$dst"
    done

    echo ""
done

echo "Build complete."
