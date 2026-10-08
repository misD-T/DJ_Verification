(*************************************************************)
(* Formal Verification and Fault Detection Report             *)
(*************************************************************)

Require Import Grover.GroverProofs.
Require Import Grover.GroverFaults.
Require Import Grover.GroverFaultTests.

Require Import DJ.DJProofs.
Require Import DJ.Tests.DJFaultTests.


(*************************************************************)
(* Deutsch-Jozsa: HH verification                            *)
(*************************************************************)

Print DJ_constant_HH_verified.
Print DJ_balanced_HH_verified.

Print Assumptions DJ_constant_HH_verified.
Print Assumptions DJ_balanced_HH_verified.


(*************************************************************)
(* Deutsch-Jozsa: QDL verification                           *)
(*************************************************************)

Print DJ_constant_QDL_verified.
Print DJ_balanced_QDL_verified.

Print Assumptions DJ_constant_QDL_verified.
Print Assumptions DJ_balanced_QDL_verified.


(*************************************************************)
(* Deutsch-Jozsa: concrete oracle correctness                *)
(*************************************************************)

Print constant_zero_verified.
Print constant_one_verified.

Print first_bit_verified.
Print parity_verified.
Print full_parity_verified.
Print affine_verified.
Print xor_two_bits_verified.
Print and_xor_verified.
Print example_balanced_verified.

Print Assumptions constant_zero_verified.
Print Assumptions first_bit_verified.
Print Assumptions parity_verified.
Print Assumptions affine_verified.
Print Assumptions xor_two_bits_verified.
Print Assumptions and_xor_verified.


(*************************************************************)
(* Deutsch-Jozsa: invalid promise rejection                  *)
(*************************************************************)

Print invalid_oracle_not_correct.
Print invalid_oracles_not_verified.

Print Assumptions invalid_oracle_not_correct.
Print Assumptions invalid_oracles_not_verified.


(*************************************************************)
(* Deutsch-Jozsa: soundness and completeness                 *)
(*************************************************************)

Print DJ_soundness.
Print DJ_completeness.

Print Assumptions DJ_soundness.
Print Assumptions DJ_completeness.


(*************************************************************)
(* Grover: correct implementation                            *)
(*************************************************************)

Print Grover_HH_verified.
Print Grover_QDL_verified.
Print correct_grover_verifies.

Print Assumptions Grover_HH_verified.
Print Assumptions Grover_QDL_verified.
Print Assumptions correct_grover_verifies.


(*************************************************************)
(* Grover: faulty implementation                             *)
(*************************************************************)

Print faulty_grover_rejected.

Print Assumptions faulty_grover_rejected.
