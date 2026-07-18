/*  Connectome loops — the runner (loops arm of the Wave 3 granularity experiment).

    Ticks the reentrant cortico-basal-ganglia-thalamo-cortical loop for N laps and
    prints the narrated, glass-box trace. The BEHAVIOUR is held constant with the
    Wave 2 slice and the atomic arm — only the pack boundaries differ (here the
    whole loop is ONE pack, its three regions internal). Each region runs as a
    PrologAI cyclic_actor (a background thread) on the loop pack's internal tick
    predicate; the regions coordinate ONLY through the Lattice, via numbered phase
    cues and lattice_await/notify — stigmergy for state, notification for
    reactivity, zero actor-to-actor references, no busy-poll. When the loop comes
    to rest the runner PROVES it closed. Exit 0 on a clean, proven run.

    Usage:  swipl ... bin/run_slice.pl -- <NLaps> <EventLap> <Rate>
*/

% Import PrologAI's actors pack for the cyclic_actor background threads.
:- use_module(library(cyclic_actor)).
% Import the arm's Lattice substrate: open/reset/seed/await-done/trace.
:- use_module(library(neural_lattice)).
% Import the single loop pack; its three internal region ticks drive the circuit.
:- use_module(library(loop)).
% Import list utilities for building and checking the expected hop sequence.
:- use_module(library(lists)).

% -- run_slice(+NLaps, +EventLap, +Rate): run and prove the loop, then halt.
run_slice(NLaps, EventLap, Rate) :-
    % Open (or reuse) the arm's single coordination nexus.
    neural_lattice_open(Nexus),
    % Wipe any facts and trace from a prior run for a clean start.
    neural_lattice_reset(Nexus),
    % Print the run banner naming the loop and its parameters.
    run_slice_banner(NLaps, EventLap, Rate),
    % Spawn the three region threads on the loop pack's internal ticks; each blocks on its own cue.
    cyclic_actor(cortex,   loop:loop_cortex_tick(Nexus),     0),
    cyclic_actor(striatum, loop:loop_striatum_tick(Nexus), 0),
    cyclic_actor(thalamus, loop:loop_thalamus_tick(Nexus), 0),
    % Build the seed state snapshot that will circulate around the ring.
    Seed = _{ lap:1, token:0, weight:0.0, prediction:0.0, dopamine:0.0,
              cortisol:0.0, reward:0.0, n_laps:NLaps, rate:Rate, event_lap:EventLap },
    % Seed the loop by posting the phase-0 cue: the cortex wakes and the loop begins.
    neural_lattice_post_cue(Nexus, 0, Seed),
    % Block (bounded) until the cortex signals the loop has come to rest.
    ( neural_lattice_await_done(Nexus, 30, FinalToken)
    % The loop reported completion: record the final token.
    ->  Outcome = done(FinalToken)
    % The loop failed to complete within the timeout: record a stall.
    ;   Outcome = stalled ),
    % Stop the three region threads now that the loop is at rest.
    run_slice_stop_actors,
    % Verify the retained trace actually proves the loop closed for N laps.
    run_slice_verdict(NLaps, Outcome, Verdict),
    % Halt with success only when the verdict is a clean, proven closure.
    ( Verdict == pass -> halt(0) ; halt(1) ).

% -- run_slice_banner(+NLaps, +EventLap, +Rate): print the run header.
run_slice_banner(NLaps, EventLap, Rate) :-
    % Print a blank line then the arm name.
    format("~n== connectome-loops :: one pack per reentrant loop (Wave 3b) ==~n", []),
    % Print the loop being ticked.
    format("Loop: cortex -> striatum -> thalamus -> cortex (reentrant; regions internal to one pack)~n", []),
    % Print the coordination discipline in force.
    format("Coordination: stigmergy (Lattice) + notification (lattice_await/notify); zero actor-to-actor refs; no busy-poll~n", []),
    % Print the run parameters.
    format("Laps=~w  cortisol_event_lap=~w  learning_rate=~w~n~n", [NLaps, EventLap, Rate]).

% -- run_slice_stop_actors/0: stop each region thread, tolerating an already-stopped one.
run_slice_stop_actors :-
    % Stop each of the three regions in turn, ignoring any that already exited.
    forall(member(Name, [cortex, striatum, thalamus]),
           ignore(catch(cyclic_actor_stop(Name), _, true))).

