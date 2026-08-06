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
(*                                                           *)
(* Records:                                                  *)
(*                                                           *)
(* 0 -> initial state                                        *)
(* 1 -> after first Grover iteration                         *)
(* 2 -> after second Grover iteration                        *)
(* ...                                                       *)
(*                                                           *)
(*************************************************************)


Fixpoint GroverTrace
         (k : nat)
         (U : QuantumOperator)
         (ρ : QuantumState)
         : list GroverTraceEntry :=

match k with


| 0 =>

    [
      {|
        TraceIteration := 0;

        TraceState := ρ
      |}
    ]


| S k' =>

    {|
      TraceIteration := 0;

      TraceState := ρ
    |}

    ::

    map
      (fun entry =>

        {|
          TraceIteration :=
              S (TraceIteration entry);

          TraceState :=
              TraceState entry
        |}

      )

      (GroverTrace k' U (U ρ))


end.



(*************************************************************)
(* Grover Trace Probability                                  *)
(*************************************************************)


Definition TraceProbability
           (entry : GroverTraceEntry)
           (bs : BitString)
           : R :=

match qs_amplitudes (TraceState entry) with

| None =>

    0%R


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

| [] =>

    None


| [x] =>

    Some (TraceState x)


| _ :: xs =>

    FinalTraceState xs


end.



Fixpoint StateAtIteration
         (i : nat)
         (trace : list GroverTraceEntry)
         : option QuantumState :=

match trace with


| [] =>

    None


| x :: xs =>


    match Nat.eqb i (TraceIteration x) with


    | true =>

        Some (TraceState x)


    | false =>

        StateAtIteration i xs


    end


end.



(*************************************************************)
(* Trace Length                                              *)
(*************************************************************)


Lemma GroverTrace_length :

forall k U ρ,

length (GroverTrace k U ρ)

=

S k.


Proof.

  induction k.

  - intros.

    simpl.

    reflexivity.


  - intros U ρ.

    simpl.

    rewrite map_length.

    rewrite (IHk U (U ρ)).

    reflexivity.

Qed.



(*************************************************************)
(* Trace Lookup Correctness                                  *)
(*************************************************************)


Lemma StateAtIteration_exists :


forall i trace ρ,


StateAtIteration i trace = Some ρ


->


In ρ (TraceStates trace).


Proof.


intros i trace.


induction trace.


- simpl.

  intros ρ H.

  discriminate.



- intros ρ H.


  simpl in H.


  destruct
    (Nat.eqb i (TraceIteration a))
    eqn:Hi.



  + inversion H.

    subst.


    simpl.

    left.

    reflexivity.



  + right.

    apply IHtrace.

    exact H.


Qed.

Lemma StateAtIteration_in_trace :

forall i trace ρ,

StateAtIteration i trace = Some ρ

->

exists entry,

In entry trace
/\ 
TraceState entry = ρ
/\ 
TraceIteration entry = i.

Proof.

Admitted.
