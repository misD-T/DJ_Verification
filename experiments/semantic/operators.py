"""
Semantic quantum operators.

This module defines reusable semantic operators that transform
QuantumState objects.

The operators correspond to the abstract transition rules
defined in the Rocq verification framework.

Each operator has the form:

    QuantumState -> QuantumState

The actual quantum circuit execution is handled separately by
the backend implementation (e.g. PennyLane).
"""

import numpy as np
from .quantum_state import QuantumState
from .execution_status import ExecutionStatus
from .transforms import HadamardTransform



# -------------------------------------------------
# Hadamard Operator
#
# Corresponds to Rocq:
#
# Definition Hadamard :
#     QuantumOperator := ...
#
# Behaviour:
#
# Initial
#    |
#    v
# AfterHadamard
#
# AfterOracle
#    |
#    v
# Finished
#
# -------------------------------------------------

def HadamardOperator(
    state: QuantumState,
    register: str = "all"
) -> QuantumState:
    """
    Apply semantic Hadamard transformation.

    The transformation is applied to the complete
    amplitude representation of the state.

    For n qubits:

        H^{⊗n} |ψ>

    is computed by HadamardTransform().
    """

    if state.amplitudes is not None:

        state.amplitudes = HadamardTransform(
            state.amplitudes,
            state.qubits
        )

    state.add_history(
        "H"
    )

    if state.status == ExecutionStatus.INITIAL:

        state.update_status(
            ExecutionStatus.AFTER_HADAMARD
        )

    elif state.status == ExecutionStatus.AFTER_ORACLE:

        state.update_status(
            ExecutionStatus.FINISHED
        )

    return state


def _apply_oracle_to_amplitudes(
    state: QuantumState,
    oracle
) -> None:

    if state.amplitudes is None:
        return

    amplitudes = state.amplitudes

    for index in range(
        len(amplitudes)
    ):

        bits = format(
            index,
            f"0{state.qubits}b"
        )

        if oracle.evaluate(bits):

            amplitudes[index] *= -1

# -------------------------------------------------
# Oracle Operator
#
# Corresponds to Rocq:
#
# Definition OracleOperator
#            (f : OracleInstance)
#            : QuantumOperator := ...
# -------------------------------------------------

def OracleOperator(
    state: QuantumState,
    oracle
) -> QuantumState:
    """
    Apply semantic oracle transition.

    For amplitude-based states, the oracle performs
    the Grover phase transformation:

        |x> -> (-1)^f(x) |x>

    The oracle identity and marked states are also
    recorded in the semantic state.
    """

    # -------------------------------------------------
    # Apply phase oracle to amplitudes
    # -------------------------------------------------

    _apply_oracle_to_amplitudes(
        state,
        oracle
    )

    # -------------------------------------------------
    # Evaluate symbolic current state
    # -------------------------------------------------
    oracle_result = oracle.evaluate(
        state.bits
    )

    state.target = (
        state.target != oracle_result
    )

    # -------------------------------------------------
    # Store oracle identity
    # -------------------------------------------------

    state.oracle = (
        oracle.kind.value
    )

    # -------------------------------------------------
    # Record marked computational states
    # -------------------------------------------------

    if state.amplitudes is not None:

        state.marked_states = [

            format(
                index,
                f"0{state.qubits}b"
            )

            for index in range(
                len(state.amplitudes)
            )

            if oracle.evaluate(
                format(
                    index,
                    f"0{state.qubits}b"
                )
            )
        ]

    # -------------------------------------------------
    # Semantic trace
    # -------------------------------------------------

    state.add_history(
        "Oracle"
    )

    # -------------------------------------------------
    # Status transition
    # -------------------------------------------------

    if state.status == ExecutionStatus.AFTER_HADAMARD:

        state.update_status(
            ExecutionStatus.AFTER_ORACLE
        )

    return state



# -------------------------------------------------
# Diffusion Operator
#
# Used by Grover's algorithm.
#
# Not present in the original DJ semantics,
# but implemented as reusable semantic infrastructure.
#
# -------------------------------------------------

def DiffusionOperator(
    state: QuantumState
) -> QuantumState:
    """
    Apply the Grover diffusion operator.

    The diffusion transformation performs inversion
    about the mean amplitude:

        a_i -> 2 * mean(a) - a_i
    """

    if state.amplitudes is not None:

        mean = np.mean(
            state.amplitudes
        )

        state.amplitudes = (
            2 * mean
            - state.amplitudes
        )

    state.add_history(
        "Diffusion"
    )

    state.update_status(
        ExecutionStatus.AFTER_DIFFUSION
    )

    return state



# -------------------------------------------------
# Measurement Operator
#
# Corresponds to Rocq:
#
# Definition MeasurementOperator :
#     QuantumOperator := ...
#
# -------------------------------------------------

def MeasurementOperator(
    state: QuantumState
) -> QuantumState:
    """
    Apply semantic measurement transition.

    If amplitudes are available, the measured result
    is represented by the most likely computational
    basis state.

    Otherwise the symbolic output or current basis
    state is used.
    """

    if state.symbolic_output is not None:

        result = state.symbolic_output

    elif state.amplitudes is not None:

        index = int(
            np.argmax(
                np.abs(
                    state.amplitudes
                ) ** 2
            )
        )

        result = format(
            index,
            f"0{state.qubits}b"
        )

    else:

        result = state.bits

    state.set_measurement(
        result
    )

    state.add_history(
        "Measurement"
    )

    state.update_status(
        ExecutionStatus.FINISHED
    )

    return state



# -------------------------------------------------
# Generic Operator Application
# -------------------------------------------------

def ApplyOperator(
    state: QuantumState,
    operator,
    *args,
    **kwargs
) -> QuantumState:
    """
    Generic semantic operator application.

    Example:

        ApplyOperator(
            state,
            HadamardOperator
        )

    corresponds to applying a QuantumOperator
    in the Rocq framework.
    """


    return operator(
        state,
        *args,
        **kwargs
    )



# -------------------------------------------------
# Measurement Observation
#
# Corresponds to Rocq:
#
# Definition Measure :
#     QuantumState -> MeasurementOutcome
#
# -------------------------------------------------

def Measure(
    state: QuantumState
):
    """
    Extract measurement result.

    This is an observation function rather than
    a state transition.
    """


    if state.measurement is not None:

        return state.measurement


    return state.bits