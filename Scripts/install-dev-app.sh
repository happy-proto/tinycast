#!/bin/bash
# Build the complete fork stack and install its single Dev app copy.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ "$(git branch --show-current)" != "integration/current" ]; then
    echo "✗ switch to integration/current before installing the Dev app" >&2
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "✗ commit or remove working-tree changes before installing the integrated Dev app" >&2
    exit 1
fi

source_commit=$(git rev-parse HEAD)
source_app="$PWD/build/DerivedData/Build/Products/Debug/Tinycast Dev.app"
installed_app="/Applications/Tinycast Dev.app"
stage_dir=$(mktemp -d /tmp/tinycast-dev-install.XXXXXX)
staged_app="$stage_dir/Tinycast Dev.app"
previous_app="$stage_dir/Previous Tinycast Dev.app"
replacement_started=0

cleanup() {
    status=$?
    if [ "$status" -ne 0 ] && [ "$replacement_started" -eq 1 ]; then
        pkill -TERM -f 'Tinycast Dev.app/Contents/MacOS/Tinycast Dev$' 2>/dev/null || true
        if [ -d "$installed_app" ]; then
            mv "$installed_app" "$stage_dir/Failed Tinycast Dev.app"
        fi
        if [ -d "$previous_app" ]; then
            mv "$previous_app" "$installed_app"
            open "$installed_app" 2>/dev/null || true
            echo "✗ installation failed; restored the previous Dev app" >&2
        fi
    fi
    if [ -d "$stage_dir" ]; then
        rm -r -- "$stage_dir"
    fi
    exit "$status"
}
trap cleanup EXIT

xcodebuild -project Tinycast.xcodeproj -scheme Tinycast -configuration Debug \
    -derivedDataPath build/DerivedData build

test -d "$source_app"
ditto "$source_app" "$staged_app"

bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' \
    "$staged_app/Contents/Info.plist")
if [ "$bundle_id" != "com.tinycast.app.dev" ]; then
    echo "✗ unexpected bundle id: $bundle_id" >&2
    exit 1
fi
codesign --verify --deep --strict "$staged_app"

pkill -TERM -f 'Tinycast Dev.app/Contents/MacOS/Tinycast Dev$' 2>/dev/null || true
for _ in 1 2 3 4 5; do
    if ! pgrep -f 'Tinycast Dev.app/Contents/MacOS/Tinycast Dev$' >/dev/null; then
        break
    fi
    sleep 1
done
if pgrep -f 'Tinycast Dev.app/Contents/MacOS/Tinycast Dev$' >/dev/null; then
    echo "✗ a Tinycast Dev process did not stop" >&2
    exit 1
fi

if [ -d "$installed_app" ]; then
    mv "$installed_app" "$previous_app"
fi
replacement_started=1
mv "$staged_app" "$installed_app"
open "$installed_app"

processes=""
for _ in 1 2 3 4 5; do
    processes=$(pgrep -fl 'Tinycast Dev.app/Contents/MacOS/Tinycast Dev$' || true)
    process_count=$(printf '%s\n' "$processes" | sed '/^$/d' | wc -l | tr -d ' ')
    if [ "$process_count" = "1" ]; then
        break
    fi
    sleep 1
done

if [ "$process_count" != "1" ] || ! printf '%s\n' "$processes" \
    | grep -F '/Applications/Tinycast Dev.app/Contents/MacOS/Tinycast Dev' >/dev/null
then
    echo "✗ the installed Dev app is not the only running instance" >&2
    exit 1
fi

codesign --verify --deep --strict "$installed_app"
cmp "$source_app/Contents/MacOS/Tinycast Dev" \
    "$installed_app/Contents/MacOS/Tinycast Dev"

if [ -d "$previous_app" ]; then
    user_home=$(dscl . -read "/Users/$(id -un)" NFSHomeDirectory | awk '{print $2}')
    case "$user_home" in /Users/*) ;; *) echo "✗ could not resolve the user home" >&2; exit 1;; esac
    trash_dir=$(mktemp -d "$user_home/.Trash/Tinycast Dev previous.XXXXXX")
    mv "$previous_app" "$trash_dir/Tinycast Dev.app"
fi
replacement_started=0

echo "✓ installed Tinycast Dev from ${source_commit:0:12}"
printf '%s\n' "$processes"
