(*************************************************************)
(* GroverOperators.v                                         *)
(*                                                           *)
(* Semantic Operators for Grover Search                      *)
(*************************************************************)

From Coq Require Import List Bool String Lia.

Import ListNotations.

Open Scope string_scope.


Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.
Require Import Quantum.AmplitudeSemantics.

Require Import DJ.Oracles.Oracles.


(*************************************************************)
(* Identity Operator                                         *)
(*************************************************************)

Definition IdentityOperator : QuantumOperator :=
fun ρ => ρ.



(*************************************************************)
(* Amplitude Amplification                                   *)
(*************************************************************)

Definition Amplify
         (f : OracleInstance)
         (n : nat)
         (amps : AmplitudeState)
         : AmplitudeState :=

ReflectAboutMean
   (PhaseFlip f amps)
   n.



(*************************************************************)
(* Oracle Phase Operator                                     *)
(*************************************************************)

Definition OraclePhase
         (f : OracleInstance)
         : QuantumOperator :=

fun ρ =>
{|
  qs_bits := qs_bits ρ;

  qs_amplitudes :=
  match qs_amplitudes ρ with

  | None => None

  | Some amps =>
      Some (PhaseFlip f amps)

  end;

  qs_target := qs_target ρ;

  qs_qubits := qs_qubits ρ;

  qs_oracle := Some f;

  qs_measurement := qs_measurement ρ;

  qs_history := qs_history ρ;

  qs_status := qs_status ρ;

  qs_symbolic_output := qs_symbolic_output ρ
|}.



(*************************************************************)
(* Diffusion Operator                                        *)
(*************************************************************)

Definition Diffusion
         : QuantumOperator :=

fun ρ =>
{|
  qs_bits := qs_bits ρ;

  qs_amplitudes :=
  match qs_amplitudes ρ with

  | None => None

  | Some amps =>
      Some
        (ReflectAboutMean amps (qs_qubits ρ))

  end;

  qs_target := qs_target ρ;

  qs_qubits := qs_qubits ρ;

  qs_oracle := qs_oracle ρ;

  qs_measurement := qs_measurement ρ;

  qs_history :=
      "Diffusion" :: qs_history ρ;

  qs_status := qs_status ρ;

  qs_symbolic_output := qs_symbolic_output ρ
|}.



(*************************************************************)
(* Single Grover Iteration                                   *)
(*************************************************************)

Definition GroverIteration
         (f : OracleInstance)
         : QuantumOperator :=

Compose
   (OraclePhase f)
   Diffusion.



(*************************************************************)
(* Repeat Operator                                           *)
(*************************************************************)

Fixpoint RepeatOperator
         (k : nat)
         (U : QuantumOperator)
         : QuantumOperator :=

match k with

| O =>
    IdentityOperator

| S k' =>
    Compose
      U
      (RepeatOperator k' U)

end.



(*************************************************************)
(* Grover Iterations                                         *)
(*************************************************************)

Definition GroverIterations
       (n:nat)
       : nat :=
n.



(*************************************************************)
(* Complete Grover Operator                                  *)
(*************************************************************)

Definition GroverOperator
         (n : nat)
         (f : OracleInstance)
         : QuantumOperator :=

Compose
   Hadamard
   (RepeatOperator
      (GroverIterations n)
      (GroverIteration f)).



(*************************************************************)
(* Preservation Lemmas                                       *)
(*************************************************************)


Lemma IdentityOperator_preserves_qubits :

forall ρ,

qs_qubits (IdentityOperator ρ)
=
qs_qubits ρ.

Proof.

  reflexivity.

Qed.



Lemma Diffusion_preserves_qubits :

forall ρ,

qs_qubits (Diffusion ρ)
=
qs_qubits ρ.

Proof.

  reflexivity.

Qed.



Lemma OraclePhase_preserves_qubits :

forall f ρ,

qs_qubits (OraclePhase f ρ)
=
qs_qubits ρ.

Proof.

  reflexivity.

Qed.



Lemma Hadamard_preserves_qubits :

forall ρ,

qs_qubits (Hadamard ρ)
=
qs_qubits ρ.

Proof.

  reflexivity.

Qed.



Lemma RepeatOperator_preserves_qubits :

forall k U,

(forall ρ,
 qs_qubits (U ρ)
 =
 qs_qubits ρ)

->

forall ρ,

qs_qubits (RepeatOperator k U ρ)
=
qs_qubits ρ.

Proof.

  intros k U H.

  induction k.

  - intros ρ.

    simpl.

    reflexivity.


  - intros ρ.

    simpl.

    unfold Compose.

    simpl.

    rewrite H.

    apply IHk.

Qed.



Lemma GroverIteration_preserves_qubits :

forall f ρ,

qs_qubits (GroverIteration f ρ)
=
qs_qubits ρ.

Proof.

  intros f ρ.

  unfold GroverIteration.

  unfold Compose.

  change
  (qs_qubits (Diffusion (OraclePhase f ρ))
   =
   qs_qubits ρ).

  rewrite Diffusion_preserves_qubits.

  apply OraclePhase_preserves_qubits.

Qed.



(*************************************************************)
(* Oracle Tracking                                           *)
(*************************************************************)


Lemma OraclePhase_records_oracle :

forall f ρ,

qs_oracle (OraclePhase f ρ)
=
Some f.

Proof.

  reflexivity.

Qed.



Lemma GroverIteration_records_oracle :

forall f ρ,

qs_oracle (GroverIteration f ρ)
=
Some f.

Proof.

  intros f ρ.

  unfold GroverIteration.

  unfold Compose.

  simpl.

  reflexivity.

Qed.

Lemma RepeatOperator_records_oracle :

forall k f ρ,

qs_oracle
(RepeatOperator (S k)
   (GroverIteration f)
   ρ)
=
Some f.

Proof.

  intros k f ρ.

  simpl.

  unfold Compose.

  simpl.

  apply (GroverIteration_records_oracle f
        (RepeatOperator k (GroverIteration f) ρ)).

Qed.

(*************************************************************)
(* Complete Grover Properties                                *)
(*************************************************************)


Lemma GroverOperator_preserves_qubits :

forall n f ρ,

qs_qubits (GroverOperator n f ρ)
=
qs_qubits ρ.

Proof.

  intros n f ρ.

  unfold GroverOperator.

  unfold Compose.

  simpl.

  rewrite (RepeatOperator_preserves_qubits
             (GroverIterations n)
             (GroverIteration f)
             (Hadamard_preserves_qubits)).

  reflexivity.

Qed.