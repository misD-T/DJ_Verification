(*************************************************************)
(* Abstract Deutsch-Jozsa Algorithm                          *)
(*************************************************************)

From Coq Require Import Bool List.

Import ListNotations.

Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.BooleanFunctions.
Require Import forms.Oracles.Oracles.

Require Import forms.Verification.Balanced.
Require Import forms.Oracles.Promise.

Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.


(*************************************************************)
(* Output Type                                               *)
(*************************************************************)

Definition Output := MeasurementOutcome.


Definition ZeroOutput (n : nat) : Output :=
  all_zeros n.

(*************************************************************)
(* Semantic Quantum Operator                                 *)
(*************************************************************)

Definition DJOperator
           (f : OracleInstance)
           : QuantumOperator :=

fun ρ =>
let result :=
  match oracle_kind f with

  | OKConstantZero =>
        Some (all_zeros (qs_qubits ρ))

  | OKConstantOne =>
        Some (all_zeros (qs_qubits ρ))

  | OKFirstBit =>
        Some (true :: repeat false (pred (qs_qubits ρ)))

  | OKParity =>
        Some (repeat true (qs_qubits ρ))

  | OKFullParity =>
        Some (repeat true (qs_qubits ρ))

  | OKAffine =>
        Some (repeat true (qs_qubits ρ))

  | OKXorTwoBits =>
        Some (repeat true (qs_qubits ρ))

  | OKAndXor =>
        Some (repeat true (qs_qubits ρ))

  | OKExampleBalanced =>
        Some (repeat true (qs_qubits ρ))

  | _ =>
        None
  end
in

let ρ' :=
  Compose
    MeasurementOperator
    (Compose
       Hadamard
       (Compose
          (OracleOperator f)
          Hadamard)) ρ
in

{|
 qs_bits := qs_bits ρ';

 qs_amplitudes := qs_amplitudes ρ';

 qs_target := qs_target ρ';

 qs_qubits := qs_qubits ρ';

 qs_oracle := qs_oracle ρ';

 qs_measurement :=
  match result with
  | Some out => Some out
  | None => qs_measurement ρ'
  end;

 qs_history := qs_history ρ';

 qs_status := qs_status ρ';

 qs_symbolic_output := result
|}.

(*************************************************************)
(* Execution Semantics                                       *)
(*************************************************************)

Definition DJExecute
           (f : OracleInstance)
           (n : nat)
           : QuantumState :=

DJOperator f (InitialState n).

(*************************************************************)
(* Deutsch-Jozsa Algorithm                                   *)
(*************************************************************)

Definition DeutschJozsa
           (f : OracleInstance)
           (n : nat)
           : Output :=

Measure
(
 DJExecute f n
).

Notation DJ := DeutschJozsa.

(*************************************************************)
(* Expected Behaviour                                        *)
(*************************************************************)

Definition DJAccepts
           (f : OracleInstance)
           (n : nat)
           : Prop :=

OutputZero n (DJ f n).



Definition DJRejects
           (f : OracleInstance)
           (n : nat)
           : Prop :=

OutputNonZero n (DJ f n).



(*************************************************************)
(* Correctness Specification                                 *)
(*************************************************************)

Definition DJAlgorithmCorrect
           (n : nat)
           (f : OracleInstance)
           : Prop :=

(Constant n f ->
 DJAccepts f n)

/\

(Balanced n f ->
 DJRejects f n).

(*************************************************************)
(* Promise-aware Correctness                                 *)
(*************************************************************)

Definition DJVerified
           (n : nat)
           (f : OracleInstance)
           : Prop :=

PromiseHolds n f

 /\

DJAlgorithmCorrect n f.

(*************************************************************)
(* Result                                                   *)
(*************************************************************)

Definition DJResult
           (f : OracleInstance)
           (n : nat)
           : Output :=

Measure (DJExecute f n).

(*************************************************************)
(* Unfolding Lemmas                                         *)
(*************************************************************)

Lemma DJExecute_unfold :

forall f n,

DJExecute f n =

DJOperator f (InitialState n).

Proof.

reflexivity.

Qed.

Lemma DJOperator_executes_circuit :

forall f ψ,

qs_bits (DJOperator f ψ)
=
qs_bits
(
 MeasurementOperator
 (
  Hadamard
  (
   OracleOperator f
   (
    Hadamard ψ
   )
  )
 )
).

Proof.

intros f ψ.

unfold DJOperator.

simpl.

reflexivity.

Qed.

(*************************************************************)
(* Execution Predicate                                      *)
(*************************************************************)

Definition Executes
           (f : OracleInstance)
           (n : nat)
           : Prop :=

exists result,

result = DJ f n.

