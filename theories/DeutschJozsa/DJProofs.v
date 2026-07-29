(*************************************************************)
(* Correctness Proofs for the Deutsch-Jozsa Algorithm        *)
(*************************************************************)

From Coq Require Import Bool List Arith Lia Classical.
Require Import Coq.Logic.FunctionalExtensionality.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Foundations.Counting.

Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.

Require Import DJ.Verification.Balanced.
Require Import DJ.Oracles.Promise.
Require Import DJ.Verification.OracleProofs.

Require Import DJ.DeutschJozsa.DJ.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.

(*************************************************************)
(* Output Predicates                                         *)
(*************************************************************)

Definition DJZeroPost
           (n : nat)
           : Predicate :=

fun ψ =>

Measure ψ = ZeroOutput n.

Definition DJNonZeroPost
           (n : nat)
           : Predicate :=

fun ψ =>

Measure ψ <> ZeroOutput n.

(*************************************************************)
(* Hoare-Heisenberg Specifications                           *)
(*************************************************************)

Definition DJConstantHHSpec
           (n : nat)
           : HHSpecification :=
{|
  HHPre :=

      fun ψ =>

      ψ = InitialState n;

  HHProgram :=

      DJOperator constant_zero;

  HHPost :=

      DJZeroPost n
|}.

Definition DJBalancedHHSpec
           (n : nat)
           : HHSpecification :=
{|
  HHPre :=

      fun ψ =>

      ψ = InitialState (S n);

  HHProgram :=

      DJOperator oracle_parity;

  HHPost :=

      DJNonZeroPost (S n)
|}.

(*************************************************************)
(* QDL Specifications                                        *)
(*************************************************************)
Definition DJInitial
           (n : nat)
           : Formula :=

Atom
  (fun ψ =>
      ψ = InitialState n).

Definition DJConstantFormula
           (n : nat)
           : Formula :=

Implication
   (DJInitial n)
   (Box
      (DJOperator constant_zero)
      (Atom (DJZeroPost n))).

Definition DJBalancedFormula
           (n : nat)
           : Formula :=

Implication
   (DJInitial (S n))
   (Box
      (DJOperator oracle_parity)
      (Atom (DJNonZeroPost (S n)))).

(*************************************************************)
(* Hadamard Preservation                                     *)
(*************************************************************)
Lemma Hadamard_preserves_bits :

forall ρ,

qs_bits (Hadamard ρ)
=
qs_bits ρ.

Proof.

  intros ρ.

  reflexivity.

Qed.

Lemma Hadamard_initial_length :

forall n,

length (qs_bits (Hadamard (InitialState n)))
=
n.

Proof.

  intros n.

  rewrite Hadamard_preserves_bits.

  simpl.

  apply length_all_zeros.

Qed.
(*************************************************************)
(* Lemmas for Properties                                     *)
(*************************************************************)
Lemma DJOperator_preserves_qubits :
forall f ρ,
qs_qubits (DJOperator f ρ)
=
qs_qubits ρ.

Proof.
  intros f ρ.

  unfold DJOperator.
  unfold Compose.

  simpl.

  reflexivity.

Qed.

Lemma DJOperator_records_oracle :

forall f ρ,

qs_oracle (DJOperator f ρ)
=
Some f.

Proof.

  intros f ρ.

  unfold DJOperator.
  unfold Compose.

  simpl.

  reflexivity.

Qed.

(*************************************************************)
(* Deutsch–Jozsa Semantic Properties                         *)
(*************************************************************)

Theorem DJ_constant_semantics :

forall n,

DJ constant_zero n
=
ZeroOutput n.

Proof.

  intro n.

  apply DJ_constant_zero_output.

Qed.

Theorem DJ_balanced_semantics :

forall n,

n > 0 ->

DJ oracle_parity n
<>
ZeroOutput n.

Proof.

  intros n Hn.

  rewrite DJ_parity_output.

  unfold ZeroOutput.

  apply repeat_true_not_all_zeros.

  exact Hn.

Qed.

(*************************************************************)
(* Bridge Lemmas                                             *)
(*************************************************************)

Lemma ZeroOutput_is_OutputZero :

forall n,

OutputZero n (ZeroOutput n).

Proof.

  intro n.

  unfold OutputZero.
  unfold ZeroOutput.

  reflexivity.

Qed.

(*************************************************************)
(* Constant                                                  *)
(*************************************************************)
Lemma DJ_constant_post_implies_accept :

forall n,

DJZeroPost n
  (DJOperator constant_zero (InitialState n))

->

DJAccepts constant_zero n.

Proof.

  intros n H.

  unfold DJZeroPost in H.

  unfold DJAccepts.
  unfold DJ.
  unfold DJExecute.

  rewrite H.

  apply ZeroOutput_is_OutputZero.

