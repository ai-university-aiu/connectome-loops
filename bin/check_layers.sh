#!/usr/bin/env bash
# check_layers.sh — run PrologAI's UNMODIFIED strict-layer-rule construct
# (library(layer), Ledger entry L4) against THIS arm's four packs.
#
# The loops arm has the FEWEST packs of the three granularity arms, so it is the
# gentlest test of the layer construct. Every pack declares layer(N) in its
# pack.pl; this checker loads PrologAI's library(layer) by its real path (no copy,
# no modification) and calls its directory-scoped report + check against the arm's
# packs/ dir, reusing the SAME construct through its public layer_report_dir/1 and
# layer_check_dir/2 predicates — reuse, not reimplement.
#
# Exit 0 = clean (no upward edge among declared packs); 1 = a violation;
# 2 = could not run.
set -u
# Resolve the arm repository root from this script's location.
cd "$(dirname "$0")/.." || exit 2
# Resolve the PrologAI checkout (honour PROLOGAI_HOME, else the local default).
PROLOGAI_HOME="${PROLOGAI_HOME:-/home/ccaitwo/PrologAI}"
# Confirm PrologAI's layer pack exists before trying to load it.
if [ ! -f "$PROLOGAI_HOME/packs/layer/prolog/layer.pl" ]; then
  # Report the missing construct and stop.
  echo "check_layers.sh: cannot find PrologAI's library(layer) at $PROLOGAI_HOME (set PROLOGAI_HOME)" >&2
  exit 2
fi
# The arm's packs directory (absolute) that the construct will check.
SLICE_PACKS="$PWD/packs"
# Load PrologAI's layer construct from its own prolog directory and run it over the arm.
swipl -q -p library="$PROLOGAI_HOME/packs/layer/prolog" \
  -g "use_module(library(layer)), layer_report_dir('$SLICE_PACKS'), layer_check_dir('$SLICE_PACKS', V), (V==[] -> halt(0) ; halt(1))" \
  -t "halt(2)" 2>&1
# Propagate swipl's exit code as the gate result.
exit $?
