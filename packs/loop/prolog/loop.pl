/*  Connectome loops — the reentrant loop (Layer 2): the whole circuit as ONE pack.

    THE LOOPS-ARM RULE: one pack per reentrant loop or circuit. The three regions
    of the cortico-basal-ganglia-thalamo-cortical loop — cortex, striatum,
    thalamus — are INTERNAL MODULES of this single pack: the three clearly
    delimited sections below (each marked "INTERNAL REGION MODULE: <name>"), with
    loop_<region>_ prefixed predicates. They are NOT packs in their own right.
    This is the coarse contrast to connectome-atomic, where each region was its
    own pack (and each neurochemical, and each interface).

    THE CLOSURE RULE STILL HOLDS INSIDE THE PACK. Sharing a pack is NOT a licence
    to couple: the three region sections NEVER call one another. Each awaits its
    own numbered phase cue and posts the NEXT slot's cue through the Lattice — a
    positional NUMBER, never a name (zero actor-to-actor references, enforced
    across the section boundary by bin/check_no_coupling.sh, which reads this file
    section by section). The loop closes at RUNTIME through the shared Lattice,
    exactly as in the slice; the static graph has no region-to-region edge because
    no section imports or calls another.

    The DYNAMICS stay native and coarse: dopamine, cortisol, and the three-factor
    plasticity rule live in library(neurochemistry) (one pack), reused verbatim.
    The STRUCTURE stays in library(causal_map) (one pack, all 28 records) — which
    this loop does NOT import, so the runtime and the grounding stay cleanly
    separate (unlike the atomic arm, where co-location fused them).

    Imports library(neural_lattice) (Layer 0) and library(neurochemistry)
    (Layer 1) — both downward, so the layer rule holds. NOTE: this ONE pack spans
    what the slice and atomic arms expressed as THREE region layers (cortex 4,
    striatum 3, thalamus 2). The loops arm collapses that internal hierarchy into
    a single pack layer, and the layer construct — being pack-granular — can no
    longer see it (see LEDGER.md, LOOPS-1).
*/

% Declare the module and the three region tick predicates it exposes to the runner.
:- module(loop, [
    % loop_cortex_tick/1: one cortical step (the origin and re-entry point).
    loop_cortex_tick/1,
    % loop_striatum_tick/1: one striatal step (dopamine-gated plasticity).
    loop_striatum_tick/1,
    % loop_thalamus_tick/1: one thalamic step (the relay that closes the loop).
    loop_thalamus_tick/1
]).

% Import the Lattice substrate (Layer 0) for cue await/post and narration.
:- use_module(library(neural_lattice)).
% Import the neurochemistry (Layer 1): reward schedule, dopamine RPE, cortisol, three-factor plasticity.
:- use_module(library(neurochemistry)).

% ============================================================================
% INTERNAL REGION MODULE: cortex — the origin and re-entry point (slice layer 4)
% ============================================================================

% -- loop_cortex_tick(+Nexus): block for the phase-0 cue, predict, and either hand on or finish.
loop_cortex_tick(Nexus) :-
    % Block with no busy-poll until the beat has returned to phase 0, then take that cue.
    neural_lattice_await_cue(Nexus, 0, State0),
    % Read the current lap number.
    get_dict(lap, State0, Lap),
    % Read the number of laps the loop should run.
    get_dict(n_laps, State0, NLaps),
    % Read the current corticostriatal weight, which the cortex reads as its reward prediction.
    get_dict(weight, State0, Weight),
    % Read the running token counter.
    get_dict(token, State0, Token0),
    % Advance the token by one for the cortical hop.
    Token is Token0 + 1,
    % Record and print the cortical hop; the beat arrived VIA the Lattice, re-entering the loop.
    neural_lattice_hop(lattice, cortex, Token),
    % Decide whether this re-entry is the terminal one or a continuing lap.
    loop_cortex_step(Nexus, Lap, NLaps, Weight, Token, State0).

% -- loop_cortex_step(+Nexus, +Lap, +NLaps, +Weight, +Token, +State0): terminate or continue.
loop_cortex_step(Nexus, Lap, NLaps, _Weight, Token, _State0) :-
    % The loop is at rest once the cortex re-enters beyond the last lap.
    Lap > NLaps,
    !,
    % Narrate that the loop has closed for the full number of laps.
    format(string(Line), "cortex: lap ~w exceeds ~w -- loop at rest; final token=~w", [Lap, NLaps, Token]),
    % Print the closing narration line.
    neural_lattice_narrate('    ', Line),
    % Signal the driver that the loop has come to rest, carrying the final token.
    neural_lattice_signal_done(Nexus, Token).
loop_cortex_step(Nexus, Lap, NLaps, Weight, Token, State0) :-
    % Otherwise this is a continuing lap: the cortex predicts reward from its learned value.
    Prediction = Weight,
    % Narrate the lap header and the cortical prediction, in glass-box style.
    format(string(Line), "cortex: lap ~w/~w  predict(value)=~4f", [Lap, NLaps, Prediction]),
    % Print the narration line.
    neural_lattice_narrate('    ', Line),
    % Update the state snapshot with the token and the prediction for the next slot to use.
    State1 = State0.put(_{token: Token, prediction: Prediction}),
    % Post the phase-1 cue: hand the beat to the next slot by NUMBER, naming no region.
    neural_lattice_post_cue(Nexus, 1, State1).

