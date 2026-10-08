Require Import Grover.Grover.
Require Import Grover.GroverProofs.
Require Import Grover.GroverFaults.
Require Import Grover.GroverOperators.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import forms.Oracles.Oracles.

(*************************************************************)
(* Correct implementation                                    *)
(*************************************************************)

Theorem correct_grover_verifies :
  forall n f,
    n > 0 ->
    qs_oracle (GroverExecute n f) = Some f.
Proof.
  intros n f Hn.
  unfold GroverExecute.
  unfold GroverOperator.
  simpl.
  apply grover_semantics_preservation.
  exact Hn.
Qed.


(*************************************************************)
(* Faulty implementation                                    *)
(*************************************************************)

Theorem faulty_grover_rejected :
  forall n f,
    ~ BadGroverOracleProperty n f.
Proof.
  intros n f H.
  exact (BadGrover_fails_oracle_preservation n f H).
Qed.