Qed.

(*************************************************************)
(* Bridge Lemmas                                             *)
(*************************************************************)
Lemma OutputNonZero_from_not_ZeroOutput :

forall b n,

length b = n ->
b <> ZeroOutput n ->
OutputNonZero n b.

Proof.

  intros b n Hlen Hzero.

  unfold OutputNonZero.

  intro Hz.

  apply Hzero.

  unfold ZeroOutput.

  exact Hz.

Qed.

Lemma DJ_output_length :

forall n f,

List.length (Measure (DJOperator f (InitialState n)))
=
n.

Proof.
Admitted. (*will come back for to complete properly*)

(*************************************************************)
(* Balanced                                                  *)
(*************************************************************)
Lemma DJ_balanced_post_implies_reject :

forall n,

DJNonZeroPost n
  (DJOperator oracle_parity (InitialState n))

->

DJRejects oracle_parity n.

Proof.

  intros n H.

  unfold DJNonZeroPost in H.

  unfold DJRejects.
  unfold DJ.

  unfold DJExecute.

  apply OutputNonZero_from_not_ZeroOutput with (n := n).

  - apply DJ_output_length.

  - exact H.

Qed.

(*************************************************************)
(* Post Lemma                                                *)
(*************************************************************)
Lemma DJ_constant_post :

forall n,

DJZeroPost n
  (DJOperator constant_zero (InitialState n)).

Proof.

  intro n.

  unfold DJZeroPost.

  unfold Measure.

  simpl.

  apply DJ_constant_zero_final.

Qed.

Lemma DJ_balanced_post :

forall n,

DJNonZeroPost (S n)
  (DJOperator oracle_parity (InitialState (S n))).

Proof.

  intros n.

  unfold DJNonZeroPost.

  unfold DJ.
  unfold DJExecute.

  apply DJ_balanced_semantics.

  apply Nat.lt_0_succ.

Qed.

(*************************************************************)
(* Constant Output                                           *)
(*************************************************************)
Lemma Constant_false_output :

forall n f,

Constant n f ->

forall x,

oracle_function f x = false.

Proof.
Admitted.

Lemma Constant_true_output :

forall n f,

Constant n f ->

forall x,

oracle_function f x = true.

Proof.
Admitted.

(*currently too strong with my Constant Def so leave for now*)

(*************************************************************)
(* Semantic Verification Theorems                            *)
(*************************************************************)

Theorem DJ_constant_HH_verified :
forall n,
HHVerified (DJConstantHHSpec n).
Proof.
  intros n.

  unfold HHVerified.
  unfold HoareTriple.
  unfold DJConstantHHSpec.

  simpl.

  intros ψ Hpre.

  rewrite Hpre.

  unfold DJZeroPost.
  unfold DJOperator.
  unfold Compose.

  simpl.

  apply DJ_constant_semantics.
Qed.

Theorem DJ_balanced_HH_verified :

forall n,

HHVerified (DJBalancedHHSpec n).

Proof.

  intros n.

  unfold HHVerified.
  unfold HoareTriple.
  unfold DJBalancedHHSpec.

  intros ψ Hpre.

  rewrite Hpre.

  unfold DJNonZeroPost.

  unfold DJ.
  unfold DJExecute.

  apply DJ_balanced_semantics.

  apply Nat.lt_0_succ.

Qed.

Theorem DJ_constant_QDL_verified :

forall n,

Valid (DJConstantFormula n).

Proof.
  intros n.

  unfold Valid.
  intros ψ.

  unfold DJConstantFormula.
  simpl.

  unfold DJInitial in *.

  intros Hinit.

  rewrite Hinit.

  apply DJ_constant_post.
Qed.

Theorem DJ_balanced_QDL_verified :

forall n,

Valid (DJBalancedFormula n).

Proof.
  intros n.

  unfold Valid.
  intros ψ.

  unfold DJBalancedFormula.
  simpl.

  unfold DJInitial in *.

  intros Hinit.

  rewrite Hinit.

  apply DJ_balanced_post.
Qed.

(*************************************************************)
(* Extensionality for DJ                                     *)
(*************************************************************)
Lemma DJ_kind_extensionality :

forall n f g,

oracle_kind f = oracle_kind g ->

DJ f n = DJ g n.

Proof.

  intros n f g Hkind.

  unfold DJ.
  unfold DeutschJozsa.
  unfold DJExecute.

  unfold DJOperator.

  rewrite Hkind.

  reflexivity.

Qed.

(*************************************************************)
(* Correctness for Constant Oracles                          *)
(*************************************************************)
Theorem DJ_constant_correct :

forall n (f : OracleInstance),

Constant n f ->

DJAccepts f n.

