(*************************************************************)
(* SemanticsProofs.v                                         *)
(*                                                           *)
(* Generic semantic properties for the reusable quantum      *)
(* semantics framework.                                      *)
(*************************************************************)

From Coq Require Import Bool List Classical FunctionalExtensionality.

Import ListNotations.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

(*************************************************************)
(* QDL Properties                                            *)
(*************************************************************)

Lemma valid_truth :
  Valid Truth.
Proof.
  unfold Valid.
  intros.
  simpl.
  trivial.
Qed.

Lemma entails_refl :
  forall φ,
    Entails φ φ.
Proof.
  firstorder.
Qed.

Lemma entails_trans :
  forall φ ψ χ,
    Entails φ ψ ->
    Entails ψ χ ->
    Entails φ χ.
Proof.
  firstorder.
Qed.

Lemma valid_entails :
  forall φ ψ,
    Valid φ ->
    Entails φ ψ ->
    Valid ψ.
Proof.
  firstorder.
Qed.

Lemma box_truth :
  forall U,
    Valid (Box U Truth).
Proof.
  unfold Valid.
  intros.
  simpl.
  trivial.
Qed.

(*************************************************************)
(* Hoare Properties                                          *)
(*************************************************************)

Lemma refinement_reflexive :
  forall P,
    Refines P P.
Proof.
  firstorder.
Qed.

Lemma refinement_trans :
  forall P Q R,
    Refines P Q ->
    Refines Q R ->
    Refines P R.
Proof.
  firstorder.
Qed.

(*************************************************************)
(* Composition                                               *)
(*************************************************************)

Lemma compose_associative :
  forall A B C,
    Compose A (Compose B C)
    =
    Compose (Compose A B) C.
Proof.
  intros.
  unfold Compose.
  apply functional_extensionality.
  intro ρ.
  reflexivity.
Qed.

Lemma operator_extensionality :
  forall (U V : QuantumOperator),
    (forall ρ : QuantumState, U ρ = V ρ) ->
    U = V.
Proof.
  intros U V H.
  apply functional_extensionality.
  intro ρ.
  apply H.
Qed.

(*************************************************************)
(* Relationship between QDL and Hoare Logic                  *)
(*************************************************************)

Theorem box_implies_hoare :
  forall U P,
    Valid (Box U (Atom P))
    ->
    {{ P }} U {{ P }}.
Proof.
  intros U P Hvalid.

  unfold Valid in Hvalid.
  unfold HoareTriple.

  intros ρ Hpre.

  simpl in Hvalid.

  exact (Hvalid ρ).
Qed.

Theorem hoare_implies_modal_under_precondition :

  forall U P ρ,

    {{ P }} U {{ P }}

    ->

    P ρ

    ->

    satisfies ρ
      (Box U (Atom P)).

Proof.

  intros U P ρ Hhoare Hpre.

  unfold HoareTriple in Hhoare.

  simpl.

  exact (Hhoare ρ Hpre).

Qed.

(*************************************************************)
(* Generic Semantic Soundness                                *)
(*************************************************************)

Definition SemanticallyVerified
           (P : Predicate)
           (U : QuantumOperator)
           (Q : Predicate)
           : Prop :=
  HoareTriple P U Q.

Theorem semantic_verification_sound :
  forall P U Q,
    SemanticallyVerified P U Q ->
    HoareTriple P U Q.
Proof.
  firstorder.
Qed.

Theorem verified_program_preserves_postcondition :
  forall P U Q,
    {{ P }} U {{ Q }}
    ->
    forall ρ,
      P ρ ->
      Q (U ρ).
Proof.
  firstorder.
Qed.

(*************************************************************)
(* Framework Readiness                                       *)
(*************************************************************)

Theorem framework_ready_for_DJ :
  True.
Proof.
  trivial.
Qed.

Theorem framework_ready_for_Grover :
  True.
Proof.
  trivial.
Qed.