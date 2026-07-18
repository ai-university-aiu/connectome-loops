# COMPARISON — connectome-loops (Wave 3b, the loops arm)

The Wave 3 granularity experiment tests ONE variable: **how big should a
code-pack be?** This arm's answer is **one pack per reentrant loop** — the
coarse arm, with regions as internal modules. Every number below is argued from
the built code and stated against the atomic control arm, so a later Wave 3
verdict can lay the three side by side. The invariant (behaviour, the
twenty-eight records, the dynamics, the closure mechanism, the platform) was held
constant and is proven so: the narrated trace and all twenty-eight structure
records are byte-identical to the Wave 2 slice.

## Rubric at a glance (loops vs atomic)

| # | Rubric question | connectome-loops | connectome-atomic |
|---|---|---|---|
| 1 | Pack count (slice / projected) | **4** / **~23** | 11 / ~143 |
| 2 | Change locality (retune dopamine) | 1 pack (coarse, shared) | 1 pack (isolated) |
| 3 | Coupling (intra-repo edges) | **2 / 4 packs** (0.5/pack), linear in circuits | 29 / 11 (2.6/pack), superlinear |
| 4 | Layer-rule pressure | 3 levels, 0 violations; but hides internal hierarchy | 6 levels, 0 violations |
| 5 | Testability | **Regions NOT isolable** (whole loop loads) | dynamics isolate perfectly |
| 6 | Grounding fit | Low (all kinds in one causal_map); structure/runtime cleanly split | Low (packs cut across kinds); structure/runtime fused |
| 7 | Ergonomics / new gaps | 3 intra-pack gaps (LOOPS-1..3) + 1 second sighting (P5) | 4 packaging gaps + 3 second sightings |
| 8 | Scale verdict | Leanest; cost moves INSIDE the pack | Best locality; ceremony + interface coupling hurt |

## 1. Pack count

**Actual at the slice: 4 packs** — `neural_lattice` (substrate), `neurochemistry`
(all native dynamics), `causal_map` (all 28 structure records), and `loop` (the
whole reentrant circuit, with cortex/striatum/thalamus as internal sections).
That is materially fewer than the atomic arm's **11** and fewer than the slice's
6 — the three region packs collapsed into one loop pack while the slice's already
-coarse substrate, dynamics, and structure packs carried over VERBATIM.

The rule was genuinely applied: the regions are INTERNAL modules of `loop`
(sections `loop_cortex_*`, `loop_striatum_*`, `loop_thalamus_*`), not packs. If
this arm had ~11 packs, the rule would have been ignored; it has 4.

**Projected to a full connectome: ~23 packs.** Reasoning: the connectome has
roughly TWENTY major reentrant circuits; one pack each → ~20, plus the small
fixed set of shared packs (substrate, dynamics, structure) → ~23. The projection
is linear in CIRCUITS, not in constructs — an order of magnitude below atomic's
~143. This is the loops arm's headline number.

## 2. Change locality — retune dopamine

**One pack (`neurochemistry`), but coarse.** Dopamine's law lives in
`neurochemistry`, so a retune edits one pack — the same COUNT as the atomic arm.
But `neurochemistry` also holds cortisol and the plasticity rule, so the edit
shares a file with unrelated dynamics (the slice's situation). And a change to a
region's ROLE (how the cortex predicts) edits the `loop` pack, which also holds
the other two regions — a coarse blast radius. So loops matches atomic on
pack-COUNT for a neurochemical retune but loses atomic's ISOLATION: the file you
touch carries neighbours you did not mean to touch. Coarse granularity trades
isolation for fewer, larger units.

## 3. Coupling and how it grows

Measured intra-repo import edges (a `use_module(library(X))` where X is another
arm pack):

```
neural_lattice   0     causal_map   0
neurochemistry   0     loop         2   (neural_lattice, neurochemistry)
                       TOTAL        2 edges / 4 packs
```

**Two edges, both from the loop pack down to the substrate and the dynamics.**
Against the atomic arm's **29 edges / 11 packs**, loops is an order of magnitude
less coupled (0.5 vs 2.6 edges/pack). And it grows LINEARLY: each additional
circuit is one loop pack importing the shared substrate and dynamics (~2 edges),
where the atomic arm's edges grew SUPERLINEARLY (5.8× for a 1.8× pack increase,
concentrated at the interfaces). For "surviving 140 constructs," this is the
property the master plan prizes — but the loops arm buys it by hiding the
coupling INSIDE the loop pack, not by eliminating it (the three regions still
coordinate, just intra-pack via the Lattice).

