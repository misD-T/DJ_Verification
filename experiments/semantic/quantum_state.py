"""
QuantumState semantic representation.

This module provides the Python representation of the abstract
quantum state used by the Rocq verification framework.

The class mirrors the Rocq definition:

Record QuantumState :=
{
    qs_bits;
    qs_amplitudes;
    qs_target;
    qs_qubits;
    qs_oracle;
    qs_measurement;
    qs_history;
    qs_status;
    qs_symbolic_output
}.

The object represents semantic evolution, not physical quantum
simulation. Quantum backends such as PennyLane execute circuits,
while QuantumState records the corresponding semantic transitions.
"""


from dataclasses import dataclass, field

import numpy as np

from .execution_status import ExecutionStatus



# -------------------------------------------------
# QuantumState
#
# Corresponds to Rocq:
#
# Record QuantumState := ...
#
# -------------------------------------------------

@dataclass
class QuantumState:
    """
    Semantic representation of a quantum computation state.
    """


    # Current computational basis representation
    bits: str


    # Optional amplitude/probability representation
    amplitudes: np.ndarray | None


    # Target/marked condition
    #
    # Used by the semantic model to record whether
    # the current symbolic state satisfies the oracle.
    target: bool


    # Number of qubits
    qubits: int


    # Oracle identifier
    oracle: str | None


    # Measurement result
    measurement: str | None


    # Marked states used by search algorithms such
    # as Grover.
    #
    # Stored as computational-basis bitstrings.
    marked_states: list[str] = field(
        default_factory=list
    )


    # Semantic execution history
    #
    # Corresponds directly to Rocq:
    #
    # qs_history : list string
    #
    history: list[str] = field(
        default_factory=list
    )


    # Current semantic execution status
    status: ExecutionStatus = (
        ExecutionStatus.INITIAL
    )


    # Symbolic result
    symbolic_output: str | None = None



    # -------------------------------------------------
    # History Management
    # -------------------------------------------------

    def add_history(
        self,
        operation: str
    ):
        """
        Append semantic operation to execution history.

        Corresponds to Rocq:

            qs_history := operation :: qs_history
        """

        self.history.append(
            operation
        )



    # -------------------------------------------------
    # Status Management
    # -------------------------------------------------

    def update_status(
        self,
        status: ExecutionStatus
    ):
        """
        Update semantic execution state.
        """

        self.status = status



    # -------------------------------------------------
    # Measurement
    # -------------------------------------------------

    def set_measurement(
        self,
        result: str
    ):
        """
        Store measurement result.
        """

        self.measurement = result

        self.symbolic_output = result



    # -------------------------------------------------
    # Summary
    # -------------------------------------------------

    def summary(self):
        """
        Return semantic execution summary.
        """

        return {

            "bits":
                self.bits,

            "qubits":
                self.qubits,

            "oracle":
                self.oracle,

            "measurement":
                self.measurement,

            "history":
                self.history,

            "status":
                self.status.value,

            "symbolic_output":
                self.symbolic_output
        }


def set_marked_states(
    state: QuantumState,
    marked_states: list[str]
) -> QuantumState:
    """
    Record the marked computational-basis states
    associated with a search oracle.

    This is semantic metadata rather than a numerical
    quantum operation.
    """

    state.marked_states = list(
        marked_states
    )

    return state


# -------------------------------------------------
# InitialState
#
# Corresponds to Rocq:
#
# Definition InitialState
#
# -------------------------------------------------

def InitialState(
    qubits: int,
    target: bool = False
) -> QuantumState:
    """
    Construct the initial semantic quantum state.

    The semantic amplitude representation starts in
    computational basis state |0...0>.

    This is important because HadamardOperator must
    subsequently transform |0...0> into a uniform
    superposition for Deutsch-Jozsa and Grover.
    """

    dimension = 2 ** qubits

    amplitudes = np.zeros(
        dimension,
        dtype=complex
    )

    amplitudes[0] = 1.0

    return QuantumState(

        bits="0" * qubits,

        amplitudes=amplitudes,

        target=target,

        marked_states=[],

        qubits=qubits,

        oracle=None,

        measurement=None,

        history=[
            "InitialState"
        ],

        status=ExecutionStatus.INITIAL,

        symbolic_output=None
    )
    
def UniformSuperposition(
    state: QuantumState
) -> QuantumState:
    """
    Initialise the amplitude representation of a
    quantum state as the uniform superposition.

    This is useful for Grover's search space.
    """

    dimension = 2 ** state.qubits

    state.amplitudes = np.ones(
        dimension,
        dtype=complex
    ) / np.sqrt(
        dimension
    )

    state.add_history(
        "UniformSuperposition"
    )

    return state