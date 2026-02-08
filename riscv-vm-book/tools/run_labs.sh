#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DOC_ROOT="$REPO_ROOT/docs/riscv-vm-book"

BATCH="all"
MODE="full"
STOP_ON_FAIL=0
SKIP_ASM=0
OUTPUT_DIR=""

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Options:
  --batch <1|2|3|all>   Run a specific batch (default: all)
  --mode <full|smoke>   full runs all configured commands; smoke runs lighter set
  --skip-asm            Skip commands requiring --features asm or asm64 mode
  --stop-on-fail        Stop immediately when a command fails
  --output-dir <path>   Write logs/report to custom path
  -h, --help            Show this help

Examples:
  $(basename "$0") --batch 1
  $(basename "$0") --batch all --mode smoke --skip-asm
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --batch)
      BATCH="$2"
      shift 2
      ;;
    --mode)
      MODE="$2"
      shift 2
      ;;
    --skip-asm)
      SKIP_ASM=1
      shift
      ;;
    --stop-on-fail)
      STOP_ON_FAIL=1
      shift
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 2
      ;;
  esac
done

if [[ "$BATCH" != "1" && "$BATCH" != "2" && "$BATCH" != "3" && "$BATCH" != "all" ]]; then
  echo "Invalid --batch value: $BATCH"
  exit 2
fi

if [[ "$MODE" != "full" && "$MODE" != "smoke" ]]; then
  echo "Invalid --mode value: $MODE"
  exit 2
fi

TS="$(date +%Y%m%d_%H%M%S)"
if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$DOC_ROOT/reports/labs/$TS"
fi

LOG_DIR="$OUTPUT_DIR/logs"
REPORT_MD="$OUTPUT_DIR/lab-run-report.md"
REPORT_CSV="$OUTPUT_DIR/lab-run-report.csv"

mkdir -p "$LOG_DIR"

declare -a CASE_BATCH=()
declare -a CASE_ID=()
declare -a CASE_TITLE=()
declare -a CASE_CMD=()
declare -a CASE_EXPECT=()

add_case() {
  CASE_BATCH+=("$1")
  CASE_ID+=("$2")
  CASE_TITLE+=("$3")
  CASE_CMD+=("$4")
  CASE_EXPECT+=("$5")
}

add_batch_1() {
  add_case "1" "1.1" "simple cycles" \
    "cargo test --test test_simple test_simple_cycles -- --nocapture" \
    "cycles behavior test passes"
  add_case "1" "1.2" "max cycles boundary" \
    "cargo test --test test_simple test_simple_max_cycles_reached -- --nocapture" \
    "max cycles exceeded behavior asserted"
  add_case "1" "1.3" "pause semantics" \
    "cargo test --test test_signal_pause -- --nocapture" \
    "pause tests pass across paths"
  add_case "1" "1.4" "version and boundary checks" \
    "cargo test --test test_versions -- --nocapture" \
    "version compatibility tests pass"
  add_case "1" "1.5" "mop path" \
    "cargo test --test test_mop -- --nocapture" \
    "mop regression set passes"
}

add_batch_2() {
  add_case "2" "2.1" "runner interpreter64" \
    "cargo run --example ckb_vm_runner -- --mode interpreter64 tests/programs/simple64" \
    "program exits successfully in interpreter mode"
  add_case "2" "2.2" "resume" \
    "cargo test --test test_resume -- --nocapture" \
    "snapshot resume tests pass"
  add_case "2" "2.3" "resume2" \
    "cargo test --test test_resume2 -- --nocapture" \
    "snapshot2 cross-backend tests pass"
  add_case "2" "2.4" "b extension" \
    "cargo test --test test_b_extension -- --nocapture" \
    "b extension semantics stable"
  add_case "2" "2.5" "a extension" \
    "cargo test --test test_a_extension -- --nocapture" \
    "a extension semantics stable"
  add_case "2" "2.6" "asm regression" \
    "cargo test --features asm --test test_asm -- --nocapture" \
    "asm backend tests pass"
}

add_batch_3() {
  add_case "3" "3.1" "versions + misc" \
    "cargo test --test test_versions -- --nocapture" \
    "version suite remains stable"
  add_case "3" "3.2" "misc semantics" \
    "cargo test --test test_misc -- --nocapture" \
    "misc regression passes"
  add_case "3" "3.3" "crypto path mop" \
    "cargo test --test test_mop -- --nocapture" \
    "crypto-related mop path passes"
  add_case "3" "3.4" "full regression" \
    "cargo test --all -- --nocapture" \
    "full test suite passes"
  add_case "3" "3.5" "asm + versions" \
    "cargo test --features asm --test test_versions -- --nocapture" \
    "asm and version matrix remains stable"
}

if [[ "$BATCH" == "1" || "$BATCH" == "all" ]]; then
  add_batch_1
fi
if [[ "$BATCH" == "2" || "$BATCH" == "all" ]]; then
  add_batch_2
fi
if [[ "$BATCH" == "3" || "$BATCH" == "all" ]]; then
  add_batch_3
fi

if [[ "$MODE" == "smoke" ]]; then
  for i in "${!CASE_CMD[@]}"; do
    if [[ "${CASE_ID[$i]}" == "3.4" ]]; then
      CASE_CMD[$i]="cargo test --test test_simple -- --nocapture"
      CASE_EXPECT[$i]="smoke fallback: simple regression passes"
    fi
  done
