/*  Connectome slice — causal_map (Layer 1): the Causalontology 2.0.0 grounding.

    The GROUNDING RULE: ground the STRUCTURE in Causalontology 2.0.0, keep the
    DYNAMICS native. This pack is the structure. It MINTS the content-addressed
    records that describe the slice's anatomy — one of every KIND the cut must
    touch — using PrologAI's UNMODIFIED causal_core engine for identity and
    signing. It computes no rate constant and no plasticity increment: those
    live in the neurochemistry pack, deliberately NOT as records.

    What it mints (one thin cut through the kinds):
      - strata            the neuroendocrine ladder ordinals the slice uses
      - continuants       cortex, striatum, thalamus, substantia nigra (bearers)
      - occurrents        the events/processes the loop and the hormone realise
      - a realizable      the striatum's synaptic-plasticity disposition
      - ports             the corticostriatal and dopaminergic ports
      - a TRANSMISSIVE conduit    the nigrostriatal dopamine projection (no transform)
      - a COMPUTATIONAL conduit   the corticostriatal projection (transform = a CRO)
      - a plain CRO       the corticostriatal transform itself
      - a SKIPPING CRO    cortisol: community_and_society -> macromolecular, skips:true
      - a token           one particular cortisol episode, local-by-default, signed observer
      - a signed assertion  provenance over the skipping CRO (Ed25519)

    The Perfect Wire Test decides transmissive vs computational: a conduit is
    transmissive when a perfect wire would suffice (the dopamine projection just
    delivers the signal) and computational when it performs a transformation a
    wire cannot (the corticostriatal synapse applies a plasticity CRO).

    It imports only PrologAI's library(causal_core) and library(signing)
    (EXTERNAL — resolved on the library path, invisible to the slice's own layer
    graph). It is a pure minting leaf: it coordinates nothing, so it touches no
    other slice pack. Its declared layer(1) therefore has no intra-slice edge.
*/

% Declare the module and its public predicates.
:- module(causal_map, [
    % causal_map_records/1: the full list of record(Name, Kind, Dict) the slice mints.
    causal_map_records/1,
    % causal_map_signed_assertion/1: the Ed25519-signed provenance record over the skip CRO.
    causal_map_signed_assertion/1,
    % causal_map_skip_check/2: the semantic classification and skip-gaps of the cortisol CRO.
    causal_map_skip_check/2
]).

% Import PrologAI's Causalontology engine for content identity, kind inference, and semantics.
:- use_module(library(causal_core)).
% Import PrologAI's signing layer for the Ed25519 keypair and record signature.
:- use_module(library(signing)).
% Import SHA hashing for the deterministic keypair seed (the co_key convention).
:- use_module(library(sha)).
% Import dict/list utilities.
:- use_module(library(lists)).

% ---------------------------------------------------------------------------
% Minting helpers — each stamps the content-addressed id via causal_core.
% ---------------------------------------------------------------------------

