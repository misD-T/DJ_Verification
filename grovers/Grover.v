(*************************************************************)
(* Grover.v                                                  *)
(*                                                           *)
(* Semantic Grover Search Algorithm                          *)
(*************************************************************)

From Coq Require Import List Bool Lia.

Import ListNotations.

Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Grover.GroverOracles.
Require Import Grover.GroverOperators.


(*************************************************************)
(* Grover Execution                                          *)
(*************************************************************)
Definition GroverExecute
           (n : nat)
           (f : OracleInstance)
           : QuantumState :=

GroverOperator n f (InitialState n).

(*************************************************************)
(* Grover Result                                             *)
(*************************************************************)
Definition GroverResult
           (n : nat)
           (oracle : OracleInstance)
           : BitString :=

qs_bits (GroverExecute n oracle).

(*************************************************************)
(* Correctness Predicate                                     *)
(*************************************************************)
Definition GroverCorrect
           (n : nat)
           (f : OracleInstance)
           : Prop :=

qs_oracle (GroverExecute n f)
=
Some f.

(*************************************************************)
(* Theorems                                                  *)
(*************************************************************)
(*************************************************************)
(* Grover Semantic Preservation                              *)
(*************************************************************)

Theorem grover_semantics_preservation :

forall n f,

n > 0 ->
GroverCorrect n f.

Proof.

  intros n f Hn.

  unfold GroverCorrect.
  unfold GroverExecute.
  unfold GroverOperator.
  unfold Compose.

  simpl.

  unfold GroverIterations.

  destruct n.

  - lia.

  - apply RepeatOperator_records_oracle.

Qed.

(*************************************************************)
(* Oracle Generality                                         *)
(*************************************************************)

Theorem grover_oracle_family_independence :

forall n f,

n > 0 ->

GroverCorrect n f.

Proof.

  intros n f Hn.

  apply grover_semantics_preservation.

  exact Hn.

Qed.
