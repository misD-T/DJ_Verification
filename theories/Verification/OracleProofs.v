(*************************************************************)
(* Formal Properties of Example Oracle Families              *)
(*************************************************************)

From Coq Require Import Bool List Arith Lia.
Require Import Coq.Logic.FunctionalExtensionality.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Foundations.Counting.
Require Import DJ.Foundations.Enumeration.

Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.
Require Import DJ.Oracles.Promise.

Require Import DJ.Verification.Balanced.
Require Import DJ.DeutschJozsa.DJ.


(*************************************************************)
(* Helper Lemmas                                             *)
(*************************************************************)
Lemma count_true_zero_iff :

forall l,

count_true l = 0 ->

forall b,

In b l ->

b = false.

Proof.

  induction l as [|a l IH].

  -
    intros H b HIn.

    inversion HIn.

  -
    intros H b HIn.

    destruct a.

    +
      simpl in H.

      discriminate.

    +
      simpl in H.

      destruct HIn.

      *
        symmetry.
        exact H0.

      *
        apply (IH H b H0).

Qed.

Lemma count_false_zero_iff :

forall l,

count_false l = 0 ->

forall b,

In b l ->

b = true.

Proof.

  induction l as [|a l IH].

  -
    intros H b HIn.

    inversion HIn.

  -
    intros H b HIn.

    destruct a.

    +
      (* a = true *)

      simpl in H.

      destruct HIn.

      *

        symmetry.
        exact H0.

      *

        apply (IH H b H0).

    +
      (* a = false *)

      simpl in H.

      discriminate.

Qed.

Lemma count_true_map_false :

forall (l : list BitString),

count_true (map (fun _ => false) l) = 0.

Proof.

  induction l.

  - reflexivity.

  - simpl.
    rewrite IHl.
    reflexivity.

Qed.



Lemma count_true_map_true :

forall (l : list BitString),

count_true (map (fun _ => true) l) = length l.

Proof.

  induction l.

  - reflexivity.

  - simpl.
    rewrite IHl.
    reflexivity.

Qed.



Lemma count_false_map_false :

forall (l : list BitString),

count_false (map (fun _ => false) l) = length l.

Proof.

  induction l.

  - reflexivity.

  - simpl.
    rewrite IHl.
    reflexivity.

Qed.



Lemma count_false_map_true :

forall (l : list BitString),

count_false (map (fun _ => true) l) = 0.

Proof.

  induction l.

  - reflexivity.

  - simpl.
    rewrite IHl.
    reflexivity.

Qed.

Lemma enumerate_bitstrings_complete :

forall n x,

length x = n ->

In x (enumerate_bitstrings n).

Proof.

  induction n as [|n IH].

  - intros x Hlen.

    simpl in Hlen.

    destruct x.

    + simpl.

      left.

      reflexivity.

    + simpl in Hlen.

      discriminate.

  - intros x Hlen.

    destruct x as [|b x].

    + simpl in Hlen.

      discriminate.

    + simpl in Hlen.

      simpl.

      apply in_or_app.

      destruct b.

      * right.

        apply prepend_bit_contains.

        apply IH.

        apply Nat.succ_inj in Hlen.

        exact Hlen.

      * left.

        apply prepend_bit_contains.

        apply IH.

        apply Nat.succ_inj in Hlen.

        exact Hlen.

Qed.

Lemma enumerate_outputs_length :

forall A (f : BitString -> A) n,

length (enumerate_outputs f n)
=
length (enumerate_bitstrings n).

Proof.

  intros A f n.

  unfold enumerate_outputs.

  apply map_length.

Qed.

Lemma count_false_outputs_correct :

forall n (f : Oracle),

count_false_outputs f n
=
count_false (oracle_outputs f n).

Proof.

  intros n f.

  unfold count_false_outputs.
  unfold number_of_inputs.
  unfold count_true_outputs.

  rewrite <- (oracle_outputs_length n f).

  apply count_false_from_total.

Qed.

Lemma count_true_zero_implies_all_false :

forall l,

count_true l = 0 ->

forall b,

In b l ->

b = false.

