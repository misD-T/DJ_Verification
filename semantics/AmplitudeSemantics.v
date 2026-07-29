(*************************************************************)
(* Amplitude Semantic Utilities                              *)
(*************************************************************)

From Coq Require Import List Bool Arith Reals String Psatz.

Import ListNotations.

Open Scope string_scope.
Open Scope R_scope.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.
Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

(*************************************************************)
(* Qubit Preservation                                        *)
(*************************************************************)
Definition PreservesQubits
           (U : QuantumOperator)
           : Prop :=

forall ρ,

qs_qubits (U ρ)
=
qs_qubits ρ.

(*************************************************************)
(* Oracle Phase Flip                                         *)
(*************************************************************)

Definition PhaseFlip
           (f : OracleInstance)
           (amps : AmplitudeState)
           : AmplitudeState :=

fun x =>

if oracle_function f x

then -(amps x)

else amps x.

(*************************************************************)
(* Basis State Enumeration                                  *)
(*************************************************************)

Fixpoint BasisStates
         (n : nat)
         : list BitString :=

match n with

| 0 =>
    [[]]

| S n' =>
    let previous := BasisStates n' in

    (AppendBit false previous)
    ++
    (AppendBit true previous)

end.

(*************************************************************)
(* Amplitude Summation                                      *)
(*************************************************************)

Fixpoint SumAmplitudes
        (amps : AmplitudeState)
        (states : list BitString)
        : R :=

match states with

| [] =>
    0%R

| s :: rest =>
    amps s + SumAmplitudes amps rest

end.

(*************************************************************)
(* Mean Amplitude                                            *)
(*************************************************************)

Definition MeanAmplitude
        (amps : AmplitudeState)
        (n:nat)
        : R :=

(SumAmplitudes amps (BasisStates n))
/
(INR (2^n)).

(*************************************************************)
(* Diffusion Transformation                                  *)
(*************************************************************)

Definition DiffusionTransform
           (amps : AmplitudeState)
           (n : nat)
           : AmplitudeState :=

fun x =>

(2%R * MeanAmplitude amps n) - amps x.

(*************************************************************)
(* Reflection About Mean                                     *)
(*************************************************************)

Definition ReflectAboutMean
         (amps : AmplitudeState)
         (n : nat)
         : AmplitudeState :=

DiffusionTransform amps n.

(*************************************************************)
(* Amplitude Observation                                     *)
(*************************************************************)

Definition AmplitudeOf
           (amps : AmplitudeState)
           (bs : BitString)
           : R :=

amps bs.

Definition ProbabilityOf
           (amps : AmplitudeState)
           (bs : BitString)
           : R :=

let a := amps bs in

a * a.

Definition MeasurementProbability
           (amps : AmplitudeState)
           (bs : BitString)
           : R :=

ProbabilityOf amps bs.

Fixpoint TotalProbabilityAux
         (amps : AmplitudeState)
         (states : list BitString)
         : R :=

match states with

| [] => 0%R

| s :: tl =>

    ProbabilityOf amps s
    +
    TotalProbabilityAux amps tl

end.

Definition TotalProbability
           (amps : AmplitudeState)
           (n : nat)
           : R :=

TotalProbabilityAux amps (BasisStates n).

Definition MostLikelyState
           (amps : AmplitudeState)
           (n : nat)
           : BitString :=

all_zeros n.

(*************************************************************)
(* Successful Grover State                                   *)
(*************************************************************)

Definition IsMarkedState
           (f : OracleInstance)
           (bs : BitString)
           : Prop :=

oracle_function f bs = true.

Definition GroverSuccessProbability
           (amps : AmplitudeState)
           (f : OracleInstance)
           (n : nat)
           : R :=

TotalProbabilityAux
 amps
 (filter
    (oracle_function f)
    (BasisStates n)).

(*************************************************************)
(* Observation Lemmas                                        *)
(*************************************************************)

Lemma Probability_nonnegative :

forall amps bs,

0 <= ProbabilityOf amps bs.

Proof.

    intros.

    unfold ProbabilityOf.

    nra.

Qed.

 Lemma TotalProbability_nonnegative :

forall amps n,

0 <= TotalProbability amps n.

Proof.

Admitted. (*Will be changed later when amp model is richer*)

Lemma MeasurementProbability_equals_probability :

forall amps bs,

MeasurementProbability amps bs =
ProbabilityOf amps bs.

Proof.

    intros.

    reflexivity.

Qed.

(*************************************************************)
(* Basis States Lemmas                                       *)
(*************************************************************)

Lemma BasisStates_two :
BasisStates 2 =
[
 [false;false];
 [false;true];
 [true;false];
 [true;true]
].
Proof.
        reflexivity.
Qed.

Lemma BasisStates_length :
forall n,

List.length (BasisStates n)
=
Nat.pow 2 n.

Proof.
Admitted.

Lemma UniformAmplitude_constant :

forall n x y,

UniformAmplitudeState n x =
UniformAmplitudeState n y.

Proof.

    intros.

    reflexivity.

Qed.
