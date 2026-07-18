/*  connectome-loops (Wave 3b, the loops arm) — neurochemistry (Layer 1): the NATIVE DYNAMICS, reused verbatim from the Wave 2 slice.

    The GROUNDING RULE says: ground the STRUCTURE in Causalontology 2.0.0, but
    keep the DYNAMICS native. This pack is the dynamics. None of it is a
    causal_relation_object or any other Causalontology record: a rate constant,
    a reward-prediction-error, and a plasticity increment are numbers evolving
    in time, and forcing them into a content-addressed structure record would
    be a category error. So dopamine kinetics, cortisol tone, and the
    three-factor plasticity rule live here as ordinary Prolog arithmetic.

    DOPAMINE is the reward-prediction-error (RPE) signal: the difference
    between the reward actually received and the reward the cortex predicted.
    It is the THIRD FACTOR that gates plasticity — without it the rule would be
    plain Hebbian coincidence detection; with it, the synapse learns only in
    proportion to surprise.

    CORTISOL is the slow glucocorticoid tone. Biologically a chronic-stress
    cortisol elevation suppresses corticostriatal plasticity; here it enters
    the three-factor rule as a multiplicative suppression factor, giving the
    hormone a real dynamical effect on top of the structural layer-skip the
    causal_map pack records.

    This pack is a pure LEAF: it imports no other slice pack, because the
    dynamics are self-contained arithmetic. The regions above it (Layers 2-4)
    import IT — those are the downward edges the strict layer rule permits.
*/

% Declare the module and its public predicates.
:- module(neurochemistry, [
    % neurochemistry_reward/2: the reward delivered on a given lap.
    neurochemistry_reward/2,
    % neurochemistry_dopamine/3: the reward-prediction-error (RPE) dopamine signal.
    neurochemistry_dopamine/3,
    % neurochemistry_cortisol_suppression/2: the plasticity suppression factor for a cortisol level.
    neurochemistry_cortisol_suppression/2,
    % neurochemistry_plasticity/7: the three-factor synaptic update.
    neurochemistry_plasticity/7,
    % neurochemistry_cortisol_decay/2: one step of cortisol return toward baseline.
    neurochemistry_cortisol_decay/2,
    % neurochemistry_clamp/4: clamp a value into a closed interval.
    neurochemistry_clamp/4
]).

% -- neurochemistry_reward(+Lap, -Reward): the reward on this lap.
% A reliable cue-reward association: reward is 1.0 on every lap, so the classic
% RPE signature appears — dopamine starts high and decays toward zero as the
% cortex's prediction rises to meet the reward.
neurochemistry_reward(_Lap, 1.0).

% -- neurochemistry_dopamine(+Reward, +Prediction, -Dopamine): the RPE signal.
neurochemistry_dopamine(Reward, Prediction, Dopamine) :-
    % Dopamine phasic firing encodes reward minus predicted reward (Rescorla-Wagner / TD error).
    Dopamine is Reward - Prediction.

% -- neurochemistry_cortisol_suppression(+Cortisol, -Factor): plasticity gain under stress.
neurochemistry_cortisol_suppression(Cortisol, Factor) :-
    % Higher glucocorticoid tone shrinks the plasticity gain; baseline (0) leaves it at 1.0.
    Factor is 1.0 / (1.0 + Cortisol).

% -- neurochemistry_cortisol_decay(+Cortisol, -NewCortisol): slow return toward baseline.
neurochemistry_cortisol_decay(Cortisol, NewCortisol) :-
    % Cortisol clears with a slow exponential decay (retains 90 percent each lap).
    NewCortisol is Cortisol * 0.9.

% -- neurochemistry_plasticity(+Weight, +Pre, +Post, +Dopamine, +Cortisol, +Rate, -NewWeight):
% the THREE-FACTOR rule: change = rate * presynaptic * postsynaptic * dopamine, scaled by cortisol tone.
neurochemistry_plasticity(Weight, Pre, Post, Dopamine, Cortisol, Rate, NewWeight) :-
    % Compute the cortisol-dependent suppression of the plasticity gain.
    neurochemistry_cortisol_suppression(Cortisol, Suppression),
    % The weight change is the product of the three factors, the learning rate, and the suppression.
    Delta is Rate * Pre * Post * Dopamine * Suppression,
    % Apply the change to the current weight.
    Raw is Weight + Delta,
    % Keep the synaptic weight inside the unit interval (a bounded efficacy).
    neurochemistry_clamp(Raw, 0.0, 1.0, NewWeight).

% -- neurochemistry_clamp(+X, +Low, +High, -Y): clamp X into [Low, High].
neurochemistry_clamp(X, Low, _High, Low) :-
    % When X is at or below the lower bound, clamp to the lower bound.
    X =< Low, !.
neurochemistry_clamp(X, _Low, High, High) :-
    % When X is at or above the upper bound, clamp to the upper bound.
    X >= High, !.
neurochemistry_clamp(X, _Low, _High, X).
    % Otherwise X is already inside the interval; pass it through unchanged.
