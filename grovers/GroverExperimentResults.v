(*************************************************************)
(* GroverExperimentResults.v                                *)
(*                                                           *)
(* Converts Grover traces into measurable experiment data.   *)
(*************************************************************)

From Coq Require Import List Arith Reals.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverTrace.
Require Import Grover.GroverExperiments.

(*************************************************************)
(* Data Points                                               *)
(*************************************************************)
Record GroverDataPoint :=

{

DataN : nat;

DataIteration : nat;

DataState : BitString;

DataProbability : R

}.

(*************************************************************)
(* Extracting Probability                                    *)
(*************************************************************)
Definition ProbabilityFromEntry
           (entry : GroverTraceEntry)
           (bs : BitString)
           : R :=

TraceProbability entry bs.

(*************************************************************)
(* Convert Trace to Data                                     *)
(*************************************************************)
Fixpoint TraceToData
         (n : nat)
         (trace : list GroverTraceEntry)
         (bs : BitString)
         : list GroverDataPoint :=

match trace with

| [] => []

| entry :: rest =>

    {|
      DataN := n;

      DataIteration :=
        TraceIteration entry;

      DataState := bs;

      DataProbability :=
        ProbabilityFromEntry entry bs

    |}

    ::

    TraceToData n rest bs

end.

(*************************************************************)
(* Automatic Marked State Extraction                         *)
(*************************************************************)

Fixpoint FindMarkedState
         (f : OracleInstance)
         (states : list BitString)
         : option BitString :=

match states with

| [] => None

| x :: xs =>

    if oracle_function f x
    then Some x
    else FindMarkedState f xs

end.

(*************************************************************)
(* Complete Grover Result                                    *)
(*************************************************************)

Definition RunGroverExperiment
           (n : nat)
           (f : OracleInstance)
           : list GroverDataPoint :=

match FindMarkedState f (BasisStates n) with

| None => []

| Some marked =>

    TraceToData

       n

       (ExampleGroverTrace n f)

       marked

end.

(*************************************************************)
(* Sanity Lemmas                                             *)
(*************************************************************)
Lemma TraceToData_length :

forall n trace bs,

length (TraceToData n trace bs)
=
length trace.

Proof.

  intros n trace.

  induction trace.

  - simpl.
    reflexivity.

  - intros bs.

    simpl.

    rewrite IHtrace.

    reflexivity.

Qed.

Lemma TraceToData_nil :

forall n bs,

TraceToData n [] bs = [].

Proof.

  intros.

  reflexivity.

Qed.

Lemma FindMarkedState_correct :

forall f states bs,

FindMarkedState f states = Some bs
->
oracle_function f bs = true.

Proof.

  intros f states.

  induction states as [|a states IH].

  - intros bs H.
    simpl in H.
    discriminate.

  - intros bs H.

    simpl in H.

    destruct (oracle_function f a) eqn:Horacle.

    + inversion H.
      subst bs.
      exact Horacle.

    + apply IH.
      exact H.

Qed.