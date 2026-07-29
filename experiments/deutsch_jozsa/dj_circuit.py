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


from semantic import (
    InitialState,
    HadamardOperator,
    OracleOperator,
    MeasurementOperator,
    Measure
)


from dj_oracles import dj_function



# -------------------------------------------------
# SETTINGS
# -------------------------------------------------

n_target_bits = 5

n_wires = n_target_bits + 1



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



# -------------------------------------------------
# DEVICE
# -------------------------------------------------

dev = qml.device(
    "default.qubit",
    wires=n_wires
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
# EXECUTION
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

@qml.qnode(dev)
def ExecuteDJ(
    oracle_type
):


    # ---------------------------------------------
    # Semantic initial state
    # ---------------------------------------------

    state = InitialState(
        n_wires
    )


    state.oracle = oracle_type



    # ---------------------------------------------
    # Ancilla preparation
    #
    # |1>
    #
    # ---------------------------------------------

    qml.PauliX(
        wires=n_target_bits
    )


    state.add_history(
        "AncillaX"
    )



    # ---------------------------------------------
    # First Hadamard layer
    #
    # Semantic:
    #
    # HadamardOperator(state)
    #
    # Physical:
    #
    # qml.Hadamard
    #
    # ---------------------------------------------

    state = HadamardOperator(
        state,
        register="all"
    )


    for wire in range(
        n_wires
    ):

        qml.Hadamard(
            wires=wire
        )



    # ---------------------------------------------
    # Oracle
    #
    # Semantic:
    #
    # OracleOperator(state)
    #
    # Physical:
    #
    # ApplyDJOracle
    #
    # ---------------------------------------------

    state = OracleOperator(
        state,
        oracle_type,
        lambda bits:
            False
    )


    ApplyDJOracle(
        oracle_type,
        n_target_bits
    )



    # ---------------------------------------------
    # Second Hadamard
    #
    # Only input register
    #
    # ---------------------------------------------

    state = HadamardOperator(
        state,
        register="input"
    )


    for wire in range(
        n_target_bits
    ):

        qml.Hadamard(
            wires=wire
        )



    # ---------------------------------------------
    # Measurement
    #
    # Physical measurement is returned by PennyLane.
    #
    # Semantic state is updated afterwards.
    #
    # ---------------------------------------------

    probs = qml.probs(
        wires=range(
            n_target_bits
        )
    )


    return probs