Proof.

  intros n f Hconstant.

  unfold DJAccepts.
  unfold OutputZero.

  destruct (Constant_implies_kind n f Hconstant)
    as [Hzero | HOne].

  - (* f is constant zero *)

    rewrite (DJ_kind_extensionality
               n
               f
               constant_zero
               Hzero).

    apply DJ_constant_zero_output.


  - (* f is constant one *)

    rewrite (DJ_kind_extensionality
               n
               f
               constant_one
               HOne).

    apply DJ_constant_one_output.

Qed.

(*************************************************************)
(* Verified Implications                                     *)
(*************************************************************)

Theorem verified_implies_promise :

  forall n f,

  DJVerified n f ->

  PromiseHolds n f.

Proof.

  intros n f Hverified.

  unfold DJVerified in Hverified.

  destruct Hverified as [Hpromise _].

  exact Hpromise.

Qed.



Theorem verified_implies_correct :

  forall n f,

  DJVerified n f ->

  DJAlgorithmCorrect n f.

Proof.

  intros n f Hverified.

  unfold DJVerified in Hverified.

  destruct Hverified as [_ Hcorrect].

  exact Hcorrect.

Qed.

Lemma promise_partition :

forall (n : nat) (f : OracleInstance),

PromiseHolds n f
\/
PromiseFails n f.

Proof.

  intros n f.

  unfold PromiseHolds.
  unfold PromiseFails.

  apply classic.

Qed.

(*************************************************************)
(* Oracle-specific Correctness                               *)
(*************************************************************)

Theorem DJ_first_bit_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_first_bit.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_first_bit_output.

    intro Hzero.

    apply (first_bit_output_not_zero n Hn).

    exact Hzero.

Qed.



Theorem DJ_parity_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_parity.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_parity_output.

    apply repeat_true_not_all_zeros.

    exact Hn.

Qed.



Theorem DJ_full_parity_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_full_parity.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_full_parity_output.

    apply repeat_true_not_all_zeros.

    exact Hn.

Qed.



Theorem DJ_affine_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_affine.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_affine_output.

    apply repeat_true_not_all_zeros.

    exact Hn.

Qed.



Theorem DJ_xor_two_bits_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_xor_two_bits.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_xor_two_bits_output.

    apply repeat_true_not_all_zeros.

    exact Hn.

Qed.



Theorem DJ_and_xor_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_and_xor.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_and_xor_output.

    apply repeat_true_not_all_zeros.

    exact Hn.

Qed.



Theorem DJ_example_balanced_correct :

forall n,

n > 0 ->

DJAlgorithmCorrect n oracle_example_balanced.

Proof.

  intros n Hn.

  unfold DJAlgorithmCorrect.

  split.

  -
    intro Hconstant.

    apply DJ_constant_correct.

    exact Hconstant.


  -
    intro Hbalanced.

    unfold DJRejects.
    unfold OutputNonZero.

    rewrite DJ_example_balanced_output.

    apply repeat_true_not_all_zeros.

    exact Hn.

Qed.

(*************************************************************)
(* Verified Example Oracles                                  *)
(*************************************************************)

Theorem constant_zero_verified :
forall n,
DJVerified n constant_zero.
Proof.

  intro n.

  apply DJVerified_from_correct.

  - apply DJPromise_implies_PromiseHolds.
    apply constant_zero_satisfies_promise.

  - split.

    + apply DJ_constant_correct.

    + intros Hbalanced.

      exfalso.

      apply (constant_zero_not_balanced n).

      exact Hbalanced.

Qed.

Theorem constant_one_verified :

forall n,

DJVerified n constant_one.

Proof.

  intro n.

  apply DJVerified_from_correct.

  - apply DJPromise_implies_PromiseHolds.
    apply constant_one_satisfies_promise.

  - split.

    + apply DJ_constant_correct.

    + intro Hbalanced.

      exfalso.

      apply (constant_one_not_balanced n).

      exact Hbalanced.

Qed.

(*************************************************************)
(* Verified Balanced Oracles                                  *)
(*************************************************************)

Theorem first_bit_verified :

forall n,

n > 0 ->

DJVerified n oracle_first_bit.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply first_bit_satisfies_promise.

    exact Hn.

  -
    apply DJ_first_bit_correct.

    exact Hn.

Qed.


Theorem parity_verified :

forall n,

n > 0 ->

DJVerified n oracle_parity.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply parity_satisfies_promise.

    exact Hn.

  -
    apply DJ_parity_correct.

    exact Hn.

Qed.


Theorem full_parity_verified :

forall n,

n > 0 ->

DJVerified n oracle_full_parity.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply full_parity_satisfies_promise.

  -
    apply DJ_full_parity_correct.

    exact Hn.

Qed.


Theorem affine_verified :

forall n,

n > 0 ->

DJVerified n oracle_affine.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply affine_satisfies_promise.

  -
    apply DJ_affine_correct.

    exact Hn.

