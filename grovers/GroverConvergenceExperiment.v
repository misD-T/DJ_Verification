(*************************************************************)
(* GroverConvergenceExperiment.v                             *)
(*                                                           *)
(* Experimental evaluation of Grover probability evolution   *)
(*************************************************************)

From Coq Require Import List Arith Reals.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOracles.
Require Import Grover.GroverTrace.
Require Import Grover.GroverExperiments.
Require Import Grover.GroverExperimentResults.


(*************************************************************)
(* Standard Grover Experiment Oracle                         *)
(*************************************************************)

Definition GroverMarkedOracle
           (n : nat)
           : OracleInstance :=

{|

 oracle_kind := OKGrover;

 oracle_function :=

   fun bs =>

     if bitstring_eqb bs (all_zeros n)

     then true

     else false

|}.


(*************************************************************)
(* Oracle Sanity                                             *)
(*************************************************************)
Lemma GroverMarkedOracle_exists :

forall n : nat,

exists bs,

oracle_function
  (GroverMarkedOracle n)
  bs = true.

Proof.

  intros n.

  exists (all_zeros n).

  unfold GroverMarkedOracle.

  change ((if bitstring_eqb (all_zeros n) (all_zeros n) then true else false) = true).

  rewrite (bitstring_eqb_all_zeros_refl n).

  reflexivity.

Qed.


Lemma GroverMarkedOracle_marks_zero :

forall n : nat,

oracle_function
  (GroverMarkedOracle n)
  (all_zeros n)
=
true.

Proof.

  intros n.

  unfold GroverMarkedOracle.

  change ((if bitstring_eqb (all_zeros n) (all_zeros n) then true else false) = true).

  rewrite (bitstring_eqb_all_zeros_refl n).

  reflexivity.

Qed.

(*************************************************************)
(* All Zeroes in Basis                                       *)
(*************************************************************)
Lemma AppendBit_preserves_membership :

forall b states bs,

In bs states
->

In (b :: bs) (AppendBit b states).

Proof.

  intros b states bs H.

  unfold AppendBit.

  induction states.

  - simpl in H.

    contradiction.

  - simpl.

    destruct H as [H | H].

    + subst.

      left.

      reflexivity.

    + right.

      apply IHstates.

      exact H.

Qed.

Lemma all_zeros_in_basis :

forall n : nat,

In (all_zeros n) (BasisStates n).

Proof.

  induction n.

  - simpl.

    left.

    reflexivity.

  - simpl.

    apply in_or_app.

    left.

    apply AppendBit_preserves_membership.

    exact IHn.

Qed.

(*************************************************************)
(* Marked State Extraction                                   *)
(*************************************************************)
Lemma BasisStates_head_zero :

forall n,

BasisStates n = all_zeros n :: tl (BasisStates n).

Proof.

  induction n.

  - simpl.

    reflexivity.

  - simpl.

    rewrite IHn.

    reflexivity.

Qed.

Lemma GroverMarkedOracle_found :

forall n : nat,

FindMarkedState
  (GroverMarkedOracle n)
  (BasisStates n)
=
Some (all_zeros n).

Proof.

  intros n.

  rewrite (BasisStates_head_zero n).

  simpl.

  unfold GroverMarkedOracle.

  rewrite (bitstring_eqb_all_zeros_refl n).

  reflexivity.

Qed.

(*************************************************************)
(* Experiment 1: Probability Trajectory                      *)
(*************************************************************)

Definition GroverConvergenceData
           (n : nat)
           : list GroverDataPoint :=

RunGroverExperiment

n

(GroverMarkedOracle n).


(*************************************************************)
(* Trace Extraction Sanity                                   *)
(*************************************************************)

Lemma GroverConvergenceData_length :

forall n : nat,

length (GroverConvergenceData n)
=
length (ExampleGroverTrace n (GroverMarkedOracle n)).

Proof.

  intros n.

  unfold GroverConvergenceData.
  unfold RunGroverExperiment.

  rewrite (GroverMarkedOracle_found n).

  simpl.

  apply TraceToData_length.

Qed.

(*************************************************************)
(* Convergence State                                         *)
(*************************************************************)
Lemma GroverConvergenceData_state :

forall n d,

In d (GroverConvergenceData n)

->

DataState d = all_zeros n.

Proof.

  intros n d H.

  unfold GroverConvergenceData in H.
  unfold RunGroverExperiment in H.

  rewrite (GroverMarkedOracle_found n) in H.

  simpl in H.

  (* unfold TraceToData membership *)
  induction (ExampleGroverTrace n (GroverMarkedOracle n)).

  - simpl in H.
    contradiction.

  - simpl in H.

    destruct H as [H | H].

    + inversion H.
      reflexivity.

    + apply IHl.
      exact H.

Qed.

(*************************************************************)
(* Experiment Instances                                      *)
(*************************************************************)

(*************************************************************)
(* Experiment 1 – Convergence                                *)
(*************************************************************)
Definition GroverExperiment_n2 :=
  GroverConvergenceData 2.

Definition GroverExperiment_n3 :=
  GroverConvergenceData 3.

Definition GroverExperiment_n4 :=
  GroverConvergenceData 4.

Definition GroverExperiment_n5 :=
  GroverConvergenceData 5.

(*************************************************************)
(* Experiment 2 – Scaling                                    *)
(*************************************************************)

Definition GroverScalingExperiments :=
[
  GroverConvergenceData 2;
  GroverConvergenceData 3;
  GroverConvergenceData 4;
  GroverConvergenceData 5;
  GroverConvergenceData 6
].

(*************************************************************)
(* Experiment 3 – Probability queries                        *)
(*************************************************************)

Definition ExampleProbability_n3_it0 :=
  ProbabilityAtIteration
    3
    oracle_grover
    0
    (all_zeros 3).

Definition ExampleProbability_n3_it1 :=
  ProbabilityAtIteration
    3
    oracle_grover
    1
    (all_zeros 3).


