(*************************************************************)
(* GroverCaseStudy.v                                         *)
(*                                                           *)
(* Case Study: Verification of Grover Search using            *)
(* Hoare-Heisenberg Logic and Quantum Dynamic Logic            *)
(*************************************************************)

From Coq Require Import List Bool Arith Lia Classical String.

Import ListNotations.
Open Scope string_scope.

Require Import DJ.Oracles.Oracles.
Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

Require Import Grover.Grover.
Require Import Grover.GroverOracles.
Require Import Grover.GroverOperators.
Require Import Grover.GroverProofs.

Require Import Final.Framework.

(*************************************************************)
(* Grover Case                                               *)
(*************************************************************)

Definition GroverSearchCase
           : VerifiedAlgorithmCase :=

{|

 AlgorithmName :=
   "Grover Search";

 VerificationProperty :=

   forall n (f : OracleInstance),

   n > 0 ->

   HHVerified
      (GroverHHSpec n f)

|}.

(*************************************************************)
(* HH Verification                                           *)
(*************************************************************)

Theorem Grover_case_HH_verified :

forall n (f : OracleInstance),

n > 0 ->

HHVerified (GroverHHSpec n f).

Proof.

  intros n f Hn.

  apply Grover_HH_verified.

  exact Hn.

Qed.

(*************************************************************)
(* QDL Verification                                          *)
(*************************************************************)

Theorem Grover_case_QDL_verified :

forall n (f : OracleInstance),

n > 0 ->

Valid (GroverFormula n f).

Proof.

  intros n f Hn.

  apply Grover_QDL_verified.

  exact Hn.

Qed.

(*************************************************************)
(* Cross Logic Agreement                                     *)
(*************************************************************)

Theorem Grover_case_HH_and_QDL_agree :

forall n (f : OracleInstance),

n > 0 ->

HHVerified (GroverHHSpec n f)

/\

Valid (GroverFormula n f).

Proof.

  intros n f Hn.

  split.

  -
    apply Grover_HH_verified.
    exact Hn.

  -
    apply Grover_QDL_verified.
    exact Hn.

Qed.

(*************************************************************)
(* Correctness from Verification                             *)
(*************************************************************)

Theorem GroverCase_verified :

VerificationProperty GroverSearchCase.

Proof.

  unfold GroverSearchCase.

  simpl.

  intros n f Hn.

  apply Grover_HH_verified.

  exact Hn.

Qed.