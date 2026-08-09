From Coq Require Import Arith Lia List.

Require Import forms.Foundations.BitStrings.
Require Import forms.Foundations.Enumeration.
Require Import forms.Foundations.Counting.
Require Import forms.Oracles.BooleanFunctions.
Require Import forms.Oracles.Oracles.



(*************************************************************)
(* Constant Oracles                                          *)
(*************************************************************)

Definition Constant
           (n : nat)
           (f : OracleInstance)
           : Prop :=

count_true_outputs (oracle_function f) n = 0
\/
count_false_outputs (oracle_function f) n = 0.



(*************************************************************)
(* Balanced Oracles                                          *)
(*************************************************************)

Definition Balanced
           (n : nat)
           (f : OracleInstance)
           : Prop :=

count_true_outputs (oracle_function f) n
=
count_false_outputs (oracle_function f) n.



(*************************************************************)
(* Almost Balanced                                           *)
(*************************************************************)

Definition AlmostBalanced
           (n : nat)
           (k : nat)
           (f : OracleInstance)
           : Prop :=

balance_distance (oracle_function f) n = k.



(*************************************************************)
(* Oracle Bias                                               *)
(*************************************************************)

Definition OracleBias
           (n : nat)
           (f : OracleInstance)
           : nat * nat :=

output_ratio (oracle_function f) n.



(*************************************************************)
(* Promise Satisfaction                                      *)
(*************************************************************)

Definition DJPromise
           (n : nat)
           (f : OracleInstance)
           : Prop :=

Constant n f
\/
Balanced n f.



(*************************************************************)
(* Invalid Oracle                                            *)
(*************************************************************)

Definition Invalid
           (n : nat)
           (f : OracleInstance)
           : Prop :=

~ DJPromise n f.



(*************************************************************)
(* Helper Properties                                         *)
(*************************************************************)

Definition PerfectlyBalanced
           (n : nat)
           (f : OracleInstance)
           : Prop :=

balance_distance (oracle_function f) n = 0.



Definition NearBalanced
           (n : nat)
           (k : nat)
           (f : OracleInstance)
           : Prop :=

balance_distance (oracle_function f) n <= k.



Definition Biased
           (n : nat)
           (f : OracleInstance)
           : Prop :=

~ Balanced n f.



(*************************************************************)
(* Robustness Definitions                                    *)
(*************************************************************)

Definition PromiseDistance
           (n : nat)
           (f : OracleInstance)
           : nat :=

balance_distance (oracle_function f) n.



Definition PromiseRobust
           (n : nat)
           (k : nat)
           (f : OracleInstance)
           : Prop :=

PromiseDistance n f <= k.



Definition PromiseViolated
           (n : nat)
           (f : OracleInstance)
           : Prop :=

PromiseDistance n f > 0.



(*************************************************************)
(* Basic Relationships                                       *)
(*************************************************************)

Lemma balanced_implies_promise :

forall n f,

Balanced n f ->

DJPromise n f.

Proof.

  intros.

  right.

  assumption.

Qed.



Lemma constant_implies_promise :

forall n f,

Constant n f ->

DJPromise n f.

Proof.

  intros.

  left.

  assumption.

Qed.

(*************************************************************)
(* Counting True                                             *)
(*************************************************************)
Lemma count_true_le_length :

forall l,

count_true l <= length l.

Proof.

  induction l as [|a l IH].

  -
    simpl.
    lia.

  -
    destruct a.

    +
      simpl.
      lia.

    +
      simpl.
      lia.

Qed.

(*************************************************************)
(* Counting Lemmas                                           *)
(*************************************************************)
Lemma count_true_outputs_le_inputs :

forall n (f : Oracle),

count_true_outputs f n <= number_of_inputs n.

Proof.

  intros n f.

  unfold count_true_outputs.
  unfold number_of_inputs.

  assert (Hlength :
    length (oracle_outputs f n) = Nat.pow 2 n).

  {
    apply oracle_outputs_length.
  }

  rewrite <- Hlength.

  apply count_true_le_length.

Qed.

Lemma count_outputs_total :

forall n f,

count_true_outputs f n +
count_false_outputs f n
=
number_of_inputs n.

