(*************************************************************)
(* LogicComparison.v                                         *)
(*                                                           *)
(* Comparison of HH and QDL Verification                     *)
(*                                                           *)
(* Demonstrates that different quantum verification logics    *)
(* establish correctness through a shared semantic layer.     *)
(*************************************************************)


From Coq Require Import List Bool Arith Lia Classical.

Import ListNotations.


Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.


Require Import Final.Framework.
Require Import Final.AlgorithmVerification.



(*************************************************************)
(* Semantic Predicate Equivalence                             *)
(*                                                           *)
(* Two predicates are equivalent when they describe exactly   *)
(* the same set of quantum states.                            *)
(*************************************************************)


Definition EquivalentPredicates
           (P Q : Predicate)
           : Prop :=

forall ρ,

P ρ <-> Q ρ.



Lemma equivalent_predicates_refl :

forall P,

EquivalentPredicates P P.

Proof.

  intros P ρ.

  reflexivity.

Qed.



Lemma equivalent_predicates_sym :

forall P Q,

EquivalentPredicates P Q

->

EquivalentPredicates Q P.

Proof.

  intros P Q H ρ.

  symmetry.

  apply H.

Qed.



Lemma equivalent_predicates_trans :

forall P Q R,

EquivalentPredicates P Q

->

EquivalentPredicates Q R

->

EquivalentPredicates P R.

Proof.

  intros P Q R HPQ HQR ρ.

  split.

  -

    intro HP.

    apply HQR.

    apply HPQ.

    exact HP.


  -

    intro HR.

    apply HPQ.

    apply HQR.

    exact HR.

Qed.



(*************************************************************)
(* Hoare-Heisenberg Semantic Correctness                      *)
(*                                                           *)
(* HH verification implies correctness at the semantic        *)
(* algorithm level.                                          *)
(*************************************************************)


Theorem HH_establishes_semantic_correctness :

forall spec,

HHVerified (AlgorithmToHH spec)

->

AlgorithmCorrect
   (AlgorithmInput spec)
   (AlgorithmProgram spec)
   (AlgorithmOutput spec).

Proof.

  intros spec H.

  apply HH_implies_algorithm_correct.

  exact H.

Qed.



(*************************************************************)
(* QDL Semantic Correctness                                  *)
(*                                                           *)
(* QDL verification implies correctness at the semantic       *)
(* algorithm level through formula interpretation.             *)
(*************************************************************)


Theorem QDL_establishes_semantic_correctness :

forall spec pre post,

QDLVerified (AlgorithmToQDL spec pre post)

->

AlgorithmCorrect
   (FormulaPredicate pre)
   (AlgorithmProgram spec)
   (FormulaPredicate post).

Proof.

  intros spec pre post H.

  apply QDL_implies_algorithm_correct.

  exact H.

Qed.



(*************************************************************)
(* HH and QDL Common Semantic Layer                           *)
(*                                                           *)
(* Both logics can establish correctness of the same          *)
(* underlying quantum program.                               *)
(*                                                           *)
(* This is the central framework comparison theorem.          *)
(*************************************************************)


Theorem HH_QDL_semantics_agree :

forall spec pre post,

HHVerified (AlgorithmToHH spec)

->

QDLVerified (AlgorithmToQDL spec pre post)

->

exists HHMeaning QDLMeaning,

AlgorithmCorrect
   HHMeaning
   (AlgorithmProgram spec)
   (AlgorithmOutput spec)

/\

AlgorithmCorrect
   QDLMeaning
   (AlgorithmProgram spec)
   (FormulaPredicate post).

Proof.

  intros spec pre post HHH HQDL.

  exists
    (AlgorithmInput spec),
    (FormulaPredicate pre).


  split.

  -

    apply HH_establishes_semantic_correctness.

    exact HHH.


  -

    apply QDL_establishes_semantic_correctness.

    exact HQDL.

Qed.



(*************************************************************)
(* Logic Comparison Record                                   *)
(*                                                           *)
(* Abstract representation of a comparison between           *)
(* verification approaches.                                  *)
(*************************************************************)


Record LogicComparison :=

{

HHProofExists : Prop;

QDLProofExists : Prop;

SharedSemanticGoal : Prop

}.