From Coq Require Import Bool List.
From Coq Require Import Strings.String.

Import ListNotations.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import forms.Oracles.Oracles.

Require Import Grover.Grover.
Require Import Grover.GroverOperators.
Require Import Grover.GroverTrace.

(*************************************************************)
(* Faulty Grover Operators                                   *)
(*************************************************************)

(* A faulty oracle which deliberately fails to record the
   oracle in the resulting semantic state. *)

Definition BadOracleOperator
           (f : OracleInstance)
           : QuantumOperator :=
fun ρ =>
{|
  qs_bits := qs_bits ρ;
  qs_amplitudes := qs_amplitudes ρ;
  qs_target := qs_target ρ;
  qs_qubits := qs_qubits ρ;
  qs_oracle := None;
  qs_measurement := qs_measurement ρ;
  qs_history := "BadOracle" :: qs_history ρ;
  qs_status := qs_status ρ;
  qs_symbolic_output := qs_symbolic_output ρ
|}.


(* A faulty Grover iteration which uses the bad oracle. *)

Definition BadGroverIteration
           (f : OracleInstance)
           : QuantumOperator :=
Compose
  Diffusion 
  (BadOracleOperator f).


(* Faulty Grover execution. *)

Definition BadGroverOperator
           (n : nat)
           (f : OracleInstance)
           : QuantumOperator :=
Compose
  (RepeatOperator
     (GroverIterations n)
     (BadGroverIteration f))
  Hadamard.


Definition BadGroverExecute
           (n : nat)
           (f : OracleInstance) : QuantumState :=
BadGroverOperator n f (InitialState n).


(*************************************************************)
(* Fault property                                            *)
(*************************************************************)

Definition BadGroverOracleProperty
           (n : nat)
           (f : OracleInstance) : Prop :=
qs_oracle (BadGroverExecute n f) = Some f.


(*************************************************************)
(* Formal failure                                            *)
(*************************************************************)

Theorem BadGrover_fails_oracle_preservation :
  forall n f,
    BadGroverOracleProperty n f -> False.
Proof.
  intros n f H.

  unfold BadGroverOracleProperty in H.
  unfold BadGroverExecute in H.
  unfold BadGroverOperator in H.

  remember (GroverIterations n) as k.

  induction k as [| k IH].
  - simpl in H.
    discriminate.

  - simpl in H.
    unfold BadGroverIteration in H.
    unfold BadOracleOperator in H.
    simpl in H.
    discriminate.
Qed.