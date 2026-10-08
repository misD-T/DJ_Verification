"""
dj_fault_experiment.py

Fault-detection experiment for Deutsch-Jozsa.

This experiment mirrors the deliberately faulty semantic
implementation used in the Rocq development.

Rocq:
    BadDJOracleOperator
        -> qs_oracle := None

Python:
    BadDJOracleOperator
        -> oracle information is not preserved

The purpose is to demonstrate that the formal verification
framework can distinguish a correct semantic execution from
one that violates a specified correctness property.

PennyLane is not used here to reproduce the formal proof.
The executable Python experiment demonstrates the corresponding
semantic fault in an executable setting.
"""

from experiments.util.result_writer import save_results_csv

from ..semantic.quantum_state import InitialState
from ..semantic.operators import (
    HadamardOperator,
    OracleOperator,
    MeasurementOperator,
)
from ..semantic.execution_status import ExecutionStatus

from .dj_oracles import create_oracle


# ============================================================
# Faulty semantic operator
# ============================================================

def BadDJOracleOperator(state, oracle):
    """
    Deliberately faulty oracle operator.

    This mirrors the Rocq definition:

        BadDJOracleOperator f :=
        fun ρ =>
        {|
          ...
          qs_oracle := None;
          ...
        |}

    The oracle is therefore not preserved in the resulting
    semantic state.
    """

    state.oracle = None
    state.history.append("BadOracle")

    return state


# ============================================================
# Faulty Deutsch-Jozsa execution
# ============================================================

def BadDJCircuit(qubits, oracle):
    """
    Execute the deliberately faulty Deutsch-Jozsa semantics.

    The intended semantic structure is:

        InitialState
            |
            H
            |
         Oracle
            |
            H
            |
        Measurement

    The oracle step is replaced by BadDJOracleOperator.
    """

    state = InitialState(qubits)

    # First Hadamard
    state = HadamardOperator(state)

    # Deliberately faulty oracle
    state = BadDJOracleOperator(state, oracle)

    # Second Hadamard
    state = HadamardOperator(state)

    # Measurement
    state = MeasurementOperator(state)

    return state


# ============================================================
# Fault property
# ============================================================

def oracle_preserved(state, oracle):
    """
    Check the same semantic property used by the Rocq model:

        qs_oracle = Some f

    In the Python abstraction this corresponds to the oracle
    information being present after execution.
    """

    return state.oracle is not None


# ============================================================
# Experiment
# ============================================================

def run_fault_experiment():
    qubits = 5

    # A simple valid constant oracle.
    oracle = create_oracle(
        "constant_zero",
        qubits
    )

    print("=" * 60)
    print("DEUTSCH-JOZSA FAULT-DETECTION EXPERIMENT")
    print("=" * 60)

    print("\nOracle:")
    print("Constant-zero oracle")

    # --------------------------------------------------------
    # Correct semantic execution
    # --------------------------------------------------------

    correct_state = InitialState(qubits)

    correct_state = HadamardOperator(correct_state)
    correct_state = OracleOperator(
        correct_state,
        oracle
    )
    correct_state = HadamardOperator(correct_state)
    correct_state = MeasurementOperator(correct_state)

    correct_verified = oracle_preserved(
        correct_state,
        oracle
    )

    print("\nCorrect implementation")
    print("-" * 60)
    print("Oracle preserved:", correct_verified)
    print("Execution status:", correct_state.status)
    print("Semantic trace:", correct_state.history)

    # --------------------------------------------------------
    # Faulty semantic execution
    # --------------------------------------------------------

    faulty_state = BadDJCircuit(
        qubits,
        oracle
    )

    faulty_verified = oracle_preserved(
        faulty_state,
        oracle
    )

    print("\nFaulty implementation")
    print("-" * 60)
    print("Oracle preserved:", faulty_verified)
    print("Execution status:", faulty_state.status)
    print("Semantic trace:", faulty_state.history)

    # --------------------------------------------------------
    # Final result
    # --------------------------------------------------------

    print("\nVerification result")
    print("=" * 60)

    if correct_verified:
        print("Correct implementation: PASS")
    else:
        print("Correct implementation: FAIL")

    if not faulty_verified:
        print("Faulty implementation: REJECTED")
    else:
        print("Faulty implementation: NOT DETECTED")

    print("=" * 60)

    # --------------------------------------------------------
    # Save results to CSV
    # --------------------------------------------------------

    results = [
        {
            "implementation": "correct",
            "oracle": "constant_zero",
            "qubits": qubits,
            "oracle_preserved": correct_verified,
            "execution_status": correct_state.status,
            "semantic_trace": " -> ".join(correct_state.history),
            "verification_result": "PASS" if correct_verified else "FAIL"
        },
        {
            "implementation": "faulty",
            "oracle": "constant_zero",
            "qubits": qubits,
            "oracle_preserved": faulty_verified,
            "execution_status": faulty_state.status,
            "semantic_trace": " -> ".join(faulty_state.history),
            "verification_result": (
                "REJECTED"
                if not faulty_verified
                else "NOT DETECTED"
            )
        }
    ]

    save_results_csv(
        "dj_fault_detection.csv",
        results
    )


if __name__ == "__main__":
    run_fault_experiment()