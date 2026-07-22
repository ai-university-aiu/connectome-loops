# LEDGER — what one-pack-per-loop found PrologAI still lacks

**This Ledger is the deliverable.** connectome-loops is the LOOPS arm of the
Wave 3 granularity experiment (see `WAVE_3_DESIGN_v1.txt`). It re-decomposes the
Wave 2 slice under one rule — **one pack per reentrant loop or circuit**, with
the regions as INTERNAL modules of the loop pack — holding the behaviour, the
twenty-eight Causalontology 3.0.0 records, the dynamics, and the closure
mechanism constant. Every entry below is a wall the arm hit while carving the
identical anatomy coarsely.

## Identifier scheme

Entries use a fresh **LOOPS-series (LOOPS-1, LOOPS-2, …)**, so a finding here can
never be confused with the spike's **L1–L9**, PrologAI's **L-series and N1–N5**,
the Wave 2 slice's **P1–P10**, the control arm's **ATOMIC-1…7**, or the strata
arm's future **STRATA-***. Second sightings cite their parent by its own id.
Severity `S` uses the spike's H/M/L scale.

## Where the findings cluster

Exactly where the design predicted for the coarse arm: **inside the pack.** With
the fewest packs of any arm (four, against the slice's six and atomic's eleven),
the layer construct is barely stressed and cross-pack coupling nearly vanishes
(two edges total). But collapsing the three regions into ONE pack moves the work
the file system and the layer rule used to do FOR us into the pack, and PrologAI
has no INTRA-PACK MODULE BOUNDARY to catch it. Three of the four findings
(LOOPS-1, LOOPS-2, LOOPS-3) are facets of that one absence — the pack is the
smallest unit PrologAI can layer, isolate for coupling, or test, so anything a
coarse pack puts *inside itself* falls below the language's resolution. The
fourth is a light second sighting of the layer construct's entry point (P5).

---

### LOOPS-1 — a coarse pack collapses the internal layer hierarchy, and the layer construct cannot see inside it · S=M

- **Construct that forced it.** The reentrant LOOP pack, holding three regions
  the slice and atomic arms placed at three distinct layers.
- **What PrologAI could not express.** The slice and the atomic arm both recorded
  the loop's internal hierarchy in the layer numbers: cortex at layer 4, striatum
  at 3, thalamus at 2 — the anatomy's "cortex sits above thalamus" made
  machine-checkable. The loops arm packs all three into ONE pack at `layer(2)`,
  and that information is simply GONE: the layer construct is PACK-GRANULAR, so it
  sees one layer-2 node and cannot express — let alone check — that the cortex
  section is "higher" than the thalamus section. The coarse decomposition
  discards a layer coordinate the finer arms kept. (The pack does not *violate*
  the rule — its imports are all downward — but the rule can no longer say
  anything about what the pack contains.)
- **Evidence.** `packs/loop/pack.pl` declares a single `layer(2)`; the atomic
  arm's `packs/{cortex,striatum,thalamus}/pack.pl` declared 4, 3, 2. The loop
  module's three `INTERNAL REGION MODULE` sections carry no layer of their own.
- **Proposed remedy (minimum).** An INTRA-PACK layer annotation (a section/
  sub-module may declare its own layer within a pack) so a coarse pack can still
  record and check the hierarchy of the constructs it internalises.
- **Parents.** New. A pack-granularity limit of the layer construct (**L4**),
  exposed only when a pack deliberately spans layers.

### LOOPS-2 — no intra-pack module boundary for COUPLING: the zero-reference guarantee loses its cheap enforcement · S=M

- **Construct that forced it.** The three region sections sharing ONE loop file.
- **What PrologAI could not express.** The CLOSURE RULE (zero actor-to-actor
  references) was trivially enforceable while the regions were separate FILES: a
  cross-file name grep sufficed (the slice's and atomic's `check_no_coupling.sh`).
  Once the regions are internal SECTIONS of one file, PrologAI offers no
  construct for "these sub-modules within a pack MUST NOT call one another" — a
  module is the whole pack; there is no sub-module boundary the language enforces.
  So the guarantee had to be re-implemented as bespoke SECTION-AWARE analysis
  (split the module on section markers, confirm no section calls another's
  `loop_<region>_` predicates). It works, and it catches an injected violation,
  but it is a convention checked by a hand-written script, not a boundary the
  language provides. "Same pack" genuinely does make direct coupling tempting;
  nothing but this script stands in the way.
