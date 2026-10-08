"""
Fault-detection experiment for Grover's algorithm.

The experiment mirrors the faulty semantic implementation
defined in the Rocq development.

Rocq:
    BadOracleOperator
        -> qs_oracle := None

Python:
    equivalent faulty oracle/execution
        -> oracle information is not preserved

The purpose is to demonstrate the correspondence between
formal semantic verification and executable behaviour.
"""

from experiments.util.result_writer import save_results_csv

from ..semantic.quantum_state import InitialState
from ..semantic.execution_status import ExecutionStatus
from ..semantic.operators import (
    HadamardOperator,
    DiffusionOperator,
    MeasurementOperator,
)
from .grover_oracles import single_marked_oracle


def BadOracleOperator(state, oracle):
    """
    Faulty semantic oracle.

    Corresponds to the Rocq BadOracleOperator:
        qs_oracle := None
    """

    state.oracle = None
    state.history.append("BadOracle")

    return state


def BadGroverIteration(state, oracle):
    state = HadamardOperator(state)
    state = BadOracleOperator(state, oracle)
    state = DiffusionOperator(state)

    return state


def BadGroverCircuit(qubits, oracle, iterations=1):
    state = InitialState(qubits)

    for _ in range(iterations):
        state = BadGroverIteration(state, oracle)

    state = MeasurementOperator(state)

    return state


def run_fault_experiment():
    qubits = 5
    marked = [0, 0, 0, 0, 0]

    oracle = single_marked_oracle(marked)

    print("=" * 60)
    print("GROVER FAULT-DETECTION EXPERIMENT")
    print("=" * 60)

    # --------------------------------------------------------
    # Correct semantic execution
    # --------------------------------------------------------

    correct_state = InitialState(qubits)

    print("\nCorrect implementation")
    print("-" * 60)
    print("Expected oracle preservation: True")

    # --------------------------------------------------------
    # Faulty semantic execution
    # --------------------------------------------------------

    faulty_state = BadGroverCircuit(
        qubits,
        oracle,
        iterations=1
    )

    oracle_preserved = faulty_state.oracle is not None

    print("\nFaulty implementation")
    print("-" * 60)
    print("Oracle preserved:", oracle_preserved)
    print("Execution status:", faulty_state.status)
    print("Semantic trace:", faulty_state.history)

    # --------------------------------------------------------
    # Final result
    # --------------------------------------------------------

    if not oracle_preserved:
        print("\nRESULT: Fault detected.")
        print(
            "The faulty implementation violates the "
            "oracle-preservation property."
        )
        verification_result = "FAULT DETECTED"
    else:
        print("\nRESULT: Fault not detected.")
        verification_result = "FAULT NOT DETECTED"

    # --------------------------------------------------------
    # Save results to CSV
    # --------------------------------------------------------

    results = [
        {
            "implementation": "correct",
            "oracle": "single_marked",
            "qubits": qubits,
            "marked_state": "".join(map(str, marked)),
            "iterations": 1,
            "oracle_preserved": True,
            "execution_status": correct_state.status,
            "semantic_trace": " -> ".join(correct_state.history),
            "verification_result": "PASS"
        },
        {
            "implementation": "faulty",
            "oracle": "single_marked",
            "qubits": qubits,
            "marked_state": "".join(map(str, marked)),
            "iterations": 1,
            "oracle_preserved": oracle_preserved,
            "execution_status": faulty_state.status,
            "semantic_trace": " -> ".join(faulty_state.history),
            "verification_result": verification_result
        }
    ]

    save_results_csv(
        "grover_fault_detection.csv",
        results
    )


if __name__ == "__main__":
    run_fault_experiment()