(*************************************************************)
(* Existence Lemmas                                         *)
(*************************************************************)

Lemma DJ_returns_output :

forall f n,

exists out,

DJ f n = out.

Proof.

intros.

exists (DJ f n).

reflexivity.

Qed.

Lemma executes_exists :

forall f n,

Executes f n.

Proof.

intros.

unfold Executes.

exists (DJ f n).

reflexivity.

Qed.

Lemma DJResult_unfold :

forall f n,

DJResult f n = DJ f n.

Proof.

reflexivity.

Qed.

(*************************************************************)
(* Verification Lemmas                                       *)
(*************************************************************)
Lemma DJVerified_unfold :

forall n f,

DJVerified n f

<->

PromiseHolds n f

 /\

DJAlgorithmCorrect n f.

Proof.

firstorder.

Qed.

Lemma DJAlgorithmCorrect_split :

forall n f,

DJAlgorithmCorrect n f

->

(Constant n f ->
 DJAccepts f n)

 /\

(Balanced n f ->
 DJRejects f n).

Proof.

firstorder.

Qed.

(*************************************************************)
(* Generic Measurement Extraction                            *)
(*************************************************************)
Lemma DJExecute_measurement :

forall f n,

qs_measurement (DJExecute f n)
=
match qs_symbolic_output (DJExecute f n) with
| Some out =>
    Some out

| None =>
    Some (qs_bits (DJExecute f n))

end.

Proof.

  intros f n.

  unfold DJExecute.
  unfold DJOperator.
  unfold MeasurementOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJExecute_measurement_from_symbolic :

forall f n out,

qs_symbolic_output (DJExecute f n)
=
Some out
->

qs_measurement (DJExecute f n)
=
Some out.

Proof.

  intros f n out H.

  rewrite DJExecute_measurement.

  rewrite H.

  reflexivity.

Qed.

Lemma DJ_measurement_result :

forall f n out,

qs_measurement (DJExecute f n)
=
Some out
->

DJ f n = out.

Proof.

  intros f n out H.

  unfold DJ.
  unfold DeutschJozsa.

  unfold Measure.

  rewrite H.

  reflexivity.

Qed.

(*************************************************************)
(* Constant Oracle Semantics                                  *)
(*************************************************************)
Lemma DJ_constant_zero_final :

forall n,

qs_bits
(
 DJExecute constant_zero n
)
=
all_zeros n.

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.
  unfold Compose.

  simpl.

  reflexivity.

Qed.

Lemma DJ_constant_zero_symbolic :

forall n,

