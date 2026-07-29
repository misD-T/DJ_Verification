(*************************************************************)
(* HoaresHeisenberg.v                                        *)
(*                                                           *)
(* Generic Hoare-Heisenberg Logic                            *)
(*                                                           *)
(* Provides a Hoare-style reasoning framework                *)
(* for quantum programs independent of any                  *)
(* particular quantum algorithm.                            *)
(*************************************************************)

From Coq Require Import List Bool.

Import ListNotations.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

(*************************************************************)
(* Quantum Predicates                                        *)
(*************************************************************)

Definition Predicate :=

QuantumState -> Prop.

(*************************************************************)
(* Refinement                                                *)
(*************************************************************)
Definition Refines

(P Q : Predicate)

: Prop :=

forall ρ,

P ρ ->

Q ρ.

(*************************************************************)
(* Hoare Triple                                              *)
(*************************************************************)

Definition HoareTriple
           (P : Predicate)
           (U : QuantumOperator)
           (Q : Predicate)
           : Prop :=

forall ρ,

P ρ

->

Q (U ρ).

(*************************************************************)
(* Notation                                                  *)
(*************************************************************)

Notation "{{ P }} U {{ Q }}" :=

(HoareTriple P U Q)

(at level 90).

(*************************************************************)
(* Weakest Precondition                                      *)
(*************************************************************)
Definition WeakestPrecondition
          (U : QuantumOperator)
          (Q : Predicate)
          : Predicate :=

fun ρ =>

Q (U ρ).

(*************************************************************)
(* Hoare Specification                                       *)
(*************************************************************)

Record HHSpecification :=

{

HHPre : Predicate;

HHProgram : QuantumOperator;

HHPost : Predicate

}.

(*************************************************************)
(* Verified Specification                                    *)
(*************************************************************)

Definition HHVerified
           (spec : HHSpecification)
           : Prop :=

HoareTriple
    (HHPre spec)
    (HHProgram spec)
    (HHPost spec).

(*************************************************************)
(* Identity Triple - Lemmas                                  *)
(*************************************************************)

Lemma hoare_identity :
  forall (P : Predicate),
    HoareTriple P Identity P.

Proof.

  intros P.

  unfold HoareTriple.

  intros ρ HP.

  unfold Identity.

  exact HP.

Qed.

(*************************************************************)
(* Reflexive Implication - Lemmas                            *)
(*************************************************************)
Lemma assertion_refl :
  forall (P : Predicate) (ρ : QuantumState),
    P ρ ->
    P ρ.
Proof.
  firstorder.
Qed.

(*************************************************************)
(* Lemma                                                     *)
(*************************************************************)
Lemma verified_unfold :
  forall (spec : HHSpecification),
    HHVerified spec <->
    HoareTriple
      (HHPre spec)
      (HHProgram spec)
      (HHPost spec).
Proof.
  firstorder.
Qed.

Lemma weakest_precondition_correct :
  forall (U : QuantumOperator)
         (Q : Predicate),
    {{ WeakestPrecondition U Q }}
    U
    {{ Q }}.
Proof.
  unfold HoareTriple.
  unfold WeakestPrecondition.
  intros.
  assumption.
Qed.

(*************************************************************)
(* Sequential Composition                                    *)
(*************************************************************)
Definition Compose
           (U V : QuantumOperator)
           : QuantumOperator :=

fun ρ =>

V (U ρ).

Lemma hoare_composition :
  forall (P Q R : Predicate)
         (U V : QuantumOperator),

    HoareTriple P U Q ->

    HoareTriple Q V R ->

    HoareTriple P (Compose U V) R.
Proof.

  unfold HoareTriple.
  unfold Compose.

  intros P Q R U V HU HV ρ HP.

  apply HV.
  apply HU.
  exact HP.

Qed.

Lemma compose_assoc :

forall A B C,

Compose A (Compose B C)

=

Compose (Compose A B) C.

Proof.

reflexivity.

Qed.

(*Lemma hoare_consequence :

forall (P P' Q Q' : Predicate)
       (U : QuantumOperator),

Refines P P' ->

HoareTriple P' U Q' ->

Refines Q' Q ->

HoareTriple P U Q.*)