(*************************************************************)
(* Boolean Functions Used by Quantum Oracles                 *)
(*************************************************************)

From Coq Require Import List Bool Arith.
Import ListNotations.

Require Import DJ.Foundations.BitStrings.

(*************************************************************)
(* Types                                                     *)
(*************************************************************)

Definition Oracle := BitString -> Bit.

Definition evaluate
           (f : Oracle)
           (x : BitString)
           : Bit :=
  f x.


(*************************************************************)
(* Balanced Oracle Functions                                 *)
(*************************************************************)
Definition xor_two_bits
           (x : BitString)
           : bool :=

  match x with
  | b1::b2::_ =>
      xor b1 b2
  | _ => false
  end.

Definition affine
           (x : BitString)
           : bool :=

  xor (parity x) true.



Definition alternating
           (x : BitString)
           : bool :=

  negb (first_bit x).

(*************************************************************)
(* Invalid Oracle Functions                                  *)
(*************************************************************)
Definition majority
           (x : BitString)
           : bool :=

Nat.leb

(bit_length x / 2 + 1)

(count_ones x).

(*************************************************************)
(* Utility Lemmas                                            *)
(*************************************************************)
Lemma evaluate_oracle :

forall f x,

evaluate f x = f x.

Proof.

reflexivity.

Qed.

Lemma affine_is_negated_parity :

forall x,

affine x = negb (parity x).

Proof.

intros.

unfold affine.

destruct (parity x).

all: reflexivity.

Qed.

Lemma bitstring_eqb_all_zeros_refl :

forall n,

bitstring_eqb (all_zeros n) (all_zeros n)
=
true.

Proof.

  induction n.

  - simpl.
    reflexivity.

  - simpl.
    rewrite IHn.
    reflexivity.

Qed.

Lemma bitstring_eqb_refl :

forall bs : BitString,

bitstring_eqb bs bs = true.

Proof.

  induction bs.

  - simpl.
    reflexivity.

  - simpl.
    rewrite IHbs.

    destruct a.

    + simpl.
      reflexivity.

    + simpl.
      reflexivity.

Qed.