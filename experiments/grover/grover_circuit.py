"""
Semantic Grover circuit.

Corresponds to the Rocq Grover execution model:

InitialState
    |
    H
    |
Oracle
    |
Diffusion
    |
Measurement

This module connects the Grover algorithm layer
with the reusable semantic framework.
"""


from ..semantic.quantum_state import (
    InitialState,
    UniformSuperposition
)

from ..semantic.operators import (
    HadamardOperator,
    OracleOperator,
    DiffusionOperator,
    MeasurementOperator
)




# -------------------------------------------------
# Single Grover iteration
# -------------------------------------------------

def GroverIteration(
    state,
    oracle
):
    """
    Apply one semantic Grover iteration.

    A Grover iteration consists of:

        Oracle
            |
            v
        Diffusion

    The initial Hadamard transformation is applied
    once by GroverCircuit() to create the uniform
    superposition.
    """

    state = OracleOperator(
        state,
        oracle
    )

    state = DiffusionOperator(
        state
    )

    return state



# -------------------------------------------------
# Complete Grover execution
# -------------------------------------------------

def GroverCircuit(
    qubits,
    oracle,
    iterations
):
    """
    Execute semantic Grover search.

    Semantic execution:

        InitialState
            |
            H
            |
        UniformSuperposition
            |
        +--- GroverIteration ---+
        |       Oracle          |
        |          |             |
        |      Diffusion         |
        |          |             |
        +----------+-------------+
            |
        Measurement
    """

    state = InitialState(
        qubits
    )

    # -------------------------------------------------
    # Create initial uniform superposition
    # -------------------------------------------------

    state = HadamardOperator(
        state
    )

    # -------------------------------------------------
    # Grover iterations
    # -------------------------------------------------

    for _ in range(
        iterations
    ):

        state = GroverIteration(
            state,
            oracle
        )

    # -------------------------------------------------
    # Measurement
    # -------------------------------------------------

    state = MeasurementOperator(
        state
    )

    return state
