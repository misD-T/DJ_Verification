"""
QuantumState semantic representation.

This module provides the Python representation of the abstract
quantum state used by the Rocq verification framework.

The class is intentionally independent from any quantum backend
(PennyLane, Qiskit, etc.). It represents the semantic state that
is transformed by quantum operators.
"""


from dataclasses import dataclass

import numpy as np

from .execution_status import ExecutionStatus
from .trace import SemanticTrace



# -------------------------------------------------
# QuantumState
#
# Corresponds to Rocq:
#
# Record QuantumState :=
# {
#    qs_bits;
#    qs_amplitudes;
#    qs_target;
#    qs_qubits;
#    qs_oracle;
#    qs_measurement;
#    qs_history;
#    qs_status;
#    qs_symbolic_output
# }
#
# -------------------------------------------------

@dataclass
class QuantumState:
    """
    Semantic representation of a quantum program state.

    This object does not simulate quantum evolution itself.

    Instead, it records the abstract semantic state and
    execution trace produced by quantum operators.

    Quantum backends such as PennyLane provide physical
    execution, while QuantumState records the corresponding
    semantic evolution.
    """


    # Current computational basis representation
    bits: str


    # Optional probability/amplitude representation
    amplitudes: np.ndarray | None


    # Whether this state contains a target/marked condition
    target: bool


    # Number of qubits in the system
    qubits: int


    # Oracle identifier used during execution
    oracle: str | None


    # Measurement result
    measurement: str | None


    # Semantic execution trace
    #
    # Corresponds to Rocq:
    #
    # qs_history : list string
    #
    trace: SemanticTrace


    # Current execution stage
    status: ExecutionStatus = ExecutionStatus.INITIAL


    # Symbolic result produced by the semantic model
    symbolic_output: str | None = None



    # -------------------------------------------------
    # Utility methods
    # -------------------------------------------------

    def add_history(self, operation: str):
        """
        Append an operation to the semantic execution trace.

        Corresponds to Rocq:

            qs_history := operation :: qs_history

        The Python trace stores operations chronologically
        for easier experimental analysis.
        """

        self.trace.add(operation)



    def update_status(self, status: ExecutionStatus):
        """
        Update semantic execution status.
        """

        self.status = status



    def set_measurement(self, result: str):
        """
        Store measurement outcome.
        """

        self.measurement = result

        self.symbolic_output = result



    def summary(self):
        """
        Return a readable semantic execution summary.
        """

        return {

            "bits": self.bits,

            "qubits": self.qubits,

            "oracle": self.oracle,

            "measurement": self.measurement,

            "trace": self.trace.to_list(),

            "status": self.status.value,

            "symbolic_output": self.symbolic_output
        }



# -------------------------------------------------
# Initial State
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

    Equivalent to Rocq InitialState.
    """


    trace = SemanticTrace()

    trace.add(
        "InitialState"
    )


    return QuantumState(

        bits="0" * qubits,

        amplitudes=None,

        target=target,

        qubits=qubits,

        oracle=None,

        measurement=None,

        trace=trace,

        status=ExecutionStatus.INITIAL,

        symbolic_output=None
    )