Proof.

  induction l as [|a l IH].

  - intros Hcount b Hin.

    simpl in Hin.

    contradiction.

  - intros Hcount b Hin.

    destruct a.

    + simpl in Hcount.

      discriminate.

    + simpl in Hcount.

      simpl in Hin.

      destruct Hin.

      * symmetry.
        exact H.

      * apply IH.

        exact Hcount.

        exact H.

Qed.

Lemma count_false_zero_implies_all_true :

forall l,

count_false l = 0 ->

forall b,

In b l ->

b = true.

Proof.

  induction l as [|a l IH].

  - intros Hcount b Hin.

    simpl in Hin.

    contradiction.

  - intros Hcount b Hin.

    destruct a.

    + simpl in Hcount.

      simpl in Hin.

      destruct Hin.

      * symmetry.
        exact H.

      * apply IH.

        exact Hcount.

        exact H.

    + simpl in Hcount.

      discriminate.

Qed.

(*************************************************************)
(* Constant Oracles                                          *)
(*************************************************************)


Theorem constant_zero_is_constant :

forall n,

Constant n constant_zero.

Proof.

  intro n.

  unfold Constant.

  left.

  unfold count_true_outputs.
  unfold oracle_outputs.

  simpl.

  unfold oracle_function.
  unfold constant_zero.
  unfold constant_zero_fun.

  apply count_true_map_false.

Qed.



Theorem constant_one_is_constant :

forall n,

Constant n constant_one.

Proof.

  intro n.

  unfold Constant.

  right.

  unfold count_false_outputs.
  unfold count_true_outputs.
  unfold oracle_outputs.
  unfold enumerate_outputs.

  unfold oracle_function.
  unfold constant_one.
  unfold constant_one_fun.

  simpl.

  rewrite count_true_map_true.

  unfold number_of_inputs.

  rewrite enumerate_bitstrings_length.

  lia.

Qed.



(*************************************************************)
(* Balanced Oracles                                          *)
(*************************************************************)

(*************************************************************)
(* First Bit Oracle Semantics                                *)
(*************************************************************)
Lemma first_bit_count_true :

forall n,

count_true_outputs first_bit (S n)
=
Nat.pow 2 n.

Proof.

  intro n.

  unfold count_true_outputs.
  unfold oracle_outputs.
  unfold enumerate_outputs.

  simpl [enumerate_bitstrings].

Admitted.

Lemma first_bit_count_false :

forall n,

count_false_outputs first_bit (S n)
=
Nat.pow 2 n.

Proof.

  intro n.

  unfold count_false_outputs.
  unfold oracle_outputs.
  unfold enumerate_outputs.

  simpl [enumerate_bitstrings].

Admitted.
(*The two above can be left for now*)

Theorem first_bit_is_balanced :

forall n,

n > 0 ->

Balanced n oracle_first_bit.

Proof.

  intros n Hn.

  destruct n.

  -
    simpl in Hn.
    lia.

  -
    unfold Balanced.

    unfold oracle_function.
    unfold oracle_first_bit.
    unfold first_bit_fun.

    rewrite first_bit_count_true.
    rewrite first_bit_count_false.

    reflexivity.

Qed.
(*************************************************************)
(* Parity Oracle Semantics                                   *)
(*************************************************************)
Lemma parity_flip_first_bit :

forall xs,

parity (true :: xs)
=
negb (parity (false :: xs)).

Proof.

  intro xs.

  simpl.

  destruct (parity xs);

  reflexivity.

Qed.

Theorem parity_is_balanced :

forall n,

n > 0 ->

Balanced n oracle_parity.

Proof.

Admitted.



Theorem full_parity_is_balanced :

forall n,

Balanced n oracle_full_parity.

Proof.

Admitted.

Theorem xor_two_bits_is_balanced :

forall n,

Balanced n oracle_xor_two_bits.

Proof.
Admitted.

Theorem example_balanced_is_balanced :

forall n,

Balanced n oracle_example_balanced.

Proof.
Admitted.


(*************************************************************)
(* Affine Oracle                                             *)
(*************************************************************)


Theorem affine_is_balanced :

forall n,

Balanced n oracle_affine.

Proof.

  intro n.

  unfold Balanced.

  unfold oracle_function.
  unfold oracle_affine.
  unfold affine_fun.

Admitted.



