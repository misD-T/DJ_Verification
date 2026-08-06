(*************************************************************)
(* GroverExperiments.v                                       *)
(*                                                           *)
(* Experiments for Semantic Grover Search                    *)
(*************************************************************)

From Coq Require Import List Bool Arith Reals Lia.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOperators.
Require Import Grover.GroverTrace.


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

   (Hadamard (InitialState n)).



(*************************************************************)
(* Probability Extraction                                    *)
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

| None =>
    0%R

| Some ρ =>

    match qs_amplitudes ρ with

    | None =>
        0%R

    | Some amps =>
        ProbabilityOf amps bs

    end

end.



(*************************************************************)
(* Oracle Predicate                                          *)
(*************************************************************)


Definition IsMarked
           (f : OracleInstance)
           (bs : BitString)
           : Prop :=

oracle_function f bs = true.



(*************************************************************)
(* Marked State Extraction                                   *)
(*************************************************************)


Definition MarkedStates
           (f : OracleInstance)
           (states : list BitString)
           : list BitString :=

filter
   (oracle_function f)
   states.



Definition CountMarked
           (f : OracleInstance)
           (states : list BitString)
           : nat :=

length
(
 MarkedStates f states
).



(*************************************************************)
(* Basic Sanity Properties                                   *)
(*************************************************************)