Proof.

  intros n f.

  unfold count_false_outputs.

  assert (H :
    count_true_outputs f n <= number_of_inputs n).

  {
    apply count_true_outputs_le_inputs.
  }

  lia.

Qed.

Lemma number_of_inputs_positive :

forall n,

number_of_inputs n > 0.

Proof.

  intro n.

  unfold number_of_inputs.

  induction n.

  - simpl.
    lia.

  - simpl.
    lia.

Qed.

Lemma Balanced_not_zero_counts :

forall n f,

n > 0 ->
Balanced n f ->
count_true_outputs (oracle_function f) n <> 0.

Proof.

  intros n f Hn Hbalanced Hzero.

  assert (Hfalse :
    count_false_outputs (oracle_function f) n = 0).

  {
  unfold Balanced in Hbalanced.

  rewrite Hzero in Hbalanced.

  symmetry.
  apply Hbalanced.
    }

  assert (Htotal :
    count_true_outputs (oracle_function f) n +
    count_false_outputs (oracle_function f) n
    =
    number_of_inputs n).

  {
    apply count_outputs_total.
  }

  rewrite Hzero in Htotal.
  rewrite Hfalse in Htotal.

  simpl in Htotal.

  assert (Hpos :
    number_of_inputs n > 0).

  {
    apply number_of_inputs_positive.
  }

  lia.

Qed.

Lemma Balanced_not_zero_false_counts :

forall n f,

n > 0 ->
Balanced n f ->
count_false_outputs (oracle_function f) n <> 0.

Proof.

  intros n f Hn Hbalanced Hzero.

  assert (Htrue :
    count_true_outputs (oracle_function f) n = 0).

  {
    unfold Balanced in Hbalanced.

    rewrite Hzero in Hbalanced.

    exact Hbalanced.
  }

  assert (Htotal :
    count_true_outputs (oracle_function f) n +
    count_false_outputs (oracle_function f) n
    =
    number_of_inputs n).

  {
    apply count_outputs_total.
  }

  rewrite Htrue in Htotal.
  rewrite Hzero in Htotal.

  simpl in Htotal.

  assert (Hpos :
    number_of_inputs n > 0).

  {
    apply number_of_inputs_positive.
  }

  lia.

Qed.

Lemma perfectly_balanced_is_balanced :

forall n (f : OracleInstance),

PerfectlyBalanced n f ->

Balanced n f.

Proof.

Admitted.

Lemma robust_zero :

forall n f,

n > 0 ->

PromiseRobust n 0 f

<->

Balanced n f.

Proof.
Admitted.

Lemma constant_not_balanced :

forall n (f : OracleInstance),

n > 0 ->

Constant n f ->

~ Balanced n f.

Proof.

  intros n f Hn Hconstant Hbalanced.

  unfold Constant in Hconstant.

  destruct Hconstant as [Hzero | Hzero].

  -

    apply (Balanced_not_zero_counts n f).

    + exact Hn.

    + exact Hbalanced.

    + exact Hzero.


  -

    apply (Balanced_not_zero_false_counts n f).

    + exact Hn.

    + exact Hbalanced.

    + exact Hzero.

Qed.

Lemma balanced_not_constant :

forall n (f : OracleInstance),

n > 0 ->

Balanced n f ->

~ Constant n f.

Proof.

  intros n f Hn Hbal Hconst.

  apply (constant_not_balanced n f Hn).

  exact Hconst.

  exact Hbal.

Qed.

(*************************************************************)
(* Invalid Oracle Properties                                 *)
(*************************************************************)

Lemma invalid_not_promise :

forall n (f : OracleInstance),

Invalid n f ->

~ DJPromise n f.

Proof.

  intros n f H.

  unfold Invalid in H.

  exact H.

Qed.



Lemma promise_implies_not_invalid :

forall n f,

DJPromise n f ->

~ Invalid n f.

Proof.

  firstorder.

Qed.



Lemma invalid_equiv_not_promise :

forall n f,

Invalid n f

<->

~ DJPromise n f.

Proof.

  firstorder.

Qed.

(* We're building the lemmas up later with a real proof but for now in development, we will leave as is*)