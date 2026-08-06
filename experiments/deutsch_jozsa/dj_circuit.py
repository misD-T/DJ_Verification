"""
Deutsch-Jozsa semantic execution model.

This module combines:

1. PennyLane quantum execution
2. Semantic execution tracing

The execution order mirrors the Rocq framework:

    InitialState
        |
        v
    Hadamard
        |
        v
    OracleOperator
        |
        v
    Hadamard
        |
        v
    MeasurementOperator


The semantic state records the abstract execution,
while PennyLane performs the actual quantum simulation.
"""


import pennylane as qml
import numpy as np

from ..semantic import (
    InitialState,
    HadamardOperator,
    OracleOperator,
    MeasurementOperator,
    Measure,
    ExecutionStatus
)


from .dj_oracles import (
    dj_function,
    create_oracle
)

# -------------------------------------------------
# HELPER
# -------------------------------------------------

def most_likely_bitstring(probs):
    """
    Convert measurement probabilities into
    the most likely computational basis state.
    """

    idx = np.argmax(probs)

    n = int(np.log2(len(probs)))

    return format(
        idx,
        f"0{n}b"
    )

def U(
    oracle_type,
    target_bits
):

    f = dj_function(
        oracle_type,
        target_bits,
        verbose=False
    )

    ancilla = target_bits


    for x in range(2 ** target_bits):

        if f[x] == 1:

            bitstring = format(
                x,
                f"0{target_bits}b"
            )


            controls = [
                int(bit)
                for bit in bitstring
            ]


            qml.ctrl(
                qml.X,
                control=list(range(target_bits)),
                control_values=controls
            )(
                wires=ancilla
            )

# -------------------------------------------------
# PENNYLANE ORACLE IMPLEMENTATION
#
# This remains algorithm-specific.
#
# The semantic OracleOperator only records:
#
#     QuantumState -> QuantumState
#
# while this function performs:
#
#     |x>|y> -> |x>|y xor f(x)>
#
# -------------------------------------------------

def ApplyDJOracle(
    oracle_type,
    target_bits
):

    f = dj_function(
        oracle_type,
        target_bits
    )


    ancilla = target_bits


    for x in range(
        2 ** target_bits
    ):


        if f[x] == 1:


            bitstring = (
                f"{x:0{target_bits}b}"
            )


            controls = [
                int(bit)
                for bit in bitstring
            ]


            qml.ctrl(
                qml.X,
                control=list(
                    range(target_bits)
                ),
                control_values=controls

            )(wires=ancilla)



# -------------------------------------------------
# PENNYLANE BACKEND EXECUTION
#
# Physical quantum execution only.
#
# This corresponds to the actual circuit evaluation.
# The semantic framework is applied separately below.
#
# -------------------------------------------------

def make_backend(n_target_bits):

    n_wires = n_target_bits + 1

    dev = qml.device(
        "default.qubit",
        wires=n_wires
    )

    @qml.qnode(dev)
    def deutsch_jozsa_backend(oracle_type):

        qml.PauliX(
            wires=n_target_bits
        )

        for wire in range(n_wires):
            qml.Hadamard(wires=wire)

        U(
            oracle_type,
            n_target_bits
        )

        for wire in range(n_target_bits):
            qml.Hadamard(wires=wire)

        return qml.probs(
            wires=range(n_target_bits)
        )

    return deutsch_jozsa_backend

# -------------------------------------------------
# SEMANTIC EXECUTION
#
# Rocq equivalent:
#
# InitialState
# -> Hadamard
# -> OracleOperator
# -> Hadamard
# -> MeasurementOperator
#
# -------------------------------------------------

def ExecuteDJ(oracle_type, n_target_bits):

    """
    Semantic Deutsch–Jozsa execution.

    Executes the semantic operators defined by the
    verification framework while using PennyLane
    as the numerical backend.
    """


    # -------------------------------------------------
    # Initial Semantic State
    # -------------------------------------------------

    state = InitialState(
        n_target_bits + 1
    )


    # -------------------------------------------------
    # Physical execution
    # -------------------------------------------------

    backend = make_backend(
        n_target_bits
    )

    probs = backend(
        oracle_type
    )


    # -------------------------------------------------
    # Semantic execution trace
    # -------------------------------------------------

    state.add_history(
        "AncillaPreparation"
    )


    # First Hadamard

    state = HadamardOperator(
        state
    )


    # Oracle

    oracle = create_oracle(
        oracle_type,
        n_target_bits
    )


    state = OracleOperator(
        state,
        oracle
    )


    # Second Hadamard

    state = HadamardOperator(
        state
    )


    # -------------------------------------------------
    # Measurement
    # -------------------------------------------------

    output = most_likely_bitstring(
        probs
    )


    state.set_measurement(
        output
    )


    state.amplitudes = probs


    state = MeasurementOperator(
        state
    )


    return probs, state