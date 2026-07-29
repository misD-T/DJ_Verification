(*************************************************************)
(* Grover.v                                                  *)
(*                                                           *)
(* Semantic Grover Search Algorithm                          *)
(*************************************************************)

From Coq Require Import List Bool Lia.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.

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

Theorem grover_semantics :

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