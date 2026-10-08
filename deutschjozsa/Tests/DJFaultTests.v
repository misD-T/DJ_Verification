From Coq Require Import Strings.String.
Require Import Quantum.QuantumState.
Require Import Quantum.QuantumOperators.

Require Import DJ.DJ.
Require Import DJ.DJProofs.

Require Import forms.Oracles.Oracles.


Definition BadDJOracleOperator
           (f : OracleInstance)
           : QuantumOperator :=
fun ρ =>
{|
  qs_bits := qs_bits ρ;
  qs_amplitudes := qs_amplitudes ρ;
  qs_target := qs_target ρ;
  qs_qubits := qs_qubits ρ;
  qs_oracle := None;
  qs_measurement := qs_measurement ρ;
  qs_history := "BadOracle" :: qs_history ρ;
  qs_status := qs_status ρ;
  qs_symbolic_output := qs_symbolic_output ρ
|}.


Theorem BadDJ_oracle_preservation_fails :
  forall f ρ,
    qs_oracle (BadDJOracleOperator f ρ) <> Some f.
Proof.
  intros f ρ.
  simpl.
  discriminate.
Qed.