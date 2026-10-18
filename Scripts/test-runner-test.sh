#!/bin/bash
set -eu
cd "$(dirname "$0")/.."
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/tools" "$scratch/tmp"
cat > "$scratch/tools/swiftc" <<'STUB'
#!/bin/bash
while [ "$1" != '-o' ]; do shift; done
cat > "$2" <<'PROGRAM'
#!/bin/bash
[ "${TINYCAST_RUNNER_FIXTURE_MODE:-}" = pass ] && exit 0
kill -TRAP $$
PROGRAM
chmod +x "$2"
STUB
chmod +x "$scratch/tools/swiftc"
status=0
PATH="$scratch/tools:$PATH" TMPDIR="$scratch/tmp" TINYCAST_TEST_TIMEOUT=5 \
    ./Scripts/run-tests.sh calc-test > "$scratch/result" 2>&1 || status=$?
[ "$status" -eq 1 ]
grep -q "crashed (signal 5)" "$scratch/result"
grep -q "1 of 1 harness(es) failed" "$scratch/result"
! grep -q "harness dispatch failed" "$scratch/result"
[ -f "$scratch/tmp/tinycast-harness/calc-test.failed" ]
grep -q "Trace/BPT trap" "$scratch/tmp/tinycast-harness/calc-test.log"
PATH="$scratch/tools:$PATH" TMPDIR="$scratch/tmp" TINYCAST_TEST_TIMEOUT=5 \
    TINYCAST_RUNNER_FIXTURE_MODE=pass TINYCAST_TEST_EXCLUDE=calc-test \
    ./Scripts/run-tests.sh > "$scratch/excluded" 2>&1
grep -q "All .* harness(es) passed" "$scratch/excluded"
grep -q "fuzz-test" "$scratch/excluded"
! grep -q "calc-test" "$scratch/excluded"
echo "Runner crash reporting and exclusion passed"
