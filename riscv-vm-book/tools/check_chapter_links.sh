#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BOOK_ROOT="$ROOT/docs/riscv-vm-book"
MANU_DIR="$BOOK_ROOT/manuscript"
WRAP_DIR="$BOOK_ROOT/mdbook/src/chapters"

# chapter_key|manuscript_file|wrapper_file|article|audit|lab
CASES=$(cat <<'CASES_EOF'
1|01-consensus-first.md|01-consensus-first.md|../articles/batch-01-01-constraint-hierarchy.md|../articles-audit/01-constraint-hierarchy-audit-template.md|../labs/batch-01-labs.md
2|02-run-to-exit.md|02-run-to-exit.md|../articles/batch-01-02-run-lifecycle.md|../articles-audit/02-run-lifecycle-audit-template.md|../labs/batch-01-labs.md
3|03-elf-loader-memory.md|03-elf-loader-memory.md|../articles/batch-01-03-elf-to-page-actions.md|../articles-audit/03-elf-to-page-actions-audit-template.md|../labs/batch-01-labs.md
4|04-decode-execute-trace.md|04-decode-execute-trace.md|../articles/batch-01-04-decode-fastpath.md|../articles-audit/04-decode-fastpath-audit-template.md|../labs/batch-01-labs.md
5|05-syscall-boundary.md|05-syscall-boundary.md|../articles/batch-02-05-ecall-dispatch-boundary.md|../articles-audit/05-ecall-dispatch-boundary-audit-template.md|../labs/batch-02-labs.md
6|06-snapshot-resume.md|06-snapshot-resume.md|../articles/batch-02-06-snapshot-layering-economics.md|../articles-audit/06-snapshot-layering-economics-audit-template.md|../labs/batch-02-labs.md
7|07-rust-type-semantics.md|07-rust-type-semantics.md|../articles/batch-02-07-register-trait-semantics.md|../articles-audit/07-register-trait-semantics-audit-template.md|../labs/batch-02-labs.md
8|08-rust-asm-hybrid.md|08-rust-asm-hybrid.md|../articles/batch-02-08-rust-asm-control-plane.md|../articles-audit/08-rust-asm-control-plane-audit-template.md|../labs/batch-02-labs.md
9|09-riscv-governance.md|09-riscv-governance.md|../articles/batch-03-09-isa-selection-impact-chain.md|../articles-audit/09-isa-selection-impact-chain-audit-template.md|../labs/batch-03-labs.md
10|10-isa-extensions-crypto.md|10-isa-extensions-crypto.md|../articles/batch-03-10-crypto-extension-real-division.md|../articles-audit/10-crypto-extension-real-division-audit-template.md|../labs/batch-03-labs.md
11|11-architecture-judgment.md|11-architecture-judgment.md|../articles/batch-03-11-benefit-cost-hard-constraints.md|../articles-audit/11-benefit-cost-hard-constraints-audit-template.md|../labs/batch-03-labs.md
CASES_EOF
)

fail_count=0

echo "[check] ensure no standalone-articles route remains in chapter manuscripts"
if rg -n "\.\./standalone-articles/" "$MANU_DIR"/{01-consensus-first.md,02-run-to-exit.md,03-elf-loader-memory.md,04-decode-execute-trace.md,05-syscall-boundary.md,06-snapshot-resume.md,07-rust-type-semantics.md,08-rust-asm-hybrid.md,09-riscv-governance.md,10-isa-extensions-crypto.md,11-architecture-judgment.md}; then
  echo "[fail] found legacy standalone-articles links"
  fail_count=$((fail_count + 1))
else
  echo "[ok] no legacy standalone-articles links"
fi

echo "[check] verify per-chapter manuscript + wrapper links"
while IFS='|' read -r key mf wf article audit lab; do
  [[ -z "$key" ]] && continue
  mpath="$MANU_DIR/$mf"
  wpath="$WRAP_DIR/$wf"

  if ! grep -Fq "$article" "$mpath"; then
    echo "[fail] chapter $key manuscript missing article link: $article"
    fail_count=$((fail_count + 1))
  fi
  if ! grep -Fq "$audit" "$mpath"; then
    echo "[fail] chapter $key manuscript missing audit link: $audit"
    fail_count=$((fail_count + 1))
  fi
  if ! grep -Fq "$lab" "$mpath"; then
    echo "[fail] chapter $key manuscript missing lab link: $lab"
    fail_count=$((fail_count + 1))
  fi

  if ! grep -Fq "$article" "$wpath"; then
    echo "[fail] chapter $key wrapper missing article link: $article"
    fail_count=$((fail_count + 1))
  fi
  if ! grep -Fq "$audit" "$wpath"; then
    echo "[fail] chapter $key wrapper missing audit link: $audit"
    fail_count=$((fail_count + 1))
  fi

  if [[ $fail_count -eq 0 ]]; then
    echo "[ok] chapter $key links present"
  fi
done <<< "$CASES"

if [[ $fail_count -gt 0 ]]; then
  echo "[result] failed with $fail_count issue(s)"
  exit 1
fi

echo "[result] all chapter links verified"