fi

requires_asm() {
  local cmd="$1"
  if [[ "$cmd" == *"--features asm"* || "$cmd" == *"--mode asm64"* ]]; then
    return 0
  fi
  return 1
}

declare -a STATUS=()
declare -a EXIT_CODE=()
declare -a LOG_FILE=()

run_one_case() {
  local idx="$1"
  local cmd="${CASE_CMD[$idx]}"
  local id="${CASE_ID[$idx]}"
  local slug
  slug="$(echo "$id-${CASE_TITLE[$idx]}" | tr ' ' '_' | tr -cd '[:alnum:]_.-')"
  local log="$LOG_DIR/${slug}.log"

  if [[ "$SKIP_ASM" -eq 1 ]] && requires_asm "$cmd"; then
    STATUS[$idx]="skipped"
    EXIT_CODE[$idx]="-"
    LOG_FILE[$idx]="(skipped: asm command)"
    return
  fi

  echo "[run] batch ${CASE_BATCH[$idx]} case ${CASE_ID[$idx]}: ${CASE_TITLE[$idx]}"
  {
    echo "# Command"
    echo "$cmd"
    echo
    echo "# Started"
    date -Iseconds
    echo
    echo "# Output"
  } > "$log"

  (cd "$REPO_ROOT" && bash -lc "$cmd") >> "$log" 2>&1
  local ec=$?

  {
    echo
    echo "# Finished"
    date -Iseconds
    echo "# Exit code"
    echo "$ec"
  } >> "$log"

  EXIT_CODE[$idx]="$ec"
  LOG_FILE[$idx]="${log#$REPO_ROOT/}"

  if [[ $ec -eq 0 ]]; then
    STATUS[$idx]="passed"
  else
    STATUS[$idx]="failed"
    if [[ "$STOP_ON_FAIL" -eq 1 ]]; then
      echo "[stop] failed at ${CASE_ID[$idx]} (exit $ec)"
      write_reports
      exit "$ec"
    fi
  fi
}

write_reports() {
  mkdir -p "$OUTPUT_DIR"

  local passed_count=0
  local failed_count=0
  local skipped_count=0
  for status in "${STATUS[@]}"; do
    case "$status" in
      passed)
        ((passed_count++))
        ;;
      failed)
        ((failed_count++))
        ;;
      skipped)
        ((skipped_count++))
        ;;
    esac
  done

  {
    echo "batch,case_id,title,status,exit_code,command,log_file"
    for i in "${!CASE_ID[@]}"; do
      printf '"%s","%s","%s","%s","%s","%s","%s"\n' \
        "${CASE_BATCH[$i]}" "${CASE_ID[$i]}" "${CASE_TITLE[$i]}" "${STATUS[$i]}" "${EXIT_CODE[$i]}" "${CASE_CMD[$i]}" "${LOG_FILE[$i]}"
    done
  } > "$REPORT_CSV"

  {
    echo "# Lab Run Report"
    echo
    echo "- Generated: $(date -Iseconds)"
    echo "- Repo: \`$REPO_ROOT\`"
    echo "- Batch: \`$BATCH\`"
    echo "- Mode: \`$MODE\`"
    echo "- Skip ASM: \`$SKIP_ASM\`"
    echo "- Stop on fail: \`$STOP_ON_FAIL\`"
    echo "- Passed: \`$passed_count\`"
    echo "- Failed: \`$failed_count\`"
    echo "- Skipped: \`$skipped_count\`"
    echo
    echo "## Result Summary"
    echo
    echo "| Batch | Case | Title | Status | Exit | Command | Log |"
    echo "|---|---|---|---|---:|---|---|"
    for i in "${!CASE_ID[@]}"; do
      echo "| ${CASE_BATCH[$i]} | ${CASE_ID[$i]} | ${CASE_TITLE[$i]} | ${STATUS[$i]} | ${EXIT_CODE[$i]} | \`${CASE_CMD[$i]}\` | \`${LOG_FILE[$i]}\` |"
    done
    echo
    echo "## Expectation Checklist"
    echo
    for i in "${!CASE_ID[@]}"; do
      echo "- [ ] ${CASE_ID[$i]} ${CASE_TITLE[$i]} -> ${CASE_EXPECT[$i]}"
    done
    echo
    echo "## Manual Observation Template"
    echo
    echo "- Environment notes:"
    echo "- Cross-backend differences observed:"
    echo "- Risk assessment:"
    echo "- Follow-up actions:"
    echo
    echo "## Artifacts"
    echo
    echo "- CSV summary: \`${REPORT_CSV#$REPO_ROOT/}\`"
    echo "- Raw logs dir: \`${LOG_DIR#$REPO_ROOT/}\`"
  } > "$REPORT_MD"

  echo
  echo "[done] report: $REPORT_MD"
  echo "[done] csv:    $REPORT_CSV"
}

for i in "${!CASE_ID[@]}"; do
  run_one_case "$i"
done

write_reports

failed_total=0
skipped_total=0
passed_total=0
for status in "${STATUS[@]}"; do
  case "$status" in
    passed)
      ((passed_total++))
      ;;
    failed)
      ((failed_total++))
      ;;
    skipped)
      ((skipped_total++))
      ;;
  esac
done

echo "[summary] passed=$passed_total failed=$failed_total skipped=$skipped_total"

if [[ "$failed_total" -gt 0 ]]; then
  exit 1
fi
