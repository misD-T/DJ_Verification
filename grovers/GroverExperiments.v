(*************************************************************)
(* GroverExperiments.v                                       *)
(*                                                           *)
(* Experiments for Semantic Grover Search                    *)
(*************************************************************)

From Coq Require Import List Bool Arith Reals.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOperators.
Require Import Grover.GroverTrace.


(*************************************************************)
(* Experiments                                               *)
(*************************************************************)

(*************************************************************)
(* Building Grover Trace                                     *)
(*************************************************************)

Definition ExampleGroverTrace
           (n : nat)
           (f : OracleInstance)
           : list GroverTraceEntry :=

GroverTrace

   (GroverIterations n)

   (GroverIteration f)

   (InitialState n).

(*************************************************************)
(* Query Probability                                         *)
(*************************************************************)

Definition ProbabilityAtIteration
           (n : nat)
           (f : OracleInstance)
           (i : nat)
           (bs : BitString)
           : R :=

match StateAtIteration
        i
        (ExampleGroverTrace n f)
with

| None => 0%R

| Some ρ =>

    match qs_amplitudes ρ with

    | None => 0%R

    | Some amps =>
        ProbabilityOf amps bs

    end

end.

(*************************************************************)
(* Defining Marked State                                     *)
(*************************************************************)

Definition IsMarked
           (f : OracleInstance)
           (bs : BitString)
           : Prop :=

oracle_function f bs = true.