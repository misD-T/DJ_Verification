From Coq Require Import Bool List.
Import ListNotations.

Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.BooleanFunctions.


(*************************************************************)
(* Oracle Kinds                                              *)
(*************************************************************)

Inductive OracleKind :=

| OKConstantZero
| OKConstantOne

| OKFirstBit
| OKParity
| OKFullParity
| OKXorTwoBits

| OKAffine

| OKAndXor

| OKExampleBalanced

| OKSingleMarked
| OKMajority
| OKAlternating

| OKGroverSingle
| OKMultipleMarked
| OKGroverPredicate.

(*************************************************************)
(* Oracle Instance                                           *)
(*************************************************************)

Record OracleInstance :=
{
  oracle_kind : OracleKind;

  oracle_function : Oracle
}.

(*************************************************************)
(* Constant Oracles                                          *)
(*************************************************************)

Definition constant_zero_fun : Oracle :=
  fun _ => false.

Definition constant_zero : OracleInstance :=
{|
  oracle_kind := OKConstantZero;
  oracle_function := constant_zero_fun
|}.

Definition constant_one_fun : Oracle :=
  fun _ => true.

Definition constant_one : OracleInstance :=
{|
  oracle_kind := OKConstantOne;
  oracle_function := constant_one_fun
|}.

(*************************************************************)
(* Linear Oracles                                            *)
(*************************************************************)

Definition first_bit_fun : Oracle :=
  first_bit.

Definition oracle_first_bit : OracleInstance :=
{|
  oracle_kind := OKFirstBit;
  oracle_function := first_bit_fun
|}.

Definition parity_fun : Oracle :=
  parity.

Definition oracle_parity : OracleInstance :=
{|
  oracle_kind := OKParity;
  oracle_function := parity_fun
|}.

Definition full_parity_fun : Oracle :=
  parity.

Definition oracle_full_parity : OracleInstance :=
{|
  oracle_kind := OKFullParity;
  oracle_function := full_parity_fun
|}.

Definition xor_two_bits_fun : Oracle :=
  xor_two_bits.


Definition oracle_xor_two_bits : OracleInstance :=
{|
  oracle_kind := OKXorTwoBits;
  oracle_function := xor_two_bits_fun
|}.

(*************************************************************)
(* Affine Oracle                                             *)
(*************************************************************)
Definition affine_fun : Oracle :=
  affine.


Definition oracle_affine : OracleInstance :=
{|
  oracle_kind := OKAffine;
  oracle_function := affine_fun
|}.

(*************************************************************)
(* Simple Nonlinear Oracle                                   *)
(*************************************************************)

Definition and_xor_fun : Oracle :=
fun x =>
  andb
    (first_bit x)
    (parity x).


Definition oracle_and_xor : OracleInstance :=
{|
  oracle_kind := OKAndXor;
  oracle_function := and_xor_fun
|}.

(*************************************************************)
(* Example Balanced Oracle                                  *)
(*************************************************************)

Definition example_balanced_fun : Oracle :=
fun x =>
  negb (parity x).


Definition oracle_example_balanced : OracleInstance :=
{|
  oracle_kind := OKExampleBalanced;
  oracle_function := example_balanced_fun
|}.

(*************************************************************)
(* Invalid Oracles                                           *)
(*************************************************************)
Definition single_marked_fun : Oracle :=
fun x =>
  bitstring_eqb
    x
    (all_ones (bit_length x)).


Definition oracle_single_marked : OracleInstance :=
{|
  oracle_kind := OKSingleMarked;
  oracle_function := single_marked_fun
|}.

Definition majority_fun : Oracle :=
  majority.


Definition oracle_majority : OracleInstance :=
{|
  oracle_kind := OKMajority;
  oracle_function := majority_fun
|}.

Definition alternating_fun : Oracle :=
  alternating.


Definition oracle_alternating : OracleInstance :=
{|
  oracle_kind := OKAlternating;
  oracle_function := alternating_fun
|}.

(* Later proved:

Theorem first_bit_balanced :
    Balanced oracle_first_bit.

*)

(*************************************************************)
(* Oracle eqb                                                *)
(*************************************************************)
Definition oracle_eqb
           (f g : OracleInstance)
           : bool :=

match oracle_kind f, oracle_kind g with

| OKConstantZero, OKConstantZero => true

| OKConstantOne, OKConstantOne => true

| OKFirstBit, OKFirstBit => true

| OKParity, OKParity => true

| OKFullParity, OKFullParity => true

| OKXorTwoBits, OKXorTwoBits => true

| OKAffine, OKAffine => true

| OKAndXor, OKAndXor => true

| OKExampleBalanced, OKExampleBalanced => true

| OKSingleMarked, OKSingleMarked => true

| OKMajority, OKMajority => true

| OKAlternating, OKAlternating => true

| OKGroverSingle, OKGroverSingle => true

| OKMultipleMarked, OKMultipleMarked => true

| OKGroverPredicate, OKGroverPredicate => true

| _, _ => false

end.

(*************************************************************)
(* Lemma                                                     *)
(*************************************************************)
Lemma constant_zero_evaluates :

forall x,

oracle_function constant_zero x = false.

Proof.

  intro x.

  reflexivity.

Qed.

Lemma constant_one_evaluates :

forall x,

oracle_function constant_one x = true.

Proof.

  intro x.

  reflexivity.

Qed.

Lemma parity_oracle_correct :

forall x,

oracle_function oracle_parity x = parity x.

Proof.

  intros x.

  reflexivity.

Qed.

Lemma first_bit_oracle_correct :

forall x,

oracle_function oracle_first_bit x = first_bit x.

Proof.

  intros x.

  reflexivity.

Qed.

Lemma affine_oracle_correct :

forall x,

oracle_function oracle_affine x = affine x.

Proof.

  intros x.

  reflexivity.

Qed.

Lemma oracle_eqb_parity_constant_zero :

oracle_eqb oracle_parity constant_zero = false.

Proof.

  reflexivity.

Qed.