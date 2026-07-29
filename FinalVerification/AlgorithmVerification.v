(*************************************************************)
(* AlgorithmVerification.v                                   *)
(*                                                           *)
(* Generic Algorithm Verification Interface                  *)
(*                                                           *)
(* Provides a semantic layer connecting different quantum     *)
(* verification logics (HH and QDL) to algorithm correctness.*)
(*************************************************************)


From Coq Require Import List Bool Arith Lia Classical.

Import ListNotations.


Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

Require Import Final.Framework.



(*************************************************************)
(* Generic Algorithm Specification                            *)
(*************************************************************)

Record AlgorithmSpecification :=

{

AlgorithmInput : Predicate;

AlgorithmProgram : QuantumOperator;

AlgorithmOutput : Predicate

}.



(*************************************************************)
(* Semantic Algorithm Correctness                            *)
(*************************************************************)

(*
   This is the common correctness property.

   It is independent of any verification logic.

   HH and QDL both aim to prove this property.
*)

Definition AlgorithmCorrect
           (input : Predicate)
           (program : QuantumOperator)
           (output : Predicate)
           : Prop :=

forall ρ,

input ρ

->

output (program ρ).



(*************************************************************)
(* Convert Generic Algorithm to HH Specification              *)
(*************************************************************)

Definition AlgorithmToHH
           (spec : AlgorithmSpecification)
           : HHSpecification :=

{|

HHPre := AlgorithmInput spec;

HHProgram := AlgorithmProgram spec;

HHPost := AlgorithmOutput spec

|}.



(*************************************************************)
(* Hoare-Heisenberg Verification Bridge                       *)
(*************************************************************)


Theorem HH_implies_algorithm_correct :

forall spec,

HHVerified (AlgorithmToHH spec)

->

AlgorithmCorrect
   (AlgorithmInput spec)
   (AlgorithmProgram spec)
   (AlgorithmOutput spec).

Proof.

  intros spec H.

  unfold AlgorithmCorrect.

  unfold HHVerified in H.

  unfold AlgorithmToHH in H.

  unfold HoareTriple in H.

  exact H.

Qed.



(*************************************************************)
(* Formula Semantics Bridge                                  *)
(*************************************************************)

(*
   Converts QDL formulas into predicates so they can be
   compared against the same semantic correctness layer.
*)

Definition FormulaPredicate
           (φ : Formula)
           : Predicate :=

fun ρ =>

satisfies ρ φ.



(*************************************************************)
(* Convert Generic Algorithm to QDL Specification              *)
(*************************************************************)

Definition AlgorithmToQDL
           (spec : AlgorithmSpecification)
           (pre post : Formula)
           : QDLSpecification :=

{|

Precondition := pre;

Program := AlgorithmProgram spec;

Postcondition := post

|}.



(*************************************************************)
(* QDL Verification Bridge                                   *)
(*************************************************************)


Theorem QDL_implies_algorithm_correct :

forall spec pre post,

QDLVerified (AlgorithmToQDL spec pre post)

->

AlgorithmCorrect
   (FormulaPredicate pre)
   (AlgorithmProgram spec)
   (FormulaPredicate post).

Proof.

  intros spec pre post H.

  unfold AlgorithmCorrect.

  unfold QDLVerified in H.

  unfold AlgorithmToQDL in H.

  exact H.

Qed.



(*************************************************************)
(* Algorithm Composition                                     *)
(*************************************************************)


Theorem algorithms_compose :

forall P Q R U V,

AlgorithmCorrect P U Q

->

AlgorithmCorrect Q V R

->

AlgorithmCorrect P (Compose U V) R.

Proof.

  intros P Q R U V HU HV.

  unfold AlgorithmCorrect in *.

  intros ρ HP.

  apply HV.

  apply HU.

  exact HP.

Qed.