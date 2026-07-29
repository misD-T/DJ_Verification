(*************************************************************)
(* FrameworkSoundness.v                                     *)
(*                                                           *)
(* Soundness Results for the Quantum Verification Framework  *)
(*                                                           *)
(* Establishes that HH and QDL verification imply semantic   *)
(* algorithm correctness.                                   *)
(*************************************************************)


From Coq Require Import List Bool Arith Lia Classical.

Import ListNotations.


Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import Quantum.QDL.
Require Import Quantum.HoaresHeisenberg.


Require Import Final.Framework.
Require Import Final.AlgorithmVerification.
Require Import Final.LogicComparison.

(*************************************************************)
(* Hoare-Heisenberg Soundness                                *)
(*************************************************************)

Theorem HH_framework_soundness :

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
(* Quantum Dynamic Logic Soundness                           *)
(*************************************************************)

Theorem QDL_framework_soundness :

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
(* Logic Agreement                                           *)
(*************************************************************)

Theorem HH_QDL_framework_agreement :

forall spec pre post,

HHVerified (AlgorithmToHH spec)

->

QDLVerified (AlgorithmToQDL spec pre post)

->

AlgorithmCorrect
   (AlgorithmInput spec)
   (AlgorithmProgram spec)
   (AlgorithmOutput spec)

/\

AlgorithmCorrect
   (FormulaPredicate pre)
   (AlgorithmProgram spec)
   (FormulaPredicate post).

Proof.

  intros spec pre post HHH HQDL.

  split.

  - apply HH_framework_soundness.
    exact HHH.

  - apply QDL_framework_soundness.
    exact HQDL.

Qed.

(*************************************************************)
(* Framework Correctness                                      *)
(*************************************************************)

Theorem QuantumVerificationFramework_sound :

forall spec,

HHVerified (AlgorithmToHH spec)

->

exists P Q,

AlgorithmCorrect
    P
    (AlgorithmProgram spec)
    Q.

Proof.

  intros spec H.

  exists
    (AlgorithmInput spec),
    (AlgorithmOutput spec).

  apply HH_framework_soundness.

  exact H.

Qed.