
(*************************************************************)
(* GroverTrace.v                                             *)
(*                                                           *)
(* Given a Grover operator and an initial state, record      *)
(* the state after each iteration.                           *)
(*************************************************************)
From Coq Require Import List Arith Reals.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOperators.

(*************************************************************)
(* Grover Trace                                              *)
(*************************************************************)

Record GroverTraceEntry :=

{

TraceIteration : nat;

TraceState : QuantumState

}.

(*************************************************************)
(* Grover Trace Generation                                   *)
(*************************************************************)

Fixpoint GroverTrace
         (k : nat)
         (U : QuantumOperator)
         (ρ : QuantumState)
         : list GroverTraceEntry :=

match k with

| 0 =>
    [{|
       TraceIteration := 0;
       TraceState := ρ
     |}]

| S k' =>

    {|
      TraceIteration := S k';
      TraceState := U ρ
    |}

    ::
    
    GroverTrace k' U (U ρ)

end.

(*************************************************************)
(* Grover Trace Probability                                  *)
(*************************************************************)

Definition TraceProbability
           (entry : GroverTraceEntry)
           (bs : BitString)
           : R :=

match qs_amplitudes (TraceState entry) with

| None => 0%R

| Some amps =>
    ProbabilityOf amps bs

end.

(*************************************************************)
(* Trace Utilities                                           *)
(*************************************************************)

Definition TraceStates
           (trace : list GroverTraceEntry)
           : list QuantumState :=

map TraceState trace.

Fixpoint FinalTraceState
         (trace : list GroverTraceEntry)
         : option QuantumState :=

match trace with

| [] => None

| [x] => Some (TraceState x)

| _ :: xs => FinalTraceState xs

end.

Fixpoint StateAtIteration
         (i : nat)
         (trace : list GroverTraceEntry)
         : option QuantumState :=

match trace with

| [] => None

| x :: xs =>

    match Nat.eqb i (TraceIteration x) with

    | true =>
        Some (TraceState x)

    | false =>
        StateAtIteration i xs

    end

end.