- **Evidence.** `bin/check_no_coupling.sh` (this repo) splits
  `packs/loop/prolog/loop.pl` into its three sections and checks intra-file cross
  references — where the slice/atomic version compared separate files.
- **Proposed remedy (minimum).** An intra-pack SUB-MODULE construct with an
  import/call boundary the language enforces, so a coarse pack can host internal
  modules that provably cannot address one another without a bespoke linter.
- **Parents.** New. The coupling face of the missing intra-pack module boundary;
  sibling of LOOPS-3.

### LOOPS-3 — no intra-pack module boundary for TESTABILITY: a region cannot be exercised without the whole loop · S=M

- **Construct that forced it.** A single region (say the cortex section) inside
  the loop pack.
- **What PrologAI could not express.** The pack is the smallest unit PrologAI can
  load and test. In the atomic arm each region was its own pack, so the dopamine
  RPE or a region's interface could be exercised in near-isolation. In the loops
  arm, loading the cortex section means loading the WHOLE loop pack — all three
  regions and their `neural_lattice` + `neurochemistry` imports — because there
  is no way to load or target ONE internal section. The dynamics
  (`neurochemistry`) and the structure (`causal_map`) stay independently testable
  (they are their own coarse packs), but the REGIONS lose isolation the moment
  they are internalised. There is no sub-pack test surface.
- **Evidence.** `packs/loop/test/test_loop.pl` can only load `library(loop)` as a
  whole; there is no `library(loop/cortex)` to test the cortex section alone.
- **Proposed remedy (minimum).** The same intra-pack sub-module construct LOOPS-2
  asks for, with a per-sub-module test target, so an internalised construct
  remains independently testable.
- **Parents.** New. The testability face of the missing intra-pack module
  boundary; sibling of LOOPS-2.

### LOOPS-4 — the layer construct's entry point still needs a hand-written wrapper (P5, second sighting) · S=L

- **Construct that forced it.** The LAYER construct, under its GENTLEST user
  (four packs).
- **What PrologAI could not express.** Exactly the slice's **P5**: PrologAI's own
  `bin/check_layers.sh` is hard-wired to its own packs, so even this tiny
  four-pack arm had to write its own wrapper calling `layer_report_dir/1` +
  `layer_check_dir/2`. The wrapper cost is independent of pack count — it bites a
  four-pack arm exactly as it bit the eleven-pack one. **Second sighting.**
- **Evidence.** `bin/check_layers.sh` (this repo) reimplements the same wrapper
  the slice and the atomic arm each wrote.
- **Parents.** Confirms **P5** (Wave 2 slice; still open). NOTE: this arm also
  technically re-touches **P6** (its `loop`/`neural_lattice` imports of PrologAI
  packs are invisible to the layer graph) and **P7** (it invents yet a third
  layer scale, 0–2), but both are MILDER here than in the atomic arm — with four
  packs and a three-level stack there is little multi-pack layer pressure to
  find. The design predicted this arm would be thin on the layer-multi-pack side,
  and it is.

---

## What did NOT become a finding (honesty)

- The behaviour held EXACTLY. The narrated trace is byte-identical to the slice's
  and the atomic arm's (same hops, tokens, weights, dopamine decay, cortisol
  event), proven by `diff`. Even with the three regions sharing one pack, they
  coordinated only through the Lattice — the closure discipline survived
  co-location, and `check_no_coupling.sh` confirms it (and catches an injected
  cross-region call, so it is not vacuous).
- The twenty-eight records are byte-identical to the slice's — here trivially so,
  because the loops arm REUSES the slice's `causal_map`, `neurochemistry`, and
  `neural_lattice` packs VERBATIM (only the three region packs were merged into
  one loop pack). Half the slice's packs carried over unchanged, which is itself
  a result: the coarse-by-role decomposition the slice already used needed no
  re-grounding.
- Cross-pack coupling nearly vanished (two edges, both from the loop pack down to
  the substrate and the dynamics) and the layer rule passed with zero friction.
  Coarse packing's cost is not at the pack boundary; it is inside the pack.

This Ledger is deliberately SHORT — four entries where the atomic arm had seven —
and that shortness is the finding the design asked for: one-pack-per-loop forced
almost nothing at the pack boundary (fewer packs, near-zero coupling, an easy
layer check), and pushed all of its cost INSIDE the pack, where PrologAI's
resolution stops. The full side-by-side measurement is in
[`COMPARISON.md`](COMPARISON.md).