Qed.


Theorem xor_two_bits_verified :

forall n,

n > 0 ->

DJVerified n oracle_xor_two_bits.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply xor_two_bits_satisfies_promise.

  -
    apply DJ_xor_two_bits_correct.

    exact Hn.

Qed.


Theorem and_xor_verified :

forall n,

n > 0 ->

DJVerified n oracle_and_xor.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply and_xor_satisfies_promise.

  -
    apply DJ_and_xor_correct.

    exact Hn.

Qed.


Theorem example_balanced_verified :

forall n,

n > 0 ->

DJVerified n oracle_example_balanced.

Proof.

  intros n Hn.

  apply DJVerified_from_correct.

  -
    apply DJPromise_implies_PromiseHolds.

    apply example_balanced_satisfies_promise.

  -
    apply DJ_example_balanced_correct.

    exact Hn.

Qed.

(*************************************************************)
(* For Invalid Oracles                                       *)
(*************************************************************)

Theorem invalid_oracle_not_correct :

  forall n (f : OracleInstance) (result : BitString),

  PromiseFails n f ->

  ~ DJCorrect n f result.

Proof.

  intros n f result Hfail Hcorrect.

  unfold DJCorrect in Hcorrect.

  destruct Hcorrect as [Hpromise _].

  unfold PromiseFails in Hfail.

  unfold PromiseHolds in Hpromise.

  unfold Invalid in Hfail.

  apply Hfail.

  exact Hpromise.

Qed.

(*************************************************************)
(* Promise Violations                                        *)
(*************************************************************)

Theorem invalid_oracles_not_verified :

  forall n (f : OracleInstance),

  PromiseFails n f ->

  ~ DJVerified n f.

Proof.

  intros n f Hfail Hverified.

  unfold DJVerified in Hverified.

  destruct Hverified as [Hpromise _].

  unfold PromiseFails in Hfail.
  unfold PromiseHolds in Hpromise.
  unfold Invalid in Hfail.

  apply Hfail.

  exact Hpromise.

Qed.

(*************************************************************)
(* HH -> DJ Verification Bridges                              *)
(*************************************************************)

Theorem HH_constant_implies_DJVerified :

forall n,

HHVerified (DJConstantHHSpec n)

->

DJVerified n constant_zero.

Proof.

  intros n _.

  apply constant_zero_verified.

Qed.


Theorem HH_parity_implies_DJVerified :

forall n,

n > 0 ->

HHVerified (DJBalancedHHSpec n)

->

DJVerified n oracle_parity.

Proof.

  intros n Hn _.

  apply parity_verified.

  exact Hn.

Qed.



(*************************************************************)
(* QDL -> DJ Verification Bridges                             *)
(*************************************************************)


Theorem QDL_constant_implies_DJVerified :

forall n,

Valid (DJConstantFormula n)

->

DJVerified n constant_zero.

Proof.

  intros n _.

  apply constant_zero_verified.

Qed.


Theorem QDL_parity_implies_DJVerified :

forall n,

n > 0 ->

Valid (DJBalancedFormula n)

->

DJVerified n oracle_parity.

Proof.

  intros n Hn _.

  apply parity_verified.

  exact Hn.

Qed.

(*************************************************************)
(* Soundness                                                 *)
(*************************************************************)
Theorem DJ_soundness :

  forall n (f : OracleInstance),

  DJVerified n f ->

  DJAlgorithmCorrect n f.

Proof.

  intros n f Hverified.

  unfold DJVerified in Hverified.

  destruct Hverified as [_ Hcorrect].

  exact Hcorrect.

Qed.

Theorem verified_has_promise :

forall n f,

DJVerified n f ->

DJPromise n f.

Proof.

  intros n f Hverified.

  unfold DJVerified in Hverified.

  destruct Hverified as [Hpromise _].

  exact Hpromise.

Qed.

(*************************************************************)
(* Completeness                                              *)
(*************************************************************)
Theorem DJ_completeness :

  forall n (f : OracleInstance) (result : BitString),

  DJCorrect n f result ->

  PromiseHolds n f.

Proof.

  intros n f result Hcorrect.

  destruct Hcorrect as [Hpromise _].

  exact Hpromise.

Qed.

(*************************************************************)
(* Utility Lemmas                                            *)
(*************************************************************)
Lemma verified_destruct :

  forall n f,

  DJVerified n f

  ->

  PromiseHolds n f
  /\

  DJAlgorithmCorrect n f.

Proof.

  intros n f Hverified.

  unfold DJVerified in Hverified.

  exact Hverified.

Qed.



Lemma promise_or_invalid :

  forall n f,

  DJPromise n f

  \/

  Invalid n f.

Proof.

  intros n f.

  unfold Invalid.

  apply classic.

Qed.