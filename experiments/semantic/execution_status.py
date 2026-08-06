"""
Execution status definitions.

This module represents the semantic execution state
used by the quantum verification framework.

Corresponds to the Rocq execution status type.
"""


from enum import Enum



class ExecutionStatus(Enum):
    """
    Represents the current semantic execution stage
    of a quantum program.
    """


    # Initial semantic state
    INITIAL = "Initial"


    # State after applying Hadamard transformation
    AFTER_HADAMARD = "AfterHadamard"


    # State after applying oracle operator
    AFTER_ORACLE = "AfterOracle"


    # State after Grover diffusion operator
    #
    # Used by Grover's algorithm
    #
    AFTER_DIFFUSION = "AfterDiffusion"


    # State after measurement operation
    AFTER_MEASUREMENT = "AfterMeasurement"


    # Completed execution
    FINISHED = "Finished"


    # Invalid semantic state
    #
    # Used for:
    # - invalid oracle promises
    # - failed semantic conditions
    #
    INVALID = "Invalid"