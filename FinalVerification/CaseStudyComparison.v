(*************************************************************)
(* CaseStudyComparison.v                                     *)
(*                                                           *)
(* Combined Case Study Comparison                            *)
(*                                                           *)
(* Demonstrates that multiple quantum algorithms can be       *)
(* verified using the same HH and QDL framework.              *)
(*************************************************************)

From Coq Require Import List Bool Arith Lia Classical String.

Import ListNotations.


Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

Require Import DJ.DeutschJozsa.DJ.
Require Import DJ.DeutschJozsa.DJProofs.
Require Import DJ.Oracles.Oracles.

Require Import Grover.GroverProofs.
Require Import Grover.GroverOracles.

Require Import Final.Framework.
Require Import Final.AlgorithmVerification.
Require Import Final.LogicComparison.


(*************************************************************)
(* Case Studies                                              *)
(*************************************************************)

Require Import DJ.Tests.DJCaseStudy.

Require Import Grover.GroverCaseStudy.


(*************************************************************)
(* Case Study Verification                                   *)
(*************************************************************)

Theorem DeutschJozsaCase_verified :

VerificationProperty DeutschJozsaCase.

Proof.

  unfold DeutschJozsaCase.

  simpl.

  intros n Hn.

  apply parity_verified.

  exact Hn.

Qed.

Theorem GroverCase_verified :

VerificationProperty GroverSearchCase.

Proof.

  unfold GroverSearchCase.

  simpl.

  intros n Hn.

  apply Grover_HH_verified.

  exact Hn.

Qed.

(*************************************************************)
(* Framework Reusability Result                              *)
(*************************************************************)

(*
   Both algorithms are accepted by the same verification
   interface.

   The proof does not depend on algorithm-specific reasoning.
*)

Theorem DJ_and_Grover_verified_by_same_framework :

VerificationProperty DeutschJozsaCase

/\

VerificationProperty GroverSearchCase.

Proof.

  split.

  - apply DeutschJozsaCase_verified.

  - apply GroverCase_verified.

Qed.