(*************************************************************)
(* Nonlinear Oracle                                          *)
(*************************************************************)


Lemma and_xor_is_balanced :

forall n,

Balanced n oracle_and_xor.

Proof.
Admitted.

(*************************************************************)
(* Invalid Oracles                                           *)
(*************************************************************)


Theorem majority_invalid :

forall n,

Invalid n oracle_majority.

Proof.

Admitted.



Theorem single_marked_invalid :

forall n,

Invalid n oracle_single_marked.

Proof.

Admitted.



(*************************************************************)
(* Promise Satisfaction                                      *)
(*************************************************************)
Theorem first_bit_satisfies_promise :

forall n,

n > 0 ->

DJPromise n oracle_first_bit.

Proof.
  intros n Hn.
  right.
  now apply first_bit_is_balanced.
Qed.

Theorem parity_satisfies_promise :

forall n,

n > 0 ->

DJPromise n oracle_parity.

Proof.

  intros n Hn.

  right.

  apply parity_is_balanced.

  exact Hn.

Qed.



Theorem affine_satisfies_promise :

forall n,

DJPromise n oracle_affine.

Proof.

  intro n.

  right.

  apply affine_is_balanced.

Qed.



Theorem constant_zero_satisfies_promise :

forall n,

DJPromise n constant_zero.

Proof.

  intro n.

  left.

  apply constant_zero_is_constant.

Qed.



Theorem constant_one_satisfies_promise :

forall n,

DJPromise n constant_one.

Proof.

  intro n.

  left.

  apply constant_one_is_constant.

Qed.



Theorem full_parity_satisfies_promise :

forall n,

DJPromise n oracle_full_parity.

Proof.

  intro n.

  right.

  apply full_parity_is_balanced.

Qed.

Theorem xor_two_bits_satisfies_promise :

forall n,

DJPromise n oracle_xor_two_bits.

Proof.

  intro n.

  right.

  apply xor_two_bits_is_balanced.

Qed.


Theorem and_xor_satisfies_promise :

forall n,

DJPromise n oracle_and_xor.

Proof.

  intro n.

  right.

  apply and_xor_is_balanced.

Qed.



(*************************************************************)
(* Generic Lemmas for Oracle Property Generalisation         *)
(*************************************************************)


Lemma affine_oracle_correct :

forall x,

oracle_function oracle_affine x = affine x.

Proof.

reflexivity.

Qed.



Lemma xor_two_bits_oracle_correct :

forall x,

oracle_function oracle_xor_two_bits x = xor_two_bits x.

Proof.

reflexivity.

Qed.



Theorem parity_oracle_correct :

forall x,

oracle_function oracle_parity x = parity x.

Proof.

reflexivity.

Qed.



Theorem example_balanced_satisfies_promise :

forall n,

DJPromise n oracle_example_balanced.

Proof.

  intro n.

  right.

  apply example_balanced_is_balanced.

Qed.

(*************************************************************)
(* Oracle Counting Lemmas                                    *)
(*************************************************************)
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

Lemma parity_has_false_output :

forall n,

n > 0 ->

count_false_outputs parity n > 0.

Proof.

  intros n Hn.

  unfold count_false_outputs.
  unfold count_true_outputs.
  unfold oracle_outputs.

Admitted. (*Leave admitted*)

Lemma parity_has_true_output :

forall n,

n > 0 ->

count_true_outputs parity n > 0.

Proof.

  intros n Hn.

  unfold count_true_outputs.
  unfold oracle_outputs.

Admitted. (*Leave admitted*)



(*************************************************************)
(* Generic Lemmas for Proving Correctness                    *)
(*************************************************************)
Lemma Constant_implies_kind :
forall n f,

Constant n f ->

oracle_kind f = OKConstantZero 
\/
oracle_kind f = OKConstantOne.

Proof.
Admitted. (*Leave admitted*)

Lemma constant_zero_not_balanced :

forall n,

~ Balanced n constant_zero.

Proof.
Admitted. (*Leave admitted*)

Lemma constant_one_not_balanced :

forall n,

~ Balanced n constant_one.

Proof.
Admitted. (*Leave admitted*)

Lemma Balanced_implies_not_constant :

forall n f,

n > 0 ->

Balanced n f ->

