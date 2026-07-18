#!/usr/bin/env bash
# check_no_coupling.sh — prove the loop's internal regions share ONLY the Lattice.
#
# The CLOSURE RULE demands actor-to-actor references ZERO: a region may never
# call, address, or name another region — it coordinates purely through the
# Lattice by posting numbered phase cues. In the slice and the atomic arm the
# three regions were separate FILES, so this was a trivial cross-file name grep.
#
# IN THE LOOPS ARM THE REGIONS SHARE ONE FILE (packs/loop/prolog/loop.pl), as
# internal sections. So this checker must do INTRA-PACK analysis: it splits the
# loop module into its three "INTERNAL REGION MODULE" sections and confirms no
# section's CODE (comments stripped) calls another region's loop_<region>_
# predicates or names another region as a bare word. That the zero-coupling
# guarantee lost its cheap cross-file enforcement, and now needs section-aware
# analysis, is itself a finding (see LEDGER.md, LOOPS-2).
#
# Exit 0 = clean (no cross-region reference); 1 = a reference found; 2 = error.
set -u
# Resolve the arm repository root from this script's location.
cd "$(dirname "$0")/.." || exit 2
# Run a small Python check that splits the loop module into region sections.
python3 - <<'PY'
import re, sys
# The three internal region modules whose code must never call one another.
regions = ["cortex", "striatum", "thalamus"]
# Read the single loop module holding all three region sections.
src = open("packs/loop/prolog/loop.pl").read()
# Split on the internal-region markers, capturing each region name and its body.
parts = re.split(r"%\s*INTERNAL REGION MODULE:\s*(\w+)", src)
# parts[0] is the preamble (module decl + imports); then (name, body) pairs follow.
sections = {}
for i in range(1, len(parts) - 1, 2):
    sections[parts[i].strip()] = parts[i + 1]
# Track every cross-region reference found.
violations = []
# Confirm all three internal region sections are present.
for r in regions:
    if r not in sections:
        violations.append(f"internal region section '{r}' not found (marker missing)")
# Examine each region section's CODE for references to another region.
for r, body in sections.items():
    # Strip block comments /* ... */ (dot matches newline).
    code = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
    # Strip whole-line % comments (keep code lines only).
    code = "\n".join(l for l in code.split("\n") if not l.lstrip().startswith("%"))
    # Also strip trailing % comments on code lines.
    code = re.sub(r"%.*", "", code)
    # Look for a call into any OTHER region's predicate family, or its bare name.
    for other in regions:
        if other == r:
            continue
        # A direct call into another region would be to a loop_<other>_ predicate.
        if re.search(r"\bloop_" + re.escape(other) + r"_", code):
            violations.append(f"internal region '{r}' calls region '{other}' directly (loop_{other}_...)")
        # Defence in depth: the other region's bare name should not appear in code either.
        if re.search(r"\b" + re.escape(other) + r"\b", code):
            violations.append(f"internal region '{r}' names region '{other}' in code")

# Report the outcome.
if violations:
    print("check_no_coupling: FAIL")
    for v in violations:
        print("  " + v)
    sys.exit(1)
else:
    print("check_no_coupling: PASS -- the loop's internal regions share only the Lattice; 0 actor-to-actor references.")
    print("  cortex, striatum, thalamus are sections of one loop pack, coordinating solely via numbered phase cues (phase_0/1/2).")
    sys.exit(0)
PY
# Propagate the Python checker's exit code.
exit $?
