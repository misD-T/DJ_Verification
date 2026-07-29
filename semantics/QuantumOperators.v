(*************************************************************)
(* QuantumOperator.v                                         *)
(* Generic semantic quantum operators                        *)
(*************************************************************)

From Coq Require Import List Bool String.
From Coq Require Import FunctionalExtensionality.

Import ListNotations.
Open Scope string_scope.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.
Require Import Quantum.QuantumState.


(*************************************************************)
(* Quantum Operators                                         *)
(*************************************************************)

Definition QuantumOperator :=
  QuantumState -> QuantumState.

(*************************************************************)
(* Hadamard Amplitude Transformation                         *)
(*************************************************************)
Definition HadamardTransform
           (amps : AmplitudeState)
           (n : nat)
           : AmplitudeState :=

UniformAmplitudeState n.

(*************************************************************)
(* Primitive Operators                                       *)
(*************************************************************)

Definition Hadamard :
 QuantumOperator :=
 fun ρ =>
 {|
   qs_bits := qs_bits ρ;

   qs_amplitudes :=

  match qs_amplitudes ρ with

  | None => None

  | Some amps =>

      Some
        (HadamardTransform amps (qs_qubits ρ))

  end;

   qs_target := qs_target ρ;

   qs_qubits := qs_qubits ρ;

   qs_oracle := qs_oracle ρ;

   qs_measurement := qs_measurement ρ;

   qs_history :=
      "H" :: qs_history ρ;

   qs_status :=
     match qs_status ρ with
     | Initial => AfterHadamard
     | AfterOracle => Finished
     | s => s
     end;
   qs_symbolic_output := qs_symbolic_output ρ;
 |}.

Definition OracleOperator
           (f : OracleInstance)
           : QuantumOperator :=
fun ρ =>
{|
 qs_bits := qs_bits ρ;

 qs_amplitudes := qs_amplitudes ρ;

 qs_target :=
   xorb
     (qs_target ρ)
     ((oracle_function f) (qs_bits ρ));

 qs_qubits := qs_qubits ρ;

 qs_oracle := Some f;

 qs_measurement := qs_measurement ρ;

 qs_history :=
   "Oracle" :: qs_history ρ;

 qs_status :=
     match qs_status ρ with
     | AfterHadamard => AfterOracle
     | s => s
     end;

  qs_symbolic_output := qs_symbolic_output ρ;
|}.

Definition MeasurementOperator : QuantumOperator :=
fun ρ =>
{|
  qs_bits := qs_bits ρ;

  qs_amplitudes := qs_amplitudes ρ;

  qs_target := qs_target ρ;

  qs_qubits := qs_qubits ρ;

  qs_oracle := qs_oracle ρ;

  qs_measurement :=
    match qs_symbolic_output ρ with
    | Some out => Some out
    | None => Some (qs_bits ρ)
    end;

  qs_history :=
    "Measurement" :: qs_history ρ;

  qs_status := Finished;

  qs_symbolic_output := qs_symbolic_output ρ
|}.

Definition Identity : QuantumOperator :=
 fun ρ => ρ.



(*************************************************************)
(* Measurement                                               *)
(*************************************************************)

Definition Measure :
  QuantumState -> MeasurementOutcome :=
fun ρ =>

match qs_measurement ρ with

| Some result =>
    result

| None =>
    qs_bits ρ

end.

(*************************************************************)
(* Measurement Length Preservation Lemma                     *)
(*************************************************************)

Lemma Measure_length :

forall ρ,

WellFormedState ρ ->

List.length (Measure ρ)
=
qs_qubits ρ.

Proof.

  intros ρ Hwf.

  unfold Measure.

  unfold WellFormedState in Hwf.

  destruct Hwf as [Hbits Hmeasure].

  destruct (qs_measurement ρ) as [result |].

  - (* Measurement exists *)

    simpl.

    exact Hmeasure.

  - (* No measurement *)

    simpl.

    exact Hbits.

Qed.

(*************************************************************)
(* Composition                                               *)
(*************************************************************)

Definition Compose
           (U V : QuantumOperator)
           : QuantumOperator :=
fun ρ =>
  U (V ρ).


Notation "U ∘ V" :=
  (Compose U V)
  (at level 40).

(*************************************************************)
(* Execution of Circuit                                      *)
(*************************************************************)

Definition Execute
           (ops : list QuantumOperator)
           (ρ : QuantumState)
           : QuantumState :=

fold_left
  (fun ψ U => U ψ)
  ops
  ρ.



(*************************************************************)
(* Generic Semantic Laws                                     *)
(*************************************************************)

Lemma Identity_left :

forall ρ,

Identity ρ = ρ.

Proof.
  reflexivity.
Qed.


Lemma Identity_right :

forall ρ,

Identity ρ = ρ.

Proof.
  reflexivity.
Qed.


Lemma Compose_identity_left :

forall U,

Compose Identity U = U.

Proof.

  intros.

  unfold Compose.

  extensionality ρ.

  reflexivity.

Qed.


Lemma Compose_identity_right :

forall U,

Compose U Identity = U.

Proof.

  intros.

  unfold Compose.

  extensionality ρ.

  reflexivity.

Qed.

(*************************************************************)
(* Measurement  Lemma                                        *)
(*************************************************************)
Lemma MeasurementOperator_finished :

forall ρ,

qs_status (MeasurementOperator ρ)
=
Finished.

Proof.

  intros.

  reflexivity.

Qed.


Lemma MeasurementOperator_sets_symbolic_result :

forall ρ out,

qs_symbolic_output ρ = Some out ->

qs_measurement (MeasurementOperator ρ)
=
Some out.

Proof.

  intros ρ out H.

  unfold MeasurementOperator.

  rewrite H.

  reflexivity.

