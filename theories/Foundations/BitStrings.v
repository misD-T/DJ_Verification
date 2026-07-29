(*************************************************************)
(* BitStrings.v                                              *)
(*                                                           *)
(* Basic definitions and utilities for finite bitstrings.    *)
(* These definitions are shared by all verified algorithms   *)
(* in the framework.                                         *)
(*************************************************************)

From Coq Require Import Bool List Lia Arith.
Import ListNotations.

Definition Bit := bool.

Definition BitString := list Bit.

Definition bit_length
           (b : BitString)
           : nat :=
  length b.

(*************************************************************)
(* Basic Bit Operations                                      *)
(*************************************************************)
Definition xor (a b : Bit) : Bit :=
    xorb a b.

Definition bit_not (b : Bit) : Bit :=
    negb b.

(*************************************************************)
(* Counting                                                  *)
(*************************************************************)
Fixpoint count_ones (b : BitString) : nat :=

match b with

| [] => 0

| true :: xs =>
    S (count_ones xs)

| false :: xs =>
    count_ones xs

end.


Fixpoint count_zeros (b : BitString) : nat :=
  match b with
  | [] => 0
  | true :: xs => count_zeros xs
  | false :: xs => S (count_zeros xs)
  end.


(*************************************************************)
(* Queries                                                   *)
(*************************************************************)
Fixpoint parity (b : BitString) : Bit :=

match b with

| [] => false

| x :: xs =>
    xor x (parity xs)

end.

Definition first_bit (b : BitString) : Bit :=

match b with

| [] => false

| x :: _ => x

end.

Fixpoint last_bit
         (b : BitString)
         : Bit :=

match b with

| [] =>
    false

| [x] =>
    x

| _::xs =>
    last_bit xs

end.


(*************************************************************)
(* Construction                                              *)
(*************************************************************)
  Fixpoint all_zeros
          (n : nat)
          : BitString :=

  match n with

  | O => []

  | S k =>
      false :: all_zeros k

  end.

Fixpoint all_ones
         (n : nat)
         : BitString :=

match n with

| O => []

| S k =>
    true :: all_ones k

end.

Definition append_bit
           (b : BitString)
           (x : Bit)
           : BitString :=

b ++ [x]. (* For constructing bitstrings*)

(*************************************************************)
(* Bit Append                                                *)
(*************************************************************)

Definition AppendBit
        (b : bool)
        (states : list BitString)
        : list BitString :=

map (fun s => b :: s) states.


(*************************************************************)
(* Equality                                                  *)
(*************************************************************)
Fixpoint bitstring_eqb
         (x y : BitString)
         : bool :=

match x, y with

| [], [] =>
    true

| a::xs, b::ys =>

    Bool.eqb a b
    &&
    bitstring_eqb xs ys

| _, _ =>

    false

end.

(*************************************************************)
(* Distances                                                 *)
(*************************************************************)
Definition hamming_weight := count_ones.

Fixpoint hamming_distance
         (a b : BitString)
         : nat :=

match a,b with

| [],[] => 0

| x::xs,y::ys =>

    (if Bool.eqb x y then 0 else 1)
    +

    hamming_distance xs ys

| _,_ => 0

end.

(*************************************************************)
(* Utilities                                                 *)
(*************************************************************)
Definition flip_first
           (b : BitString)
           : BitString :=

match b with

| [] => []

| x::xs =>

    negb x :: xs

end.

(*************************************************************)
(* Theorems                                                  *)
(*************************************************************)

Lemma count_zeros_count_ones :
  forall b,
    count_zeros b + count_ones b = length b.
Proof.
  induction b as [|x xs IH].
  - reflexivity.
  - destruct x; simpl.
    + rewrite <- plus_n_Sm.
      rewrite IH.
      reflexivity.
    + rewrite IH.
      reflexivity.
Qed.
(*Lemma count_zeros_count_ones :

forall b,

count_zeros b + count_ones b = length b.

Proof.

induction b.

- simpl.
  reflexivity.

- destruct a.

  - simpl.
    rewrite IHb.
    lia.

  - simpl.
    rewrite IHb.
    lia.

Qed*)


Lemma hamming_distance_refl :
  forall b,
    hamming_distance b b = 0.
Proof.
  induction b as [|a b IH].
  - reflexivity.
  - destruct a.
    + simpl.
      rewrite IH.
      reflexivity.
    + simpl.
      rewrite IH.
      reflexivity.
Qed.



(*************************************************************)
(* List Length Lemmas                                        *)
(*************************************************************)

Lemma length_all_zeros :

forall n,

length (all_zeros n) = n.

Proof.

  induction n.

  - reflexivity.

  - simpl.
    rewrite IHn.
    reflexivity.

Qed.


Lemma length_repeat :

forall (b : bool) n,

length (repeat b n) = n.

Proof.

  induction n.

  - reflexivity.

  - simpl.
    rewrite IHn.
    reflexivity.

Qed.

Lemma repeat_true_not_all_zeros :

forall n,

n > 0 ->

repeat true n <> all_zeros n.

Proof.

  intros n Hn.

  destruct n.

  - simpl in Hn.
    lia.

  - simpl.

    intro H.

    inversion H.

Qed.