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


from ..semantic.quantum_state import InitialState
from ..semantic.operators import (
    HadamardOperator,
    OracleOperator,
    DiffusionOperator,
    MeasurementOperator
)


from ..semantic.execution_status import ExecutionStatus



# -------------------------------------------------
# Single Grover iteration
# -------------------------------------------------

def GroverIteration(
        state,
        oracle
):
    """
    Apply one semantic Grover iteration.

    Corresponds to:

        GroverIteration f

    in Rocq.
    """


    state = HadamardOperator(
        state
    )


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

    Corresponds to:

        GroverTrace
            (GroverIterations n)
            (GroverIteration f)
            (InitialState n)

    """


    state = InitialState(
        qubits
    )


    for _ in range(iterations):

        state = GroverIteration(
            state,
            oracle
        )


    state = MeasurementOperator(
        state
    )


    return state