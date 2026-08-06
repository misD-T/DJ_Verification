(**************************************************************)
(* GroverProofs.v                                             *)
(*                                                            *)
(* Verification Proofs for Semantic Grover Search             *)
(*                                                            *)
(* This file proves semantic correctness properties of        *)
(* Grover execution using QDL and Hoare-Heisenberg logic.     *)
(*                                                            *)
(*                                                            *)
(*  Rocq verifies semantic correctness of the Grover program. *)
(* Numerical amplitude amplification and success probabilities*)
(*  are evaluated in the Python experimental framework.       *)
(**************************************************************)

From Coq Require Import List Bool Arith Lia Classical.

Import ListNotations.


Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

Require Import Grover.GroverOracles.
Require Import Grover.GroverOperators.
Require Import Grover.Grover.


(*************************************************************)
(* Grover Postcondition                                      *)
(*************************************************************)

(*
   The semantic layer verifies that the Grover execution
   preserves the oracle instance being executed.

   Amplitude amplification correctness is evaluated in
   the numerical simulator.
*)

Definition GroverOracleTrackingPost
           (f : OracleInstance)
           : Predicate :=

fun ψ =>

qs_oracle ψ = Some f.



(*************************************************************)
(* Hoare-Heisenberg Specification                             *)
(*************************************************************)

Definition GroverHHSpec
           (n : nat)
           (f : OracleInstance)
           : HHSpecification :=

{|

  HHPre :=

      fun ψ =>

      n > 0 /\

      ψ = InitialState n;


  HHProgram :=

      GroverOperator n f;


  HHPost :=

      GroverOracleTrackingPost f

|}.



(*************************************************************)
(* QDL Specification                                         *)
(*************************************************************)

Definition GroverInitial
           (n : nat)
           : Formula :=

Atom

(fun ψ =>

 ψ = InitialState n).



Definition GroverFormula
           (n : nat)
           (f : OracleInstance)
           : Formula :=

Implication

(GroverInitial n)

(Box

   (GroverOperator n f)

   (Atom

      (GroverOracleTrackingPost f)

   )

).



(*************************************************************)
(* Hoare-Heisenberg Verification                             *)
(*************************************************************)

Theorem Grover_HH_verified :

forall n f,

n > 0 ->

HHVerified (GroverHHSpec n f).

Proof.

  intros n f Hn.


  unfold HHVerified.

  unfold HoareTriple.

  unfold GroverHHSpec.


  intros ψ Hpre.


  destruct Hpre as [Hvalid Hinitial].


  subst ψ.


  unfold GroverOracleTrackingPost.


  unfold GroverExecute.


  apply grover_semantics_preservation.

  exact Hn.


Qed.



(*************************************************************)
(* QDL Verification                                          *)
(*************************************************************)

Theorem Grover_QDL_verified :

forall n f,

n > 0 ->

Valid (GroverFormula n f).

Proof.

  intros n f Hn.


  unfold Valid.


  intro ρ.


  unfold GroverFormula.


  simpl.


  unfold GroverInitial.


  intro Hinitial.


  subst ρ.


  unfold GroverOracleTrackingPost.


  unfold GroverExecute.


  apply grover_semantics_preservation.

  exact Hn.


Qed.



(*************************************************************)
(* Semantic Correctness Bridge                               *)
(*************************************************************)

(*
   Connect HH verification with the semantic correctness
   statement used by the Grover development.
*)

Theorem Grover_verified_implies_correct :

forall n f,

n > 0 ->

HHVerified (GroverHHSpec n f)

->

GroverCorrect n f.

Proof.

  intros n f Hn Hverified.


  unfold GroverCorrect.


  unfold HHVerified in Hverified.

  unfold HoareTriple in Hverified.

  unfold GroverHHSpec in Hverified.

  unfold GroverOracleTrackingPost in Hverified.


  specialize
  (Hverified (InitialState n)).


  apply Hverified.


  split.

  - exact Hn.

  - reflexivity.


Qed.



(*************************************************************)
(* Oracle Family Independence                               *)
(*************************************************************)

(*
   These proofs are independent of the oracle family.

   Therefore the same verification theorem applies to:

       - single marked state
       - multiple marked states
       - predicate based search

   as long as they are represented as OracleInstance.
*)


Lemma Grover_supports_all_oracle_instances :

forall n f,

n > 0 ->

HHVerified (GroverHHSpec n f).

Proof.

  intros n f Hn.

  apply Grover_HH_verified.

  exact Hn.

Qed.