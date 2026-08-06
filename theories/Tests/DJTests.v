(*************************************************************)
(* DJTests.v                                                 *)
(*                                                           *)
(* Basic tests for the Deutsch-Jozsa verification framework. *)
(*************************************************************)

From Coq Require Import List Bool Arith Lia Classical.

Import ListNotations.


Require Import DJ.Foundations.BitStrings.
Require Import DJ.Foundations.Enumeration.
Require Import DJ.Foundations.Counting.


Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.
Require Import DJ.Oracles.Promise.


Require Import DJ.Verification.Balanced.
Require Import DJ.Verification.OracleProofs.


Require Import DJ.DeutschJozsa.DJ.
Require Import DJ.DeutschJozsa.DJProofs.


Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.


(*
(*************************************************************)
(* Basic BitString Tests                                     *)
(*************************************************************)


Example count_ones_test :

count_ones [true; false; true; true] = 3.

Proof.

reflexivity.

Qed.



Example constant_zero_test :

forall x,

constant_zero_fun x = false.

Proof.

apply constant_zero_evaluates.

Qed.



Example parity_test :

parity [true; true] = false.

Proof.

reflexivity.

Qed.



Example first_bit_test :

first_bit [true; false; false] = true.

Proof.

reflexivity.

Qed.



Example last_bit_test :

last_bit [true; false; true] = true.

Proof.

reflexivity.

Qed.



(*************************************************************)
(* Counting Tests                                            *)
(*************************************************************)


Example count_true_test :

count_true [true; false; true; true] = 3.

Proof.

reflexivity.

Qed.



Example count_false_test :

count_false [true; false; true; true] = 1.

Proof.

reflexivity.

Qed.




(*************************************************************)
(* Oracle Evaluation                                         *)
(*************************************************************)


Example evaluate_parity :

evaluate parity [true; false]
=
parity [true; false].

Proof.

reflexivity.

Qed.



Example evaluate_affine :

evaluate affine [true; true]
=
affine [true; true].

Proof.

reflexivity.

Qed.



(*************************************************************)
(* Oracle Instance Tests                                     *)
(*************************************************************)


Example constant_zero_instance_test :

forall x,

oracle_function constant_zero x = false.

Proof.

intro x.

reflexivity.

Qed.



Example constant_one_instance_test :

forall x,

oracle_function constant_one x = true.

Proof.

intro x.

reflexivity.

Qed.



Example parity_instance_test :

forall x,

oracle_function oracle_parity x
=
parity x.

Proof.

intro x.

reflexivity.

Qed.



(*************************************************************)
(* Promise Lemmas                                            *)
(*************************************************************)


Example promise_partition_test :

forall n f,

PromiseHolds n f
\/
PromiseFails n f.

Proof.

apply promise_partition.

Qed.



Example promise_or_invalid_test :

forall n f,

DJPromise n f
\/
Invalid n f.

Proof.

apply promise_or_invalid.

Qed.



Example invalid_is_undefined_test :

forall n f,

PromiseFails n f
->
UndefinedBehaviour n f.

Proof.

apply invalid_is_undefined.

Qed.



(*************************************************************)
(* Generic Logical Tests                                     *)
(*************************************************************)


Example promise_implies_not_invalid :

forall n f,

PromiseHolds n f
->
~ PromiseFails n f.

Proof.

apply promise_implies_defined.

Qed.



Example promise_cases_test :

forall n f,

DJPromise n f
<->
Constant n f
\/
Balanced n f.

Proof.

apply promise_cases.

Qed.



(*************************************************************)
(* Compute Examples                                          *)
(*************************************************************)


Compute count_ones [true; false; true; true].

Compute count_zeros [true; false; true; true].

Compute parity [true; false; true].

Compute first_bit [true; false].

Compute last_bit [true; false; true].

Compute enumerate_bitstrings 3.

Compute count_true [true; false; true; false].

Compute count_false [true; false; true; false].




(*************************************************************)
(* DJ Operator Tests                                         *)
(*************************************************************)


Example DJ_operator_exists :

forall f,

exists U,

U = DJOperator f.

Proof.

intro f.

exists (DJOperator f).

reflexivity.

Qed.



(*************************************************************)
(* DJ Verification Tests                                    *)
(*************************************************************)


Example verified_unfold_test :

forall n f,

DJVerified n f

<->

PromiseHolds n f
/\

DJAlgorithmCorrect n f.

Proof.

apply DJVerified_unfold.

Qed.




(*************************************************************)
(* Hoare Logic Tests                                         *)
(*************************************************************)


Example hoare_identity_test :

forall P,

HoareTriple
P
Identity
P.

Proof.

apply hoare_identity.

Qed.




Example weakest_precondition_test :

forall U Q,

{{ WeakestPrecondition U Q }}

U

{{ Q }}.

Proof.

apply weakest_precondition_correct.

Qed.




Example composition_test :

forall P Q R U V,

HoareTriple P U Q
->

HoareTriple Q V R
->

HoareTriple P (Compose U V) R.

Proof.

apply hoare_composition.

Qed.



(*************************************************************)
(* Specific Oracle Verification Tests                        *)
(*************************************************************)


Example constant_zero_promise_test :

forall n,

DJPromise n constant_zero.

Proof.

apply constant_zero_satisfies_promise.

Qed.



Example parity_promise_test :

forall n,

DJPromise n oracle_parity.

Proof.

apply parity_satisfies_promise.

Qed.



Example affine_promise_test :

forall n,

DJPromise n oracle_affine.

Proof.

apply affine_satisfies_promise.

Qed.



(*************************************************************)
(* Semantic Bridge Tests                                     *)
(*************************************************************)

(*
These stay commented until the bridge theorems
are updated for OracleInstance.
*)


(*
Example HH_bridge_test :

forall n f,

HHVerified (DJHoareSpecification n f)

->

DJVerified n f.

Proof.

apply HH_implies_DJVerified.

Qed.



Example QDL_bridge_test :

forall n f,

Valid (DJFormula n f)

->

DJVerified n f.

Proof.

apply QDL_implies_DJVerified.

Qed.
*)
*)