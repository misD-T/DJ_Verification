(*************************************************************)
(* GroverConvergenceExperiment.v                             *)
(*                                                           *)
(* Experimental evaluation of Grover probability evolution   *)
(*                                                           *)
(* This file is oracle-family independent.                    *)
(* A marked state is supplied by GroverMarkedState.           *)
(*************************************************************)

From Coq Require Import List Bool Arith Reals.

Import ListNotations.

Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.BooleanFunctions.
Require Import forms.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOperators.
Require Import Grover.GroverTrace.
Require Import Grover.GroverExperiments.
Require Import Grover.GroverExperimentResults.
Require Import Grover.GroverOracles.



(*************************************************************)
(* Experiment Definition                                     *)
(*************************************************************)


Definition GroverConvergenceData
        (n : nat)
        (f : OracleInstance)
        : list GroverDataPoint :=

match GroverMarkedState n f with

| Some marked =>

    TraceToData
       n
       (ExampleGroverTrace n f)
       marked

| None => []

end.



(*************************************************************)
(* Trace Extraction Sanity                                   *)
(*************************************************************)


Lemma GroverConvergenceData_length :

forall n f marked,

GroverMarkedState n f = Some marked

->

length
 (GroverConvergenceData n f)

=

length
 (ExampleGroverTrace n f).

Proof.

  intros n f marked H.

  unfold GroverConvergenceData.

  rewrite H.

  simpl.

  apply TraceToData_length.

Qed.



(*************************************************************)
(* State Preservation                                        *)
(*************************************************************)


Lemma GroverConvergenceData_state :

forall n f d,

In d
   (GroverConvergenceData n f)

->

exists marked,

GroverMarkedState n f = Some marked
/\

DataState d = marked.

Proof.

  intros n f d H.

  unfold GroverConvergenceData in H.

  destruct (GroverMarkedState n f) eqn:Hmarked.

  - exists b.

    split.

    + reflexivity.

    + simpl in H.

      eapply TraceToData_state
        with
        (n := n)
        (trace := ExampleGroverTrace n f)
        (bs := b)
        (d := d).

      exact H.

  - simpl in H.

    contradiction.

Qed.



(*************************************************************)
(* Example Experiment Instances                              *)
(*************************************************************)


(*************************************************************)
(* Single Marked Experiments                                  *)
(*************************************************************)

Definition GroverExperiment_single_n2 :=

GroverConvergenceData
 2
 (oracle_grover_single (all_zeros 2)).



Definition GroverExperiment_single_n3 :=

GroverConvergenceData
 3
 (oracle_grover_single (all_zeros 3)).



Definition GroverExperiment_single_n4 :=

GroverConvergenceData
 4
 (oracle_grover_single (all_zeros 4)).



Definition GroverExperiment_single_n5 :=

GroverConvergenceData
 5
 (oracle_grover_single (all_zeros 5)).



(*************************************************************)
(* Multiple Marked Experiments                               *)
(*************************************************************)


Definition GroverExperiment_multiple_two :=

GroverConvergenceData
 2
 oracle_grover_two.



Definition GroverExperiment_multiple_quarter :=

GroverConvergenceData
 4
 oracle_grover_quarter.



(*************************************************************)
(* Predicate Oracle Experiments                              *)
(*************************************************************)


Definition GroverExperiment_predicate_parity :=

GroverConvergenceData
 4
 (oracle_grover_predicate even_parity).



(*************************************************************)
(* Scaling Experiments                                       *)
(*************************************************************)


Definition GroverScalingSingle :=

[

GroverExperiment_single_n2;

GroverExperiment_single_n3;

GroverExperiment_single_n4;

GroverExperiment_single_n5

].



Definition GroverScalingMultiple :=

[

GroverExperiment_multiple_two;

GroverExperiment_multiple_quarter

].



(*************************************************************)
(* Oracle Family Experiment Collection                       *)
(*************************************************************)


Definition GroverOracleFamilyExperiments :=

[

GroverExperiment_single_n3;

GroverExperiment_multiple_two;

GroverExperiment_predicate_parity

].



(*************************************************************)
(* Probability Queries                                       *)
(*************************************************************)


Definition ExampleProbability_n3_it0 :=

ProbabilityAtIteration
    3
    (oracle_grover_single (all_zeros 3))
    0
    (all_zeros 3).



Definition ExampleProbability_n3_it1 :=

ProbabilityAtIteration
    3
    (oracle_grover_single (all_zeros 3))
    1
    (all_zeros 3).