Qed.


Lemma MeasurementOperator_default_result :

forall ρ,

qs_symbolic_output ρ = None ->

qs_measurement (MeasurementOperator ρ)
=
Some (qs_bits ρ).

Proof.

  intros ρ H.

  unfold MeasurementOperator.

  rewrite H.

  reflexivity.

Qed.


Lemma Measure_after_measurement_symbolic :

forall ρ out,

qs_symbolic_output ρ = Some out ->

Measure (MeasurementOperator ρ)
=
out.

Proof.

  intros ρ out H.

  unfold Measure.

  unfold MeasurementOperator.

  rewrite H.

  simpl.

  reflexivity.

Qed.


Lemma Measure_after_measurement_default :

forall ρ,

qs_symbolic_output ρ = None ->

Measure (MeasurementOperator ρ)
=
qs_bits ρ.

Proof.

  intros ρ H.

  unfold Measure.

  unfold MeasurementOperator.

  rewrite H.

  simpl.

  reflexivity.

Qed.

Lemma Measure_uses_measurement_result :

forall ρ out,

qs_measurement ρ = Some out ->

Measure ρ = out.

Proof.

  intros ρ out H.

  unfold Measure.

  rewrite H.

  reflexivity.

Qed.

(*************************************************************)
(* Hadamard Lemma                                            *)
(*************************************************************)
Lemma Hadamard_preserves_bits :

forall ρ,

qs_bits (Hadamard ρ)
=
qs_bits ρ.

Proof.

  intros.

  reflexivity.

Qed.


Lemma Hadamard_preserves_qubits :

forall ρ,

qs_qubits (Hadamard ρ)
=
qs_qubits ρ.

Proof.

  intros.

  reflexivity.

Qed.


Lemma Hadamard_updates_history :

forall ρ,

qs_history (Hadamard ρ)
=
"H" :: qs_history ρ.

Proof.

  intros.

  reflexivity.

Qed.


Lemma Hadamard_preserves_symbolic_output :

forall ρ,

qs_symbolic_output (Hadamard ρ)
=
qs_symbolic_output ρ.

Proof.

  intros.

  reflexivity.

Qed.

(*************************************************************)
(* Oracle  Lemma                                             *)
(*************************************************************)
Lemma Oracle_sets_oracle_metadata :

forall f ρ,

qs_oracle (OracleOperator f ρ)
=
Some f.

Proof.

  intros.

  reflexivity.

Qed.

Lemma Oracle_preserves_qubits :

forall f ρ,

qs_qubits (OracleOperator f ρ)
=
qs_qubits ρ.

Proof.

  intros.

  reflexivity.

Qed.

Lemma Oracle_updates_history :

forall f ρ,

qs_history (OracleOperator f ρ)
=
"Oracle" :: qs_history ρ.

Proof.

  intros.

  reflexivity.

Qed.

Lemma Oracle_preserves_symbolic_output :

forall f ρ,

qs_symbolic_output (OracleOperator f ρ)
=
qs_symbolic_output ρ.

Proof.

  intros.

  reflexivity.

Qed.

(*************************************************************)
(* Measurement  Lemma                                        *)
(*************************************************************)
Lemma MeasurementOperator_updates_history :

forall ρ,

qs_history (MeasurementOperator ρ)
=
"Measurement" :: qs_history ρ.

Proof.

  intros.

  reflexivity.

Qed.


Lemma MeasurementOperator_preserves_oracle :

forall ρ,

qs_oracle (MeasurementOperator ρ)
=
qs_oracle ρ.

Proof.

  intros.

  reflexivity.

Qed.


Lemma MeasurementOperator_preserves_qubits :

forall ρ,

qs_qubits (MeasurementOperator ρ)
=
qs_qubits ρ.

Proof.

  intros.

  reflexivity.

Qed.

(*************************************************************)
(* Length Preservation  Lemma                                *)
(*************************************************************)
Lemma Hadamard_preserves_length :

forall ρ,

List.length (qs_bits (Hadamard ρ))
=
List.length (qs_bits ρ).

Proof.

  intros.

  reflexivity.

Qed.


Lemma Oracle_preserves_length :

forall f ρ,

List.length (qs_bits (OracleOperator f ρ))
=
List.length (qs_bits ρ).

Proof.

  intros.

  reflexivity.

Qed.

(*************************************************************)
(* Execution Status  Lemma                                   *)
(*************************************************************)
Lemma Hadamard_sets_status_initial :

forall ρ,

qs_status ρ = Initial ->

qs_status (Hadamard ρ)
=
AfterHadamard.

Proof.

  intros.

  unfold Hadamard.

  simpl.

  rewrite H.

  reflexivity.

Qed.



Lemma Oracle_sets_status :

forall f ρ,

qs_status ρ = AfterHadamard ->

qs_status (OracleOperator f ρ)
=
AfterOracle.

Proof.

  intros.

  unfold OracleOperator.

  simpl.

  rewrite H.

  reflexivity.

Qed.



Lemma Hadamard_finishes :

forall ρ,

qs_status ρ = AfterOracle ->

qs_status (Hadamard ρ)
=
Finished.

Proof.

  intros.

  unfold Hadamard.

  simpl.

  rewrite H.

  reflexivity.

Qed.

(*************************************************************)
(* Initial State  Lemma                                      *)
(*************************************************************)
Lemma Measure_initial :

forall n,

Measure (InitialState n)
=
all_zeros n.

Proof.

  intros.

  reflexivity.

Qed.

Lemma Hadamard_initial_state :

forall n,

qs_bits (Hadamard (InitialState n))
=
all_zeros n.

Proof.

  intros.

  reflexivity.

Qed.