% -- cm_id(+Body, -Out): stamp a content object with its Causalontology id.
cm_id(Body, Out) :-
    % Compute the content-addressed id (kind inferred from the body's type field).
    causal_core_identify(Body, _, Id),
    % Attach the id, yielding the complete record.
    put_dict(id, Body, Id, Out).

% -- cm_stratum(+Label, +Scheme, +Ordinal, +Unit, +Governs, -Out): a stratum record.
cm_stratum(Label, Scheme, Ordinal, Unit, Governs, Out) :-
    % Build the stratum body with its required fields.
    B0 = _{type:"stratum", label:Label, scheme:Scheme, ordinal:Ordinal, unit:Unit, governs:Governs},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_occ(+Label, +Category, +StratumId, -Out): a stratified occurrent record.
cm_occ(Label, Category, StratumId, Out) :-
    % Build the occurrent body carrying its stratum id (identity-bearing).
    B0 = _{type:"occurrent", label:Label, category:Category, stratum:StratumId},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_cnt(+Label, +Category, -Out): a continuant (bearer) record.
cm_cnt(Label, Category, Out) :-
    % Build the continuant body.
    B0 = _{type:"continuant", label:Label, category:Category},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_rlz(+Bearer, +Kind, +Label, -Out): a realizable record.
cm_rlz(Bearer, Kind, Label, Out) :-
    % Build the realizable body (a disposition/function/role borne by a continuant).
    B0 = _{type:"realizable", kind:Kind, bearer:Bearer, label:Label},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_port(+Bearer, +Label, +Direction, +Accepts, +Realizable, -Out): a port record.
cm_port(Bearer, Label, Direction, Accepts, Realizable, Out) :-
    % Build the port body carrying its optional realizable id.
    B0 = _{type:"port", bearer:Bearer, label:Label, direction:Direction, accepts:Accepts, realizable:Realizable},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_port(+Bearer, +Label, +Direction, +Accepts, -Out): a port with no realizable.
cm_port(Bearer, Label, Direction, Accepts, Out) :-
    % Build the port body without a realizable field.
    B0 = _{type:"port", bearer:Bearer, label:Label, direction:Direction, accepts:Accepts},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_conduit(+From, +To, +Carries, +Label, +Transform, -Out): a computational conduit.
cm_conduit(From, To, Carries, Label, Transform, Out) :-
    % Build the conduit body WITH a transform id — asserting it is COMPUTATIONAL.
    B0 = _{type:"conduit", from:From, to:To, carries:Carries, label:Label, transform:Transform},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_conduit(+From, +To, +Carries, +Label, -Out): a transmissive conduit.
cm_conduit(From, To, Carries, Label, Out) :-
    % Build the conduit body WITHOUT a transform — asserting it is TRANSMISSIVE.
    B0 = _{type:"conduit", from:From, to:To, carries:Carries, label:Label},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_cro(+Causes, +Effects, +Extra, -Out): a causal_relation_object with extra Key-Value fields.
cm_cro(Causes, Effects, Extra, Out) :-
    % Build the minimal CRO body.
    B0 = _{type:"causal_relation_object", causes:Causes, effects:Effects},
    % Fold each extra Key-Value pair into the body (modality, temporal, skips).
    foldl(cm_put_pair, Extra, B0, B1),
    % Stamp the id.
    cm_id(B1, Out).

% -- cm_put_pair(+Key-Value, +DictIn, -DictOut): add one Key-Value pair to a dict.
cm_put_pair(K-V, D, O) :-
    % Insert the pair.
    put_dict(K, D, V, O).

% -- cm_bridge(+Coarse, +Fine, +Relation, -Out): a cross-stratal bridge record.
cm_bridge(Coarse, Fine, Relation, Out) :-
    % Build the bridge body relating one coarse occurrent to finer ones.
    B0 = _{type:"bridge", coarse:Coarse, fine:Fine, relation:Relation},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_token(+Instantiates, +Interval, +Observer, -Out): a token occurrence (an episode).
cm_token(Instantiates, Interval, Observer, Out) :-
    % Build the token body with its observer (local-by-default: it belongs to one source).
    B0 = _{type:"token_occurrence", instantiates:Instantiates, interval:Interval, observer:Observer},
    % Stamp the id.
    cm_id(B0, Out).

% -- cm_key(+Name, -Secret, -Public): the deterministic Ed25519 keypair for a name (co_key convention).
cm_key(Name, Secret, Public) :-
    % Build the seed string "key:<Name>".
    atomic_list_concat(['key:', Name], KeyString),
    % Hash it with SHA-256 to a 32-byte seed.
    sha_hash(KeyString, Seed, [algorithm(sha256), encoding(utf8)]),
    % Derive the keypair; Public is "ed25519:<hex>".
    co_keypair_from_seed(Seed, Secret, Public).

% -- cm_map_of(+Objs, -Dict): a dict keyed by each object's atomized id.
cm_map_of(Objs, Dict) :-
    % Pair each object with its id as an atom key.
    findall(KA-O, (member(O, Objs), get_dict(id, O, Id), atom_string(KA, Id)), Pairs),
    % Deduplicate by key and build the dict.
    sort(1, @<, Pairs, Uniq),
    % Assemble the id-keyed dict.
    dict_pairs(Dict, _, Uniq).

% ---------------------------------------------------------------------------
% The build — all records minted once, ids threaded in dependency order.
% ---------------------------------------------------------------------------

% -- cm_build(-Records, -Signed, -SkipCro, -OccMap, -StratumMap): mint the whole map.
cm_build(Records, Signed, SkipCro, OccMap, StratumMap) :-
    % Strata: the neuroendocrine ladder ordinals the slice touches.
    cm_stratum("macromolecular", "neuroendocrine", 4, "macromolecule", ["molecular_biology"], SMacro),
    cm_stratum("synaptic", "neuroendocrine", 7, "synapse", ["synaptic_physiology"], SSyn),
    cm_stratum("cellular", "neuroendocrine", 6, "cell", ["cell_biology"], SCell),
    cm_stratum("region", "neuroendocrine", 9, "brain_region", ["systems_neuroscience"], SRegion),
    cm_stratum("community_and_society", "neuroendocrine", 14, "community", ["sociology"], SCommunity),
    % Continuants: the region bearers.
    cm_cnt("cortex", "object", CCortex),
    cm_cnt("striatum", "object", CStriatum),
    cm_cnt("thalamus", "object", CThalamus),
    cm_cnt("substantia_nigra_pars_compacta", "object", CSnc),
    % Occurrents: the loop's and the hormone's events/processes, each stratified.
    cm_occ("action_selection", "process", SRegion.id, OSelect),
    cm_occ("neurotransmitter_release", "event", SSyn.id, ORelease),
    cm_occ("dopamine_release", "event", SSyn.id, ODopamine),
    cm_occ("corticostriatal_drive", "process", SSyn.id, ODrive),
    cm_occ("synaptic_weight_change", "state_change", SSyn.id, OUpdate),
    cm_occ("chronic_social_subordination", "process", SCommunity.id, OSocial),
    cm_occ("glucocorticoid_gene_expression", "state_change", SMacro.id, OGene),
    % A realizable: the striatum's synaptic-plasticity disposition.
    cm_rlz(CStriatum.id, "disposition", "synaptic_plasticity", RPlast),
    % Ports: cortical output, corticostriatal input (bearing the plasticity disposition), dopaminergic out/in.
    cm_port(CCortex.id, "cortical_output", "out", [ODrive.id], PCortexOut),
    cm_port(CStriatum.id, "corticostriatal_input", "in", [ODrive.id], RPlast.id, PStriatumIn),
    cm_port(CSnc.id, "dopaminergic_output", "out", [ODopamine.id], PSncOut),
    cm_port(CStriatum.id, "dopaminergic_input", "in", [ODopamine.id], PStriatumDop),
    % A plain CRO: the corticostriatal transform (drive -> weight change), the conduit's computation.
    cm_cro([ODrive.id], [OUpdate.id],
           [modality-"sufficient", temporal-_{minimum_delay:0, maximum_delay:1, unit:"seconds"}],
           CroPlast),
    % A TRANSMISSIVE conduit: the nigrostriatal dopamine projection (no transform).
    cm_conduit(PSncOut.id, PStriatumDop.id, [ODopamine.id], "nigrostriatal_projection", KDopamine),
    % A COMPUTATIONAL conduit: the corticostriatal projection (transform = the plasticity CRO).
    cm_conduit(PCortexOut.id, PStriatumIn.id, [ODrive.id], "corticostriatal_projection", CroPlast.id, KCortico),
    % A cross-stratal BRIDGE: action_selection (region 9) realises finer synaptic events (7).
    cm_bridge(OSelect.id, [ORelease.id, ODopamine.id], "realizes", BSelect),
    % The SKIPPING CRO: cortisol — community_and_society (14) -> macromolecular (4), skips:true, NO mechanism.
    cm_cro([OSocial.id], [OGene.id], [skips-true], SkipCro),
    % A token occurrence: one particular cortisol episode, with a signed observer (local-by-default).
    cm_key("connectome_slice", _Sec, Observer),
    cm_token(OGene.id, _{start:"2026-07-17T00:00:00Z", end:"2026-07-17T01:00:00Z"}, Observer, TEpisode),
    % A signed provenance ASSERTION over the skipping CRO (Ed25519).
    cm_signed_assertion_over(SkipCro.id, Signed),
    % Assemble the labelled record list in the order the cut names them.
    Records = [
        record(stratum_macromolecular,   stratum,                SMacro),
        record(stratum_synaptic,         stratum,                SSyn),
        record(stratum_cellular,         stratum,                SCell),
        record(stratum_region,           stratum,                SRegion),
        record(stratum_community,        stratum,                SCommunity),
        record(continuant_cortex,        continuant,             CCortex),
        record(continuant_striatum,      continuant,             CStriatum),
        record(continuant_thalamus,      continuant,             CThalamus),
        record(continuant_snc,           continuant,             CSnc),
        record(occurrent_action_selection, occurrent,            OSelect),
        record(occurrent_nt_release,     occurrent,              ORelease),
        record(occurrent_dopamine_release, occurrent,            ODopamine),
        record(occurrent_corticostriatal_drive, occurrent,       ODrive),
        record(occurrent_weight_change,  occurrent,              OUpdate),
        record(occurrent_social_subordination, occurrent,        OSocial),
        record(occurrent_gene_expression, occurrent,             OGene),
        record(realizable_plasticity,    realizable,             RPlast),
        record(port_cortical_output,     port,                   PCortexOut),
        record(port_corticostriatal_input, port,                 PStriatumIn),
        record(port_dopaminergic_output, port,                   PSncOut),
        record(port_dopaminergic_input,  port,                   PStriatumDop),
        record(cro_corticostriatal_transform, causal_relation_object, CroPlast),
        record(conduit_nigrostriatal_transmissive, conduit,      KDopamine),
        record(conduit_corticostriatal_computational, conduit,   KCortico),
        record(bridge_action_selection,  bridge,                 BSelect),
        record(cro_cortisol_skip,        causal_relation_object, SkipCro),
        record(token_cortisol_episode,   token_occurrence,       TEpisode),
        record(assertion_skip_provenance, assertion,             Signed)
    ],
    % Build the occurrent and stratum maps for the skip CRO's semantic classification.
    cm_map_of([OSocial, OGene], OccMap),
    cm_map_of([SCommunity, SMacro], StratumMap).

% -- cm_signed_assertion_over(+AboutId, -Signed): an Ed25519-signed assertion over a record id.
cm_signed_assertion_over(AboutId, Signed) :-
    % Derive the slice's deterministic signing key.
    cm_key("connectome_slice", Secret, Public),
    % Build the assertion body naming the signer (source) and its evidence.
    Body = _{type:"assertion", about:AboutId, evidence_type:"observation",
             confidence:0.9, timestamp:"2026-07-17T01:00:00Z", source:Public},
    % Sign it: this stamps both the content id and the Ed25519 signature.
    co_sign_record(Body, Secret, assertion, Signed).

% ---------------------------------------------------------------------------
% Public projections over the build.
% ---------------------------------------------------------------------------

% -- causal_map_records(-Records): the full labelled record list.
causal_map_records(Records) :-
    % Run the build and project the record list.
    cm_build(Records, _, _, _, _).

% -- causal_map_signed_assertion(-Signed): the signed provenance record.
causal_map_signed_assertion(Signed) :-
    % Run the build and project the signed assertion.
    cm_build(_, Signed, _, _, _).

% -- causal_map_skip_check(-Class, -Gaps): classify the cortisol CRO and read its skip-gaps.
causal_map_skip_check(Class, Gaps) :-
    % Run the build to obtain the skip CRO and its occurrent/stratum maps.
    cm_build(_, _, SkipCro, OccMap, StratumMap),
    % Classify the cross-stratal relation (expected: skipping).
    causal_core_classify(SkipCro, OccMap, StratumMap, Class),
    % Read the skip-gaps (expected: none — the absence of a mechanism is a positive finding).
    causal_core_skip_gaps(SkipCro, Class, Gaps).
