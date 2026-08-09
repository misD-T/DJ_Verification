From Coq Require Import List Bool Arith Lia.

Import ListNotations.


Require Import forms.Oracles.BooleanFunctions.
Require Import forms.Foundations.BitStrings.
Require Import forms.Foundations.Enumeration.

(*************************************************************)
(* Oracle Evaluation                                         *)
(*************************************************************)
Definition evaluate_oracle
           (f : Oracle)
           (x : BitString)
           : Bit :=
  f x.

Definition oracle_outputs
           (f : Oracle)
           (n : nat)
           : list Bit :=

enumerate_outputs f n.

(*************************************************************)
(* Counting                                                  *)
(*************************************************************)
Fixpoint count_true
         (l : list bool)
         : nat :=
  match l with
  | [] => 0
  | true :: xs =>
      S (count_true xs)
  | false :: xs =>
      count_true xs
  end.

  Fixpoint count_false
         (l : list bool)
         : nat :=
  match l with
  | [] => 0
  | true :: xs =>
      count_false xs
  | false :: xs =>
      S (count_false xs)
  end.


Definition count_true_outputs
           (f : Oracle)
           (n : nat)
           : nat :=
  count_true (oracle_outputs f n).
  
Definition count_false_outputs
           (f : Oracle)
           (n : nat)
           : nat :=

number_of_inputs n

-

count_true_outputs f n.

Definition output_counts
           (f : Oracle)
           (n : nat)
           : nat * nat :=
(
count_true_outputs f n,
count_false_outputs f n
).

(*************************************************************)
(* Total number of outputs                                   *)
(*************************************************************)
Definition total_outputs
           (n : nat)
           : nat :=
  Nat.pow 2 n.


Definition output_ratio
           (f : Oracle)
           (n : nat)
           : nat * nat :=
(
count_true_outputs f n,
total_outputs n
).

(*************************************************************)
(* Distance from Balance                                     *)
(*************************************************************)

Definition nat_abs_diff (a b : nat) : nat :=
  if Nat.leb a b then
    b - a
  else
    a - b.


Definition balance_distance
           (f : Oracle)
           (n : nat)
           : nat :=

let expected := number_of_inputs n / 2 in

nat_abs_diff
  (count_true_outputs f n)
  expected.

Definition all_true
           (l : list bool)
           : bool :=
  forallb (fun b => b) l.


Definition all_false
           (l : list bool)
           : bool :=
  forallb negb l.


(*************************************************************)
(* Utility Lemmas                                            *)
(*************************************************************)
Lemma count_true_false_total :

forall l : list bool,

count_true l + count_false l = length l.

Proof.

  induction l as [|b xs IH].

  - simpl.
    reflexivity.

  - destruct b.

    + simpl.
      rewrite IH.
      reflexivity.

    + simpl.
      rewrite <- plus_n_Sm.
      rewrite IH.
      reflexivity.

Qed.

Lemma count_false_from_total :

  forall l : list bool,

  length l - count_true l = count_false l.

Proof.

    intros l.

    rewrite <- count_true_false_total.

    lia.

Qed.

Lemma count_false_length_relation :

forall l,

count_false l = length l - count_true l.

Proof.

  intros l.

  symmetry.

  apply count_false_from_total.

Qed.

Lemma count_true_nonnegative :

forall l,

count_true l >= 0.
Proof.
lia.
Qed.

Lemma true_false_partition :

forall l,

count_true l +
count_false l
=
length l.

Proof.

  induction l.

  -
    reflexivity.

  -
    destruct a.

    +
      change (S (count_true l + count_false l) = S (length l)).

      rewrite IHl.
      reflexivity.

    +
      change (count_true l + S (count_false l) = S (length l)).

      rewrite <- plus_n_Sm.

      rewrite IHl.

      reflexivity.

Qed.

Lemma oracle_outputs_length :

forall n (f : Oracle),

length (oracle_outputs f n)
=
Nat.pow 2 n.

Proof.

  intros n f.

  unfold oracle_outputs.

  unfold enumerate_outputs.

  rewrite (map_length f (enumerate_bitstrings n)).

  apply enumerate_bitstrings_length.

Qed.

Lemma oracle_output_partition :

forall f n,

count_true_outputs f n
+
count_false_outputs f n
=

number_of_inputs n.

Proof.

  intros f n.

  unfold count_true_outputs.
  unfold count_false_outputs.
  unfold number_of_inputs.

  rewrite <- (oracle_outputs_length n f).

  rewrite count_false_from_total.

  apply true_false_partition.

Qed.


Lemma balance_distance_zero :

forall f n,

balance_distance f n = 0
->

count_true_outputs f n = number_of_inputs n / 2.

Proof.

  intros f n H.

  unfold balance_distance in H.

  unfold nat_abs_diff in H.

  destruct (Nat.leb (count_true_outputs f n)
                   (number_of_inputs n / 2)) eqn:Hle.

  -
    apply Nat.leb_le in Hle.

    lia.

  -

    apply Nat.leb_gt in Hle.

    lia.

Qed.