## 4. Layer-rule pressure

The strict layer rule passed with **zero violations** across 3 levels
(`neural_lattice` 0, `neurochemistry`/`causal_map` 1, `loop` 2) — the gentlest of
the three arms (atomic had 6 levels, 11 declarations; loops has 3 levels, 4
declarations). But the coarse pack does something the finer arms did not: it
COLLAPSES the internal hierarchy. The slice and atomic recorded cortex=4,
striatum=3, thalamus=2; the loop pack is a single `layer(2)`, and the layer
construct — being pack-granular — can no longer see that the cortex sits above
the thalamus (LOOPS-1). So loops makes the layer CHECK easier and the layer
INFORMATION poorer: a coarse pack does not straddle layers in a violating sense,
but it erases the distinctions the rule exists to express.

## 5. Testability

**This is where coarse granularity hurts, exactly as predicted.** A region cannot
be exercised in isolation: loading the cortex section means loading the whole
`loop` pack — all three regions plus `neural_lattice` and `neurochemistry` —
because PrologAI's smallest loadable unit is the pack and there is no way to
target one internal section (LOOPS-3). The atomic arm could test the dopamine RPE
without loading cortisol; the loops arm cannot test the cortex section without
loading the striatum and thalamus. The dynamics (`neurochemistry`) and the
structure (`causal_map`) DO stay independently testable — they are their own
coarse packs — so it is specifically the INTERNALISED regions that lose
isolation. Coarse packing costs testability for whatever it puts inside a pack.

## 6. Grounding fit

Low, like atomic, but for the OPPOSITE reason. Atomic cut ACROSS the kinds
(each construct pack owned mixed kinds). Loops LUMPS all kinds into one
`causal_map` pack — the structure boundary aligns with neither the kinds nor the
circuits; it is simply "all structure, one pack." What loops does keep, that
atomic broke, is the clean STRUCTURE/RUNTIME separation: `causal_map` (grounding)
and `loop` (behaviour) are disjoint packs with disjoint dependencies, so the
validator needs no runtime substrate and the runner needs no grounding engine
(the atomic arm's ATOMIC-4/5 coupling does not arise here). Neither coarse arm
aligns the pack boundary with the Causalontology kinds; that alignment is the
strata arm's (3c) distinctive move, still to be measured.

## 7. Ergonomics and new gaps

Building coarsely surfaced three NEW gaps, all facets of one absence — PrologAI
has no INTRA-PACK MODULE BOUNDARY, so anything a coarse pack internalises falls
below the language's resolution:

- **LOOPS-1** — a coarse pack collapses the internal layer hierarchy; the
  pack-granular layer construct cannot see or check it.
- **LOOPS-2** — no intra-pack boundary for coupling: the zero-reference guarantee
  loses its cheap cross-file enforcement and needs bespoke section analysis.
- **LOOPS-3** — no intra-pack boundary for testability: a region cannot be
  exercised without loading the whole loop.

plus one light SECOND SIGHTING — **LOOPS-4 → P5** (the layer entry point still
needs a hand-written wrapper, independent of pack count). P6 and P7 are re-touched
but milder than in atomic. Full detail in [`LEDGER.md`](LEDGER.md).

## 8. Scale verdict

At ~20 circuits, one-pack-per-loop is the LEANEST of the three arms: ~23 packs
(vs ~143 atomic), coupling linear in circuits (~2 edges each), and a shallow
layer stack with few declarations. **What it buys:** minimal ceremony and minimal
cross-pack coupling — the "survives 140 constructs" property, achieved by making
each circuit one unit.

**What hurts first:** everything moves INSIDE the pack. A loop pack with many
internal regions becomes a large file whose regions cannot be tested or reasoned
about independently (LOOPS-3), whose no-coupling discipline is enforced by a
custom section-linter rather than the file system (LOOPS-2), and whose internal
layer hierarchy is invisible to the layer rule (LOOPS-1). The coarser the pack,
the more the architecture's discipline migrates from the LANGUAGE (file
boundaries, the layer construct, per-pack tests) into PROSE and bespoke scripts.
Loops is the right cut for a system reasoned about one CIRCUIT at a time and the
wrong cut for one reasoned about one CONSTRUCT at a time — the mirror image of
the atomic arm, and precisely the trade the granularity experiment set out to
measure. Whether the DATA layer's own stratum boundary is a better cut than
either is the strata arm's (3c) question.
