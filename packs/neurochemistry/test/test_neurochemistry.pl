% Test suite for the neurochemistry pack (native dynamics).
% Load the neurochemistry module under test.
:- use_module(library(neurochemistry)).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).

% Open the test block for the neurochemistry pack.
:- begin_tests(neurochemistry).

% The dopamine signal is reward minus prediction (a reward-prediction-error).
test(dopamine_is_rpe) :-
    % A perfect prediction yields zero dopamine.
    neurochemistry_dopamine(1.0, 1.0, D0), D0 =:= 0.0,
    % An unpredicted reward yields a full positive error.
    neurochemistry_dopamine(1.0, 0.0, D1), D1 =:= 1.0.

% Cortisol suppression is 1.0 at baseline and strictly below 1.0 when elevated.
test(cortisol_suppresses) :-
    % Baseline tone leaves the plasticity gain untouched.
    neurochemistry_cortisol_suppression(0.0, S0), S0 =:= 1.0,
    % Elevated tone shrinks the gain below one.
    neurochemistry_cortisol_suppression(3.0, S1), S1 < 1.0.

% The three-factor rule raises the weight on a positive error and stays bounded.
test(plasticity_bounded_and_gated) :-
    % A positive error with no cortisol raises the weight toward the reward.
    neurochemistry_plasticity(0.0, 1.0, 1.0, 1.0, 0.0, 0.4, W1), W1 > 0.0, W1 =< 1.0,
    % Zero dopamine produces no weight change (the third factor gates learning).
    neurochemistry_plasticity(0.5, 1.0, 1.0, 0.0, 0.0, 0.4, W2), W2 =:= 0.5,
    % Elevated cortisol shrinks the same update.
    neurochemistry_plasticity(0.0, 1.0, 1.0, 1.0, 3.0, 0.4, W3), W3 < W1.

% Cortisol decays toward baseline between events.
test(cortisol_decays) :-
    % One decay step reduces the tone.
    neurochemistry_cortisol_decay(3.0, C), C < 3.0.

% Close the test block.
:- end_tests(neurochemistry).
