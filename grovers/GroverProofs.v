(*************************************************************)
(* GroverProofs.v                                            *)
(*                                                           *)
(* Verification Proofs for Semantic Grover Search            *)
(*************************************************************)

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
(* Output Predicates                                         *)
(*************************************************************)

Definition GroverOraclePost
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

      n > 0 /\ ψ = InitialState n;


  HHProgram :=

      GroverOperator n f;


  HHPost :=

      GroverOraclePost f

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

      (GroverOraclePost f)

   )

).


(*************************************************************)
(* Verification Statements                                   *)
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

  destruct Hpre as [Hvalid Hinit].

  subst ψ.

  unfold GroverOraclePost.

  unfold GroverExecute.

  apply grover_semantics.

  exact Hn.

Qed.



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

  intro Hinit.

  subst ρ.

  unfold GroverOraclePost.

  unfold GroverExecute.

  apply grover_semantics.

  exact Hn.

Qed.

(*************************************************************)
(* Semantic Correctness Bridge                               *)
(*************************************************************)

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
  unfold GroverOraclePost in Hverified.

  specialize (Hverified (InitialState n)).

  apply Hverified.

  split.

  - exact Hn.

  - reflexivity.

Qed.