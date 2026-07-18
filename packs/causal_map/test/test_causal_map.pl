% Test suite for the causal_map pack (Causalontology 2.0.0 grounding).
% Load the causal_map module under test.
:- use_module(library(causal_map)).
% Load PrologAI's schema validator to check the minted records here too.
:- use_module(library(schema_check)).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load list utilities.
:- use_module(library(lists)).

% Open the test block for the causal_map pack.
:- begin_tests(causal_map).

% Every minted record validates against its Causalontology 2.0.0 schema.
test(all_records_schema_valid) :-
    % Mint the full record list.
    causal_map_records(Records),
    % There is at least one record of each kind the cut must touch.
    forall(member(record(_Name, Kind, Dict), Records),
           co_validate_schema(Dict, Kind, true, [])).

% The cut touches the required Causalontology kinds.
test(covers_required_kinds) :-
    % Mint the records and collect their distinct kinds.
    causal_map_records(Records),
    findall(K, member(record(_, K, _), Records), Ks0), sort(Ks0, Ks),
    % Confirm each required kind is present.
    forall(member(Need, [stratum, bridge, port, conduit, realizable,
                         causal_relation_object, token_occurrence]),
           memberchk(Need, Ks)).

% Both a transmissive and a computational conduit are present (Perfect Wire Test).
test(both_conduit_flavours) :-
    % Mint the records.
    causal_map_records(Records),
    % Find the two conduits.
    findall(Dict, member(record(_, conduit, Dict), Records), Conduits),
    % Exactly one carries a transform (computational) and one does not (transmissive).
    include([D]>>get_dict(transform, D, _), Conduits, Computational),
    exclude([D]>>get_dict(transform, D, _), Conduits, Transmissive),
    length(Computational, 1), length(Transmissive, 1).

% The cortisol CRO is a genuine layer-skip: classified skipping, with no skip-gap.
test(cortisol_is_a_clean_skip) :-
    % Read the semantic classification and skip-gaps.
    causal_map_skip_check(Class, Gaps),
    % It skips ten strata with no gap — the absence of a mechanism is a positive finding.
    Class == skipping, Gaps == [].

% The signed provenance assertion over the skip CRO verifies.
test(signed_provenance_verifies) :-
    % A signed assertion exists and has a signature field.
    causal_map_signed_assertion(Signed),
    get_dict(signature, Signed, _).

% Close the test block.
:- end_tests(causal_map).
