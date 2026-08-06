(*************************************************************)
(* QDL.v                                                     *)
(*                                                           *)
(* Generic Quantum Dynamic Logic                             *)
(*                                                           *)
(* Defines the logical language used to reason about         *)
(* quantum programs independently of any particular          *)
(* algorithm.                                                *)
(*************************************************************)

From Coq Require Import List Bool.
Import ListNotations.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

(*************************************************************)
(* Quantum Proposition                                       *)
(*************************************************************)
Definition QPredicate :=
  QuantumState -> Prop.


(*************************************************************)
(* QDL Formulations                                          *)
(*************************************************************)
Inductive Formula : Type :=

| Truth

| Falsehood

| Atom
    (P : QPredicate)

| Conjunction
    (φ ψ : Formula)

| Disjunction
    (φ ψ : Formula)

| Implication
    (φ ψ : Formula)

| Negation
    (φ : Formula)

| Box
    (U : QuantumOperator)
    (φ : Formula)

| Diamond
    (U : QuantumOperator)
    (φ : Formula).

(* For deterministic quantum operators,Box and Diamond coincide.
This will later be generalised to probabilistic execution. *)

(*************************************************************)
(* Semantics                                                 *)
(*************************************************************)
Fixpoint satisfies
         (ρ : QuantumState)
         (φ : Formula)
         : Prop :=

match φ with

| Truth =>
    True

| Falsehood =>
    False

| Atom P =>
    P ρ

| Conjunction φ ψ =>
    satisfies ρ φ
    /\
    satisfies ρ ψ

| Disjunction φ ψ =>
    satisfies ρ φ
    \/
    satisfies ρ ψ

| Implication φ ψ =>
    satisfies ρ φ ->
    satisfies ρ ψ

| Negation φ =>
    ~ satisfies ρ φ

| Box U φ =>
    satisfies (U ρ) φ

| Diamond U φ =>
    satisfies (U ρ) φ

end.

(*************************************************************)
(* Logic Validity                                            *)
(*************************************************************)
Definition Valid
           (φ : Formula)
           : Prop :=

forall ρ,

satisfies ρ φ.

(*************************************************************)
(* Logic Implication                                         *)
(*************************************************************)
Definition Entails
           (φ ψ : Formula)
           : Prop :=

forall ρ,

satisfies ρ φ ->
satisfies ρ ψ.

(*************************************************************)
(* Logic Preservation                                        *)
(*************************************************************)
Definition Preserves
           (U : QuantumOperator)
           (P Q : Formula)
           : Prop :=

forall ρ,

satisfies ρ P

->

satisfies
   (U ρ)
   Q.

(*************************************************************)
(* Generic Specification                                     *)
(*************************************************************)
Record QDLSpecification :=

{

Precondition : Formula;

Program : QuantumOperator;

Postcondition : Formula

}.

(*************************************************************)
(* QDL Verification                                          *)
(*************************************************************)
Definition QDLVerified
           (spec : QDLSpecification)
           : Prop :=

forall ρ,

satisfies ρ (Precondition spec)

->

satisfies
   ((Program spec) ρ)
   (Postcondition spec).

(*************************************************************)
(* Useful Lemmas                                             *)
(*************************************************************)
Lemma Valid_implies_entails :

forall φ ψ,

Valid (Implication φ ψ)

->

Entails φ ψ.

Proof.

firstorder.

Qed.

Lemma entails_refl :

forall φ,

Entails φ φ.

Proof.

firstorder.

Qed.

(*************************************************************)
(* Useful Notations                                          *)
(*************************************************************)
Declare Scope qdl_scope.

Notation "¬ φ" :=
  (Negation φ)
  (at level 75, right associativity) : qdl_scope.

Notation "φ ∧ ψ" :=
  (Conjunction φ ψ)
  (at level 80, right associativity) : qdl_scope.

Notation "φ ∨ ψ" :=
  (Disjunction φ ψ)
  (at level 85, right associativity) : qdl_scope.

Notation "φ ⇒ ψ" :=
  (Implication φ ψ)
  (at level 90, right associativity) : qdl_scope.

Notation "[ U ] φ" :=
  (Box U φ)
  (at level 75, right associativity) : qdl_scope.

Notation "< U > φ" :=
  (Diamond U φ)
  (at level 75, right associativity) : qdl_scope.

Open Scope qdl_scope.



