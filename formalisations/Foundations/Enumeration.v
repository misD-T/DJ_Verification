(*************************************************************)
(* Enumeration.v                                             *)
(*                                                           *)
(* Exhaustive enumeration of finite bitstrings.              *)
(* These definitions allow finite verification of Boolean    *)
(* functions and quantum oracle properties.                  *)
(*************************************************************)

From Coq Require Import List Bool Arith Lia.
Import ListNotations.

Require Import forms.Foundations.BitStrings.

(*************************************************************)
(* Helper Functions                                          *)
(*************************************************************)
Definition prepend_bit
    (b : Bit)
    (l : list BitString)
    : list BitString :=

map (fun x => b :: x) l. (* This is a helper function that takes a bit and a list of bitstrings, and returns a new list of bitstrings where the given bit is prepended to each bitstring in the original list.*)

(*************************************************************)
(* Enumeration                                               *)
(*************************************************************)
Fixpoint enumerate_bitstrings
    (n : nat)
    : list BitString :=

match n with

| O =>
    [[]]

| S k =>

    prepend_bit false (enumerate_bitstrings k)

    ++

    prepend_bit true (enumerate_bitstrings k)

end. (* This function generates all possible bitstrings of length n. It does this recursively by generating all bitstrings of length k (where k = n - 1), and then prepending both false and true to each of those bitstrings to create the full set of bitstrings of length n.*)

(*************************************************************)
(* Utilities                                                 *)
(*************************************************************)
Definition number_of_inputs
           (n : nat)
           : nat :=
  Nat.pow 2 n. (*This definition calculates the number of possible input combinations for a given number of bits.*)

Definition valid_input
    (n : nat)
    (x : BitString)
    : Prop :=

In x (enumerate_bitstrings n). (* This definition checks if a given bitstring is a valid input for a given number of bits.*)

Definition enumerate_outputs
           {A}
           (f : BitString -> A)
           (n : nat)
           : list A :=
  map f (enumerate_bitstrings n).

(*************************************************************)
(* Examples                                                  *)
(*************************************************************)
Theorem enumerate_zero :

enumerate_bitstrings 0 = [[]].
Proof.
reflexivity.
Qed. (* This theorem states that there is only one bitstring of length 0, which is the empty list.*)

Theorem enumerate_one :

enumerate_bitstrings 1 =

[[false];
 [true]].
Proof.
reflexivity.
Qed. (* This theorem states that there are two bitstrings of length 1: one containing false and one containing true.*)

Theorem enumerate_two :

enumerate_bitstrings 2 =

[
[false;false];
[false;true];
[true;false];
[true;true]
].
Proof.
reflexivity.
Qed. (* This theorem states that there are four bitstrings of length 2: [false;false], [false;true], [true;false], and [true;true]. *)

(*************************************************************)
(* General Lemmas                                            *)
(*************************************************************)
Lemma enumerate_bitstrings_length :

forall n,

length (enumerate_bitstrings n)
=
Nat.pow 2 n.

Proof.

  induction n as [|n IH].

  -
    simpl.
    reflexivity.

  -
    unfold enumerate_bitstrings at 1.

    rewrite app_length.

    unfold prepend_bit.

    repeat rewrite map_length.

    change (length (enumerate_bitstrings n) +
            length (enumerate_bitstrings n) = 2 ^ S n).

    rewrite !IH.

    simpl.

    lia.

Qed.

Lemma valid_input_complete :

forall n x,

valid_input n x ->

length x = n.

Proof.

  induction n.

  -
    intros x H.

    unfold valid_input in H.

    simpl in H.

    destruct H.

    +
      subst.

      reflexivity.

    +
      contradiction.

  -

    intros x H.

    unfold valid_input in H.

    simpl in H.

    apply in_app_iff in H.

    destruct H as [H | H].

    +
      unfold prepend_bit in H.

      apply in_map_iff in H.

      destruct H as [y [Hy1 Hy2]].

      subst.

      simpl.

      f_equal.

      apply IHn.

      unfold valid_input.

      exact Hy2.

    +

      unfold prepend_bit in H.

      apply in_map_iff in H.

      destruct H as [y [Hy1 Hy2]].

      subst.

      simpl.

      f_equal.

      apply IHn.

      unfold valid_input.

      exact Hy2.

Qed.

Lemma prepend_bit_length :

forall b l,

length (prepend_bit b l)
=
length l.

Proof.

  intros b l.

  unfold prepend_bit.

  apply map_length.

Qed.

Lemma prepend_bit_contains :

forall b l x,

In x l ->

In (b :: x) (prepend_bit b l).

Proof.

  intros b l x H.

  unfold prepend_bit.

  apply in_map.

  exact H.

Qed.

Lemma prepend_bit_nonempty :

forall b l,

l <> [] ->

prepend_bit b l <> [].

Proof.

  intros b l Hl Hempty.

  pose proof (prepend_bit_length b l) as Hlen.

  rewrite Hempty in Hlen.

  simpl in Hlen.

  destruct l.

  -
    contradiction.

  -
    simpl in Hlen.

    discriminate.

Qed.

Lemma enumerate_nonempty :
  forall n,
    enumerate_bitstrings n <> [].

Proof.

  induction n.

  -
    simpl.

    discriminate.

  -

    simpl.

    intro H.

    apply app_eq_nil in H.

    destruct H as [Hfalse Htrue].

    apply prepend_bit_nonempty in Hfalse.

    apply Hfalse.

    exact IHn.

Qed.

