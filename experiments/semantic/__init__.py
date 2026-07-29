"""
Semantic quantum verification package.

This package provides the reusable semantic infrastructure
used by quantum algorithm experiments.

The implementation mirrors the Rocq verification framework:

    QuantumState
        |
        +-- ExecutionStatus
        |
        +-- SemanticTrace
        |
        +-- Quantum Operators

Algorithm-specific modules (Deutsch-Jozsa, Grover, etc.)
use these components without redefining the semantic model.
"""


# -------------------------------------------------
# Quantum State
# -------------------------------------------------

from .quantum_state import (
    QuantumState,
    InitialState
)



# -------------------------------------------------
# Execution Status
# -------------------------------------------------

from .execution_status import (
    ExecutionStatus
)



# -------------------------------------------------
# Semantic Trace
# -------------------------------------------------

from .trace import (
    SemanticTrace
)



# -------------------------------------------------
# Semantic Operators
# -------------------------------------------------

from .operators import (
    HadamardOperator,
    OracleOperator,
    DiffusionOperator,
    MeasurementOperator,
    ApplyOperator,
    Measure
)



# -------------------------------------------------
# Semantic Transformations
# -------------------------------------------------

from .transforms import (
    HadamardTransform
)

# -------------------------------------------------
# Oracle Representation
# -------------------------------------------------

from .oracles import (
    OracleKind,
    OracleInstance
)


# Package version
__version__ = "1.0.0"