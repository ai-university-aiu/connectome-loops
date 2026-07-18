# connectome-loops — one pack per reentrant loop (Wave 3b)

**THE DELIVERABLE IS THE FINDING, NOT THE CODE.**

This repository is the **loops arm** of the Wave 3 granularity experiment (see
`WAVE_3_DESIGN_v1.txt`). Its one-sentence purpose: **to measure the decomposition
rule "one pack per reentrant loop," and to surface what building the identical
anatomy coarsely — with the regions as internal modules of the loop pack —
reveals PrologAI still lacks.** The walls it hit live in [`LEDGER.md`](LEDGER.md);
the side-by-side measurement against the atomic control arm lives in
[`COMPARISON.md`](COMPARISON.md). Those two files, not this code, are the product.

## What this is (and is not)

It is **not a new slice.** It is the SAME Wave 2 vertical slice
(`connectome-proto-agi`), and the SAME anatomy as the atomic arm
(`connectome-atomic`), carved COARSELY instead of finely. The ONE variable Wave 3
tests is **how big a code-pack should be**; this arm's answer is the coarse one —
a whole reentrant circuit is one pack, and its regions are internal sections.

Everything else is held constant and PROVEN so:

- **The behaviour** — the cortico-basal-ganglia-thalamo-cortical loop closing for
  N laps, same verdict (3N+1 hops, a strictly monotonic token, the region
  sequence cortex then N×[striatum, thalamus, cortex], the cortex re-entering N
  times). The narrated trace is **byte-identical** to the slice and the atomic
  arm (verified by `diff`).
- **The data layer** — the SAME twenty-eight Causalontology 2.0.0 records, proven
  **byte-identical** to the slice's `structure/`. (This arm reuses the slice's
  `causal_map` pack verbatim, so identity is guaranteed.)
- **The dynamics** — the same dopamine RPE, cortisol suppression, and three-factor
  plasticity math (the slice's `neurochemistry` pack, reused verbatim).
- **The closure mechanism** — stigmergy for state (zero actor-to-actor
  references, even though the regions now share a pack) plus notification for
  reactivity (`lattice_await`/`lattice_notify`, no busy-poll), narrated in
  glass-box style.
- **The platform** — PrologAI reused UNMODIFIED, read-only. Every gap is a Ledger
  entry, never a commit. Mentova and the frozen spike are untouched.

Only the **pack boundaries** move.

## The decomposition — one pack per reentrant loop

Four packs carve the identical anatomy:

```
packs/neural_lattice/   layer 0  closure substrate (stigmergy + await/notify)     [reused verbatim from the slice]
packs/neurochemistry/   layer 1  dopamine RPE, cortisol tone, three-factor rule    [reused verbatim from the slice]
packs/causal_map/       layer 1  all 28 Causalontology 2.0.0 structure records     [reused verbatim from the slice]
packs/loop/             layer 2  the whole reentrant circuit — cortex, striatum, thalamus as INTERNAL sections
```

Three of the four packs are the slice's already-coarse packs, carried over
unchanged; only the three region packs were merged into one `loop` pack. Inside
`loop`, the regions are clearly-delimited `INTERNAL REGION MODULE` sections with
`loop_<region>_` predicates — reachable within the pack, never exposed as their
own packs, and (crucially) never calling one another: they coordinate only
through numbered Lattice cues, enforced across the section boundary by
`bin/check_no_coupling.sh`.

Contrast the control arm: `connectome-atomic` split the same anatomy into ELEVEN
packs (one per named construct). Loops uses FOUR.

## How to run it

Everything reuses a local PrologAI checkout **unmodified** (default
`/home/ccaitwo/PrologAI`; override with `PROLOGAI_HOME`). SWI-Prolog 9.x required.

```bash
# 1. Tick the reentrant loop and print the narrated, glass-box trace (exit 0 on a proven close).
bin/run_slice.sh 8 5 0.4        #  <laps> <cortisol_event_lap> <learning_rate>

# 2. Run PrologAI's UNMODIFIED layer construct against the arm's 4 packs (exit 0 = no upward edge).
bin/check_layers.sh

# 3. Prove the loop's internal regions share only the Lattice — zero actor-to-actor references.
#    (This arm's regions share ONE file, so the check does intra-pack section analysis, not a
#     cross-file grep — see LEDGER.md, LOOPS-2.)
bin/check_no_coupling.sh

# 4. Validate every Causalontology 2.0.0 structure record + the skip finding + the signature.
#    (bin/validate_structure.sh is the wrapper; it runs the validator bin/validate_structure.pl.)
bin/validate_structure.sh

# 5. Run every pack's in-pack PLUnit suite.
bin/run_tests.sh
```

## How to read the narration

Each line of the trace is one hop of the beat through the Lattice — identical in
form to the slice and the atomic arm:

```
    hop 14  via lattice  striatum  token=14
      striatum: reward=1.00 prediction=0.6400 dopamine(RPE)=0.3600 cortisol=0.000 weight 0.6400 -> 0.7840
    hop 15  via lattice  thalamus  token=15
```

- `via lattice` on **every** hop is the point: even though the three regions now
  share one pack, the beat still always arrives through the shared Lattice, never
  by one section calling another. The reentrant thalamus→cortex return is just
  another `via lattice` hop.
- `token=N` increases by exactly 1 every hop. At the end the runner checks the
  token ran 1..3N+1, the region sequence was `cortex` then N×`[striatum, thalamus,
  cortex]`, and the cortex re-entered N times.
- Watch **dopamine(RPE)** fall from 1.0 toward 0 as the prediction rises to meet
  the reward; at the cortisol event lap a one-line banner marks the ten-stratum
  skip and the weight barely moves thereafter.

## Status

The loop closes for N laps with a byte-identical trace to the slice; the internal
regions share only the Lattice (zero actor-to-actor references, proven by
intra-pack section analysis) and there is no busy-poll; every pack declares a
layer and the layer checker passes with zero upward edges (three levels, 0–2);
all 28 records validate and are byte-identical to the slice's; the mini
regression is green (ARC-AGI-1 40/40, ARC-AGI-2 12/12 — a 10 percent spot-check;
full regression deferred); PrologAI, Mentova, and the frozen spike are unmodified.
See [`LEDGER.md`](LEDGER.md) for the four findings and [`COMPARISON.md`](COMPARISON.md)
for the rubric — the reason this repository exists.

## Boundaries (what this arm must not become)

Not a new slice, not the full 140-construct connectome (it replicates the SLICE
and PROJECTS to scale), not a modification of PrologAI (a gap is a Ledger entry,
not a commit), the frozen spike, or Mentova. It is the slice, carved by loop —
one arm of a three-arm comparison whose verdict comes after connectome-strata
(3c) is built.
