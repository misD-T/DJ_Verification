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

    Corresponds to Rocq:

        qs_amplitudes :=
            match qs_amplitudes ρ with
            | None => None
            | Some amps =>
                Some(
                    HadamardTransform amps n
                )
            end;

        qs_history := "H" :: qs_history ρ;

    """

    # Apply semantic amplitude transformation
    if state.amplitudes is not None:

        state.amplitudes = HadamardTransform(
            state.amplitudes,
            state.qubits
        )


    # Record semantic transition
    state.add_history(
        "H"
    )


    # Match Rocq status transition
    if state.status == ExecutionStatus.INITIAL:

        state.update_status(
            ExecutionStatus.AFTER_HADAMARD
        )


    elif state.status == ExecutionStatus.AFTER_ORACLE:

        state.update_status(
            ExecutionStatus.FINISHED
        )


    return state



# -------------------------------------------------
# Oracle Operator
#
# Corresponds to Rocq:
#
# Definition OracleOperator
#            (f : OracleInstance)
#            : QuantumOperator := ...
#
# -------------------------------------------------

def OracleOperator(
    state: QuantumState,
    oracle_name: str,
    oracle_function
) -> QuantumState:
    """
    Apply semantic oracle transition.

    Corresponds to Rocq:

        qs_target :=
            xorb
              (qs_target ρ)
              ((oracle_function f)
               (qs_bits ρ));

        qs_oracle := Some f;

        qs_history := "Oracle" :: qs_history ρ;

    Parameters
    ----------
    state:
        Current semantic quantum state.

    oracle_name:
        Identifier of the oracle instance.

    oracle_function:
        Algorithm-specific oracle behaviour.

        This is supplied by the algorithm module
        (Deutsch-Jozsa, Grover, etc.).
    """


    oracle_result = oracle_function(
        state.bits
    )


    # XOR behaviour from Rocq xorb
    state.target = (
        state.target != oracle_result
    )


    state.oracle = oracle_name


    state.add_history(
        "Oracle"
    )


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
    Apply Grover diffusion semantic transition.
    """


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

    Corresponds to Rocq:

        qs_measurement :=
            match qs_symbolic_output ρ with

            | Some out =>
                Some out

            | None =>
                Some(qs_bits ρ)

            end;

        qs_status := Finished;
    """


    if state.symbolic_output is not None:

        result = state.symbolic_output

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