% ============================================================================
% INTERNAL REGION MODULE: striatum — the dopamine-gated plasticity site (slice layer 3)
% ============================================================================

% -- loop_striatum_tick(+Nexus): block for the phase-1 cue, run dopamine-gated plasticity, hand on.
loop_striatum_tick(Nexus) :-
    % Block with no busy-poll until phase 1 has been cued, then take that cue.
    neural_lattice_await_cue(Nexus, 1, State0),
    % Read the current lap number (drives the reward schedule).
    get_dict(lap, State0, Lap),
    % Read the prediction of reward (the value estimate = the synaptic weight).
    get_dict(prediction, State0, Prediction),
    % Read the current corticostriatal synaptic weight to be updated.
    get_dict(weight, State0, Weight0),
    % Read the prevailing cortisol tone (suppresses plasticity when elevated).
    get_dict(cortisol, State0, Cortisol),
    % Read the learning rate for the three-factor rule.
    get_dict(rate, State0, Rate),
    % Read the running token counter.
    get_dict(token, State0, Token0),
    % Determine the reward delivered on this lap.
    neurochemistry_reward(Lap, Reward),
    % Form the dopamine reward-prediction-error: reward minus predicted reward.
    neurochemistry_dopamine(Reward, Prediction, Dopamine),
    % Apply the three-factor plasticity rule (pre and post activity are both 1.0 here).
    neurochemistry_plasticity(Weight0, 1.0, 1.0, Dopamine, Cortisol, Rate, Weight),
    % Advance the token by one for the striatal hop.
    Token is Token0 + 1,
    % Record and print the striatal hop; the beat arrived VIA the Lattice.
    neural_lattice_hop(lattice, striatum, Token),
    % Narrate the dopamine computation and the gated weight change, in glass-box style.
    format(string(Line),
        "striatum: reward=~2f prediction=~4f dopamine(RPE)=~4f cortisol=~3f weight ~4f -> ~4f",
        [Reward, Prediction, Dopamine, Cortisol, Weight0, Weight]),
    % Print the narration line at the standard indent.
    neural_lattice_narrate('      ', Line),
    % Update the state snapshot with the new weight, dopamine, reward, and token.
    State1 = State0.put(_{weight: Weight, dopamine: Dopamine, reward: Reward, token: Token}),
    % Post the phase-2 cue: hand the beat to the next slot by NUMBER, naming no region.
    neural_lattice_post_cue(Nexus, 2, State1).

% ============================================================================
% INTERNAL REGION MODULE: thalamus — the relay that closes the loop (slice layer 2)
% ============================================================================

% -- loop_thalamus_tick(+Nexus): block for the phase-2 cue, relay the beat, close the loop.
loop_thalamus_tick(Nexus) :-
    % Block with no busy-poll until phase 2 has been cued, then take that cue.
    neural_lattice_await_cue(Nexus, 2, State0),
    % Read the current lap number from the state snapshot.
    get_dict(lap, State0, Lap),
    % Read the running token counter (the closure proof's monotonic value).
    get_dict(token, State0, Token0),
    % Read the current cortisol tone.
    get_dict(cortisol, State0, Cortisol0),
    % Read the lap on which the social-stress cortisol event fires.
    get_dict(event_lap, State0, EventLap),
    % Advance the token by one for this hop (the relay is a hop like any other).
    Token is Token0 + 1,
    % Record and print the thalamic hop; the beat arrived VIA the Lattice, not from a named sender.
    neural_lattice_hop(lattice, thalamus, Token),
    % Decide the cortisol tone for the next lap: surge on the event lap, else decay.
    loop_thalamus_cortisol(Lap, EventLap, Cortisol0, Cortisol),
    % The loop closes by handing the beat to the next lap: increment the lap number.
    NextLap is Lap + 1,
    % Update the state snapshot with the new token, cortisol tone, and lap.
    State1 = State0.put(_{token: Token, cortisol: Cortisol, lap: NextLap}),
    % Post the phase-0 cue: the beat returns to the origin slot by NUMBER, naming no region.
    neural_lattice_post_cue(Nexus, 0, State1).

% -- loop_thalamus_cortisol(+Lap, +EventLap, +Old, -New): the cortisol tone for the next lap.
loop_thalamus_cortisol(Lap, Lap, _Old, 3.0) :-
    % On the event lap the chronic social subordination drives a cortisol surge to 3.0.
    !,
    % Narrate the layer-skip in glass-box style: one physical step across ten strata, no mechanism.
    neural_lattice_narrate('    ',
        'CORTISOL EVENT: chronic_social_subordination @ community_and_society (ordinal 14) -> gene_expression @ macromolecular (ordinal 4): one physical step, ten strata skipped, no intervening mechanism (skips:true). Glucocorticoid tone now suppresses corticostriatal plasticity.').
loop_thalamus_cortisol(_Lap, _EventLap, Old, New) :-
    % On every other lap the cortisol tone simply decays toward baseline.
    neurochemistry_cortisol_decay(Old, New).
