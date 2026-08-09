(*************************************************************)
(* QuantumState.v                                            *)
(*                                                           *)
(* Generic concrete representation of quantum states.        *)
(*                                                           *)
(* This representation is independent of any particular      *)
(* quantum algorithm. Deutsch–Jozsa, Grover, Simon, etc.     *)
(* are all built on top of this state.                       *)
(*************************************************************)

From Coq Require Import List Bool String Reals.
Import ListNotations.
Open Scope R_scope.

Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.BooleanFunctions.
Require Import forms.Oracles.Oracles.

(*************************************************************)
(* Measurement Outcomes                                      *)
(*************************************************************)

Definition MeasurementOutcome :=
  BitString.

(*************************************************************)
(* Execution Status                                          *)
(*************************************************************)

Inductive ExecutionStatus : Type :=

| Initial

| AfterHadamard

| AfterOracle

| Finished.

(*************************************************************)
(* Optional Amplitude Representation                         *)
(*************************************************************)

(* Placeholder representation.
   This can later become a proper map from basis states
   to amplitudes (e.g. BitString -> Complex). *)

Definition Amplitude := R.

Definition AmplitudeState :=
  BitString -> Amplitude.

(*************************************************************)
(* Amplitude State                                   *)
(*************************************************************)

(* Placeholder amplitude model.

   For now:
     • |00...0⟩ has amplitude 1
     • every other basis state has amplitude 0

   Later this can be upgraded to complex amplitudes and
   proper superposition semantics.
*)

Definition InitialAmplitudeState
           (n : nat)
           : AmplitudeState :=
fun bs =>

if bitstring_eqb bs (all_zeros n)

then 1%R

else 0%R.

Definition UniformAmplitudeState
           (n : nat)
           : AmplitudeState :=

fun _ => / (sqrt (INR (Nat.pow 2 n))).

(*************************************************************)
(* Quantum State                                             *)
(*************************************************************)

Record QuantumState :=
{
  qs_bits : BitString;

  qs_amplitudes : option AmplitudeState;

  qs_target : bool;

  qs_qubits : nat;

  qs_oracle : option OracleInstance;

  qs_measurement : option MeasurementOutcome;

  qs_history : list string;

  qs_status : ExecutionStatus;

  qs_symbolic_output : option BitString
}.

(*
   Optional amplitude representation.

   Existing symbolic verification (e.g. Deutsch–Jozsa)
   does not require amplitudes, so this field may be None.

   Algorithms that require amplitude semantics
   (e.g. Grover Search) populate this field with
   an explicit amplitude representation.
*)

(*************************************************************)
(* Initial State                                             *)
(*************************************************************)

Definition InitialState
           (n : nat)
           : QuantumState :=
{|
  qs_bits := all_zeros n;

  qs_amplitudes := Some (InitialAmplitudeState n);

  qs_target := true;

  qs_qubits := n;

  qs_oracle := None;

  qs_measurement := None;

  qs_history := [];

  qs_status := Initial;

  qs_symbolic_output := None
|}.

(*************************************************************)
(* WellFormed State                                          *)
(*************************************************************)
Definition WellFormedState (ρ : QuantumState) : Prop :=
  List.length (qs_bits ρ) = qs_qubits ρ
  /\

  match qs_measurement ρ with
  | Some result =>
      List.length result = qs_qubits ρ
  | None =>
      True
  end.

(*************************************************************)
(* State Length Invariant                                    *)
(*************************************************************)

Lemma InitialState_length :

forall n,

List.length (qs_bits (InitialState n))
=
n.

Proof.
  intro n.
  simpl.
  apply length_all_zeros.
Qed.

(*************************************************************)
(* State Equality                                            *)
(*************************************************************)

Definition StateEq
           (ρ σ : QuantumState)
           : Prop :=

ρ = σ.

Notation "ρ ≈ σ" :=
(StateEq ρ σ)
(at level 70).

(*************************************************************)
(* Equality Properties                                       *)
(*************************************************************)

Lemma StateEq_refl :
  forall ρ,
    ρ ≈ ρ.
Proof.
  intros ρ.
  unfold StateEq.
  reflexivity.
Qed.

Lemma StateEq_sym :
  forall ρ σ,
    ρ ≈ σ ->
    σ ≈ ρ.
Proof.
  intros ρ σ H.
  unfold StateEq in *.
  symmetry.
  exact H.
Qed.

Lemma StateEq_trans :
  forall ρ σ τ,
    ρ ≈ σ ->
    σ ≈ τ ->
    ρ ≈ τ.
Proof.
  intros ρ σ τ H1 H2.
  unfold StateEq in *.
  transitivity σ.
  - exact H1.
  - exact H2.
Qed.