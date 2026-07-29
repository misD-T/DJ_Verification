(*************************************************************)
(* Deutsch-Jozsa Promise Specification                       *)
(*************************************************************)

From Coq Require Import Bool List Classical.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.
Require Import DJ.Verification.Balanced.

(*************************************************************)
(* Promise Satisfaction                                      *)
(*************************************************************)

Definition PromiseHolds
           (n : nat)
           (f : OracleInstance)
           : Prop :=

DJPromise n f.


Definition PromiseFails
           (n : nat)
           (f : OracleInstance)
           : Prop :=

Invalid n f.


(*************************************************************)
(* Expected Measurement Outcomes                             *)
(*************************************************************)

Definition OutputZero
           (n : nat)
           (b : BitString)
           : Prop :=

b = all_zeros n.


Definition OutputNonZero
           (n : nat)
           (b : BitString)
           : Prop :=

b <> all_zeros n.


(*************************************************************)
(* Deutsch-Jozsa Specification                               *)
(*************************************************************)

Definition DJSpecification
           (n : nat)
           (f : OracleInstance)
           (result : BitString)
           : Prop :=

(Constant n f -> OutputZero n result)
/\
(Balanced n f -> OutputNonZero n result).


(*************************************************************)
(* Correctness Predicate                                     *)
(*************************************************************)

Definition DJCorrect
           (n : nat)
           (f : OracleInstance)
           (result : BitString)
           : Prop :=

PromiseHolds n f
/\
DJSpecification n f result.

(*************************************************************)
(* Promise Violation Behaviour                               *)
(*************************************************************)

Definition UndefinedBehaviour
           (n : nat)
           (f : OracleInstance)
           : Prop :=

PromiseFails n f.

(*************************************************************)
(* Generic Lemmas                                            *)
(*************************************************************)

Lemma promise_partition :

forall (n : nat) (f : OracleInstance),

PromiseHolds n f
\/
PromiseFails n f.

Proof.

intros n f.

unfold PromiseHolds.
unfold PromiseFails.

destruct (classic (DJPromise n f)).

- left.
  assumption.

- right.
  assumption.

Qed.

Lemma constant_correctness :

forall n f result,

PromiseHolds n f ->

Constant n f ->

OutputZero n result ->

(Constant n f -> OutputZero n result).

Proof.

  intros n f result Hpromise Hconst Hzero.

  intro H.

  exact Hzero.

Qed.

Lemma balanced_correctness :

forall n f result,

PromiseHolds n f ->

Balanced n f ->

OutputNonZero n result ->

(Balanced n f -> OutputNonZero n result).

Proof.

  intros n f result Hpromise Hbal Hnonzero.

  intro H.

  exact Hnonzero.

Qed.



Lemma invalid_is_undefined :

forall n f,

PromiseFails n f ->

UndefinedBehaviour n f.

Proof.

intros n f H.

exact H.

Qed.



Lemma promise_cases :

forall n f,

DJPromise n f

<->

Constant n f

\/

Balanced n f.

Proof.

firstorder.

Qed.



Lemma promise_not_invalid :

forall n f,

DJPromise n f

->

~ Invalid n f.

Proof.

firstorder.

Qed.



Lemma invalid_not_constant :

forall n f,

Invalid n f

->

~ Constant n f.

Proof.

firstorder.

Qed.



Lemma promise_implies_defined :

forall n f,

PromiseHolds n f

->

~ PromiseFails n f.

Proof.

firstorder.

Qed.



Lemma DJPromise_implies_PromiseHolds :

forall n f,

DJPromise n f ->

PromiseHolds n f.

Proof.

intros n f H.

unfold DJPromise in H.

unfold PromiseHolds.

exact H.

Qed.