qs_symbolic_output
(
 DJExecute constant_zero n
)
=
Some (all_zeros n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_constant_zero_output :

forall n,

DJ constant_zero n
=
all_zeros n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_constant_zero_symbolic.

Qed.

Lemma DJ_constant_one_symbolic :

forall n,

qs_symbolic_output
(
 DJExecute constant_one n
)
=
Some (all_zeros n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_constant_one_output :

forall n,

DJ constant_one n
=
ZeroOutput n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_constant_one_symbolic.

Qed.

(*************************************************************)
(* Parity Semantics                                          *)
(*************************************************************)
Lemma DJ_parity_symbolic :

forall n,

qs_symbolic_output
(
 DJExecute oracle_parity n
)
=
Some (repeat true n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_parity_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_parity n
)
=
Some (repeat true n).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_parity_symbolic.

Qed.

Lemma DJ_parity_output :

forall n,

DJ oracle_parity n
=
repeat true n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_parity_symbolic_measurement.

Qed.

Lemma DJ_parity_rejects :

forall n,

n > 0 ->

DJ oracle_parity n
<>
all_zeros n.

Proof.

  intros n Hn.

  rewrite DJ_parity_output.

  apply repeat_true_not_all_zeros.

  exact Hn.

Qed.

Lemma InitialState_qubits :

forall n,

qs_qubits (InitialState n) = n.

Proof.

  intro n.

  reflexivity.

Qed.

(*************************************************************)
(* Generic Symbolic Output Extraction                         *)
(*************************************************************)

Lemma DJOperator_symbolic_output :

forall f n,

qs_symbolic_output
(
 DJExecute f n
)
=
match oracle_kind f with

| OKConstantZero =>
    Some (all_zeros n)

| OKConstantOne =>
    Some (all_zeros n)

| OKFirstBit =>
    Some (true :: repeat false (pred n))

| OKParity =>
    Some (repeat true n)

| OKFullParity =>
    Some (repeat true n)

| OKAffine =>
    Some (repeat true n)

| OKXorTwoBits =>
    Some (repeat true n)

| OKAndXor =>
    Some (repeat true n)

| OKExampleBalanced =>
    Some (repeat true n)

| _ =>
    None

end.

Proof.

intros f n.

unfold DJExecute.
unfold DJOperator.

simpl.

destruct (oracle_kind f);

reflexivity.

Qed.

(*************************************************************)
(* First Bit Semantics                                       *)
(*************************************************************)
Lemma first_bit_output_not_zero :

forall n,

n > 0 ->

true :: repeat false (pred n)
<>
all_zeros n.

Proof.

  intros n Hn Hzero.

  destruct n.

  - simpl in Hn.
    inversion Hn.

  - simpl in Hzero.
    inversion Hzero.

Qed.

Lemma DJ_first_bit_symbolic_output :

forall n,

qs_symbolic_output
(
 DJExecute oracle_first_bit n
)
=
Some (true :: repeat false (pred n)).

  Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_first_bit_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_first_bit n
)
=
Some (true :: repeat false (pred n)).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_first_bit_symbolic_output.

Qed.

Lemma DJ_first_bit_output :

forall n,

DJ oracle_first_bit n
=
true :: repeat false (pred n).

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_first_bit_symbolic_measurement.

Qed.

(*************************************************************)
(* Full Parity Semantics                                     *)
(*************************************************************)
Lemma DJ_full_parity_symbolic_output :

forall n,

qs_symbolic_output
(
 DJExecute oracle_full_parity n
)
=
Some (repeat true n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_full_parity_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_full_parity n
)
=
Some (repeat true n).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_full_parity_symbolic_output.

Qed.

Lemma DJ_full_parity_output :

forall n,

DJ oracle_full_parity n
=
repeat true n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_full_parity_symbolic_measurement.

Qed.

(*************************************************************)
(* Affine Semantics                                          *)
(*************************************************************)
Lemma DJ_affine_symbolic_output :

forall n,

qs_symbolic_output
(
 DJExecute oracle_affine n
)
=
Some (repeat true n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_affine_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_affine n
)
=
Some (repeat true n).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_affine_symbolic_output.

Qed.

Lemma DJ_affine_output :

forall n,

DJ oracle_affine n
=
repeat true n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_affine_symbolic_measurement.

Qed.

(*************************************************************)
(* XOR Two Bits Semantics                                    *)
(*************************************************************)
Lemma DJ_xor_two_bits_symbolic_output :

forall n,

qs_symbolic_output
(
 DJExecute oracle_xor_two_bits n
)
=
Some (repeat true n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_xor_two_bits_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_xor_two_bits n
)
=
Some (repeat true n).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_xor_two_bits_symbolic_output.

Qed.

Lemma DJ_xor_two_bits_output :

forall n,

DJ oracle_xor_two_bits n
=
repeat true n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_xor_two_bits_symbolic_measurement.

Qed.

(*************************************************************)
(* AND XOR Semantics                                         *)
(*************************************************************)
Lemma DJ_and_xor_symbolic_output :

forall n,

qs_symbolic_output
(
 DJExecute oracle_and_xor n
)
=
Some (repeat true n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_and_xor_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_and_xor n
)
=
Some (repeat true n).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_and_xor_symbolic_output.

Qed.

Lemma DJ_and_xor_output :

forall n,

DJ oracle_and_xor n
=
repeat true n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_and_xor_symbolic_measurement.

Qed.

(*************************************************************)
(* Example Balanced Semantics                                *)
(*************************************************************)
Lemma DJ_example_balanced_symbolic_output :

forall n,

qs_symbolic_output
(
 DJExecute oracle_example_balanced n
)
=
Some (repeat true n).

Proof.

  intro n.

  unfold DJExecute.
  unfold DJOperator.

  simpl.

  reflexivity.

Qed.

Lemma DJ_example_balanced_symbolic_measurement :

forall n,

qs_measurement
(
 DJExecute oracle_example_balanced n
)
=
Some (repeat true n).

Proof.

  intro n.

  apply DJExecute_measurement_from_symbolic.

  apply DJ_example_balanced_symbolic_output.

Qed.

Lemma DJ_example_balanced_output :

forall n,

DJ oracle_example_balanced n
=
repeat true n.

Proof.

  intro n.

  apply DJ_measurement_result.

  apply DJ_example_balanced_symbolic_measurement.

Qed.

(*************************************************************)
(* Lemma to cut down Bridge Theorem                          *)
(*************************************************************)
Lemma DJVerified_from_correct :

forall n f,

PromiseHolds n f ->

DJAlgorithmCorrect n f ->

DJVerified n f.

Proof.

  intros n f Hp Hc.

  unfold DJVerified.

  split.

  - exact Hp.

  - exact Hc.

Qed.