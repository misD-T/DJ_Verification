(*************************************************************)
(* DJCaseStudy.v                                             *)
(*                                                           *)
(* Deutsch–Jozsa Case Study                                  *)
(*                                                           *)
(* Demonstrates verification of a quantum algorithm using     *)
(* both Hoare–Heisenberg Logic and Quantum Dynamic Logic.     *)
(*************************************************************)

From Coq Require Import Bool List Arith Lia Classical String.

Import ListNotations.
Open Scope string_scope.

Require Import DJ.DeutschJozsa.DJ.
Require Import DJ.DeutschJozsa.DJProofs.
Require Import DJ.Verification.Balanced.
Require Import DJ.Verification.OracleProofs.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

Require Import DJ.Oracles.Oracles.
Require Import DJ.Oracles.Promise.

Require Import Final.Framework.

(*************************************************************)
(* Deutsch-Jozsa Case                                        *)
(*************************************************************)

Definition DeutschJozsaCase
           : VerifiedAlgorithmCase :=

{|

 AlgorithmName :=
   "Deutsch-Jozsa";

 VerificationProperty :=

   forall n,

   n > 0 ->

   DJVerified n oracle_parity

|}.

(*************************************************************)
(* Case Study 1: Constant Oracle                              *)
(*************************************************************)

(* 
   A constant oracle should cause Deutsch–Jozsa to accept.

   We verify this through the framework:
   
       Constant Oracle
             |
             v
       DJ Correctness
             |
             v
       DJ Verified
*)


Theorem DJ_case_constant_zero_verified :

forall n,

DJVerified n constant_zero.

Proof.

  intro n.

  apply constant_zero_verified.

Qed.



(*************************************************************)
(* Case Study 2: Balanced Oracle                              *)
(*************************************************************)

(*
   The parity oracle is a canonical balanced oracle.

   Deutsch–Jozsa should reject because the measurement
   output is non-zero.
*)


Theorem DJ_case_parity_verified :

forall n,

n > 0 ->

DJVerified n oracle_parity.

Proof.

  intros n Hn.

  apply parity_verified.

  exact Hn.

Qed.

(*************************************************************)
(* First Bit Oracle                                          *)
(*************************************************************)

Theorem DJ_case_first_bit_verified :

forall n,

n > 0 ->

DJVerified n oracle_first_bit.

Proof.

  intros n Hn.

  apply first_bit_verified.

  exact Hn.

Qed.



(*************************************************************)
(* Full Parity Oracle                                        *)
(*************************************************************)

Theorem DJ_case_full_parity_verified :

forall n,

n > 0 ->

DJVerified n oracle_full_parity.

Proof.

  intros n Hn.

  apply full_parity_verified.

  exact Hn.

Qed.



(*************************************************************)
(* Affine Oracle                                              *)
(*************************************************************)

Theorem DJ_case_affine_verified :

forall n,

n > 0 ->

DJVerified n oracle_affine.

Proof.

  intros n Hn.

  apply affine_verified.

  exact Hn.

Qed.

(*************************************************************)
(* Hoare–Heisenberg Verification                              *)
(*************************************************************)

(*
   The HH framework expresses the correctness property as:

        {Precondition}
             DJ
        {Postcondition}

   For the balanced case:
   
        InitialState
             |
             v
        DJ oracle_parity
             |
             v
        NonZero output
*)


Theorem DJ_case_HH_balanced :

forall n,

n > 0 ->

HHVerified (DJBalancedHHSpec n).

Proof.

  intros n Hn.

  apply DJ_balanced_HH_verified.

Qed.



(*************************************************************)
(* Quantum Dynamic Logic Verification                         *)
(*************************************************************)

(*
   QDL expresses the same property using a modal formula:

       Initial -> [DJ] NonZero
*)


Theorem DJ_case_QDL_balanced :

forall n,

n > 0 ->

Valid (DJBalancedFormula n).

Proof.

  intros n Hn.

  apply DJ_balanced_QDL_verified.

Qed.



(*************************************************************)
(* Cross Logic Comparison                                    *)
(*************************************************************)

(*
   Both verification systems establish the same algorithmic
   correctness property.

   HH verification:
       HH specification
              |
              v
       Verified algorithm

   QDL verification:
       QDL formula
              |
              v
       Verified algorithm
*)


Theorem DJ_case_HH_and_QDL_agree :

forall n,

n > 0 ->

HHVerified (DJBalancedHHSpec n)

/\

Valid (DJBalancedFormula n).

Proof.

  intros n Hn.

  split.

  -

    apply DJ_balanced_HH_verified.

  -

    apply DJ_balanced_QDL_verified.

Qed.

(*************************************************************)
(* Case Study Verification Suite                              *)
(*************************************************************)

(*
   The Deutsch–Jozsa framework successfully verifies multiple
   oracle instances through the same semantic and logical
   infrastructure.

   This demonstrates reusability of the verification framework.
*)


Theorem DJ_case_study_suite :

forall n,

n > 0 ->

DJVerified n oracle_parity
/\

DJVerified n oracle_first_bit
/\

DJVerified n oracle_full_parity
/\

DJVerified n oracle_affine.

Proof.

  intros n Hn.

  split.

  -

    apply parity_verified.

    exact Hn.


  -

    split.

    +

      apply first_bit_verified.

      exact Hn.


    +

      split.

      *

        apply full_parity_verified.

        exact Hn.


      *

        apply affine_verified.

        exact Hn.

Qed.


(*************************************************************)
(* Case Study Summary                                        *)
(*************************************************************)

(*
   This case study demonstrates:

   1. A quantum algorithm can be represented using the
      semantic execution framework.

   2. Hoare–Heisenberg Logic can verify correctness.

   3. Quantum Dynamic Logic can verify the same property.

   4. The verification result is independent of the
      underlying reasoning approach.
*)