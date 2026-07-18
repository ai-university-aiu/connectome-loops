% Test suite for the loop pack (the whole reentrant circuit, regions internal).
% The three region ticks block on Lattice cues, so the loop's full behaviour is
% exercised end-to-end by bin/run_slice.sh (the closure verdict is its real test);
% this in-pack test confirms the module loads and exposes all three region ticks,
% so the pack can never rot silently out of the per-pack regression.
% Load the loop module under test.
:- use_module(library(loop)).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).

% Open the test block for the loop pack.
:- begin_tests(loop).

% The loop pack exposes its three internal region ticks as its public interface.
test(exports_three_region_ticks) :-
    % The cortex tick is defined and callable.
    current_predicate(loop_cortex_tick/1),
    % The striatum tick is defined and callable.
    current_predicate(loop_striatum_tick/1),
    % The thalamus tick is defined and callable.
    current_predicate(loop_thalamus_tick/1).

% Close the test block.
:- end_tests(loop).