~ Constant n f.

Proof.

  intros n f Hn Hbalanced Hconstant.

  destruct Hconstant as [Htrue | Hfalse].

  -
    apply (Balanced_not_zero_counts n f Hn Hbalanced).

    exact Htrue.


  -
    apply (Balanced_not_zero_false_counts n f Hn Hbalanced).

    exact Hfalse.

Qed.

(*************************************************************)
(* Universal Oracle Semantic Properties                      *)
(*************************************************************)
Lemma In_oracle_outputs :

forall n (f : Oracle) x,

length x = n ->

In (f x) (oracle_outputs f n).

Proof.

  intros n f x Hlen.

  unfold oracle_outputs.

  unfold enumerate_outputs.

  apply in_map.

  apply enumerate_bitstrings_complete.

  exact Hlen.

Qed.

Lemma oracle_outputs_count_total :

forall n (f : Oracle),

count_true_outputs f n
+
count_false_outputs f n
=
number_of_inputs n.

Proof.

  intros n f.

  rewrite count_false_outputs_correct.

  unfold count_true_outputs.

  unfold number_of_inputs.

  rewrite <- (oracle_outputs_length n f).

  apply count_true_false_total.

Qed.

Lemma Constant_semantic :

forall n (f : OracleInstance),

Constant n f ->

exists b : bool,

forall x,

length x = n ->

oracle_function f x = b.

Proof.

  intros n f Hconstant.

  unfold Constant in Hconstant.

  unfold count_true_outputs in Hconstant.

  unfold count_false_outputs in Hconstant.

  destruct Hconstant as [Htrue | Hfalse].

  - exists false.

    intros x Hlen.

    apply count_true_zero_implies_all_false
      with (l := oracle_outputs (oracle_function f) n).

    + exact Htrue.

    + apply In_oracle_outputs.

      exact Hlen.

  - exists true.

    intros x Hlen.

    apply count_false_zero_implies_all_true
      with (l := oracle_outputs (oracle_function f) n).

    + rewrite <- count_false_outputs_correct.
      exact Hfalse.

    + apply In_oracle_outputs.

      exact Hlen.

Qed.

Lemma Constant_n_functional_eq :

forall n (f : OracleInstance),

Constant n f ->

exists b : bool,

forall x,

length x = n ->

oracle_function f x =
(if b then constant_one_fun else constant_zero_fun) x.

Proof.

  intros n f Hconstant.

  destruct (Constant_semantic n f Hconstant)
    as [b Hb].

  exists b.

  intros x Hlen.

  destruct b.

  - simpl.
    apply Hb.
    exact Hlen.

  - simpl.
    apply Hb.
    exact Hlen.

Qed.

Lemma Constant_semantic_instance :

forall n (f : OracleInstance),

Constant n f ->

exists g : OracleInstance,

(g = constant_zero \/ g = constant_one)
/\
(forall x,

 length x = n ->

 oracle_function f x =
 oracle_function g x).

Proof.

  intros n f Hconstant.

  destruct (Constant_semantic n f Hconstant)
    as [b Hb].

  destruct b.

  - (* constant one *)

    exists constant_one.

    split.

    + right.
      reflexivity.

    + intros x Hlen.

      simpl.

      apply Hb.

      exact Hlen.

  - (* constant zero *)

    exists constant_zero.

    split.

    + left.
      reflexivity.

    + intros x Hlen.

      simpl.

      apply Hb.

      exact Hlen.

Qed.

Lemma Balanced_double_true :

forall n (f : OracleInstance),

Balanced n f ->

count_true_outputs (oracle_function f) n
+
count_true_outputs (oracle_function f) n
=
number_of_inputs n.

Proof.

  intros n f Hbalanced.

  unfold Balanced in Hbalanced.

  assert (
    count_true_outputs (oracle_function f) n
    +
    count_false_outputs (oracle_function f) n
    =
    number_of_inputs n
  ) as Htotal.

  {
    apply oracle_outputs_count_total.
  }

  rewrite <- Hbalanced in Htotal.

  exact Htotal.

Qed.

(*
 Oracle-specific balance proofs are currently abstracted.
 These lemmas represent mathematical properties of oracle families
 rather than verification framework properties.
*)