% -- run_slice_verdict(+NLaps, +Outcome, -Verdict): prove (or refute) the closure.
run_slice_verdict(NLaps, Outcome, Verdict) :-
    % Fetch the retained hop trace in order.
    neural_lattice_trace(Hops),
    % Extract the acting-region sequence from the hops.
    findall(Region, member(hop(_, Region, _), Hops), Regions),
    % Extract the token sequence from the hops.
    findall(Token, member(hop(_, _, Token), Hops), Tokens),
    % The loop is a total of 3N+1 hops (one cortex seed, then N of [striatum,thalamus,cortex]).
    ExpectedHops is 3 * NLaps + 1,
    % Build the expected region sequence: cortex, then N repetitions of [striatum, thalamus, cortex].
    run_slice_expected_regions(NLaps, ExpectedRegions),
    % Build the expected strictly-monotonic token sequence 1..3N+1.
    numlist(1, ExpectedHops, ExpectedTokens),
    % Count how many times the cortex acted (should be N re-entries plus the seed = N+1).
    include(==(cortex), Regions, CortexHops),
    length(CortexHops, CortexCount),
    % Check every closure condition.
    ( Outcome = done(_),
      length(Hops, ExpectedHops),
      Regions == ExpectedRegions,
      Tokens == ExpectedTokens,
      CortexCount =:= NLaps + 1
    % All conditions held: the loop provably closed.
    ->  Verdict = pass
    % Some condition failed: the loop did not close cleanly.
    ;   Verdict = fail ),
    % Print the verdict block.
    run_slice_report(NLaps, Outcome, ExpectedHops, Hops, Verdict).

% -- run_slice_expected_regions(+NLaps, -Regions): the expected acting-region sequence.
run_slice_expected_regions(NLaps, [cortex|Rest]) :-
    % Build the N repetitions of the striatum-thalamus-cortex triple.
    findall([striatum, thalamus, cortex], between(1, NLaps, _), Triples),
    % Flatten the repetitions into one region list following the cortex seed.
    append(Triples, Rest).

% -- run_slice_report(+NLaps, +Outcome, +ExpectedHops, +Hops, +Verdict): print the proof.
run_slice_report(NLaps, Outcome, ExpectedHops, Hops, Verdict) :-
    % Count the actual hops recorded.
    length(Hops, ActualHops),
    % Print a blank line then the verdict header.
    format("~n-- closure verdict --~n", []),
    % Report the completion outcome (done with final token, or stalled).
    format("  outcome            : ~w~n", [Outcome]),
    % Report the hop count against the expectation.
    format("  hops               : ~w (expected ~w)~n", [ActualHops, ExpectedHops]),
    % Report the laps requested.
    format("  laps               : ~w~n", [NLaps]),
    % Restate the structural guarantees the design gives for free.
    format("  actor-to-actor refs: 0 (regions share a pack but only the Lattice; verified by bin/check_no_coupling.sh)~n", []),
    % Restate that reactivity was notification-driven, not polled.
    format("  busy-poll          : none (lattice_await blocks on a queue; woken by lattice_notify)~n", []),
    % Print the overall verdict.
    format("  VERDICT            : ~w~n~n", [Verdict]).

% -- run_slice_main/0: read the three integer/float arguments and run the loop.
run_slice_main :-
    % Read the command-line arguments after the -- separator.
    current_prolog_flag(argv, Argv),
    % Parse the three parameters, defaulting when they are absent.
    run_slice_args(Argv, NLaps, EventLap, Rate),
    % Run the loop with the parsed parameters.
    run_slice(NLaps, EventLap, Rate).

% -- run_slice_args(+Argv, -NLaps, -EventLap, -Rate): parse args with sensible defaults.
run_slice_args([A, B, C|_], NLaps, EventLap, Rate) :-
    % When all three are given, parse each as a number.
    !,
    % Parse the number of laps.
    atom_number(A, NLaps),
    % Parse the cortisol event lap.
    atom_number(B, EventLap),
    % Parse the learning rate.
    atom_number(C, Rate).
run_slice_args(_, 8, 5, 0.4).
    % Default: 8 laps, a cortisol event on lap 5, learning rate 0.4.

% Run the loop as soon as the file is loaded (the shell script sets argv).
:- initialization(run_slice_main).
