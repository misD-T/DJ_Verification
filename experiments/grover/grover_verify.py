"""
Grover verification.

This module defines the Grover-specific correctness
properties used by the semantic verification framework.

The reusable verification infrastructure is provided by
semantic.verification.

Corresponds to the Rocq framework:

    GroverCorrect n f

    HHVerified (GroverHHSpec n f)

    Valid (GroverFormula n f)
"""

from __future__ import annotations

import time

from ..semantic import (
    Property,
    Proposition,
    Predicate,
    verify_property,
    QDLFormula,
    HoareTriple
)

from .grover_circuit import (
    GroverCircuit
)

from .grover_probability import (
    optimal_grover_iterations
)

from .grover_oracles import (
    predicate_marked_states
)


# ============================================================
# Grover Semantic Correctness Property
# ============================================================

class GroverOraclePreservationProperty(Property):
    """
    Grover semantic correctness property.

    The oracle used by the Grover program must be
    preserved in the final semantic state.
    """

    def __init__(
        self,
        oracle
    ):

        super().__init__(
            "Oracle Identity Preserved"
        )

        self.oracle = (
            oracle.kind.value
        )

    def check(
        self,
        state
    ):

        return (
            state.oracle
            == self.oracle
        )

class GroverMarkedStateProperty(Property):
    """
    Grover correctness property.

    The final measurement should correspond to one
    of the oracle's marked computational-basis states.
    """

    def __init__(
        self,
        oracle
    ):

        super().__init__(
            "Measurement Is Marked State"
        )

        self.oracle = oracle

    def check(
        self,
        state
    ):

        if state.measurement is None:

            return False

        return (
            state.measurement
            in state.marked_states
        )
        
class GroverMarkedOutputProperty(Property):
    """
    Grover correctness property.

    The final measured state must belong to the
    set of states marked by the oracle.
    """

    def __init__(
        self,
        oracle,
        qubits
    ):

        super().__init__(
            "Measurement → MarkedState"
        )

        self.oracle = oracle
        self.qubits = qubits

    def check(
        self,
        state
    ):

        if state.measurement is None:
            return False

        return self.oracle.evaluate(
            state.measurement
        )


# ============================================================
# Quantum Dynamic Logic Proposition
# ============================================================

class MarkedState(Proposition):

    def __init__(self, oracle):

        self.oracle = oracle

    def evaluate(self, state):

        if state.measurement is None:
            return False

        return self.oracle.evaluate(
            state.measurement
        )

    def __str__(self):

        return "MarkedState"


# ============================================================
# Hoare–Heisenberg Predicate
# ============================================================

class MarkedStatePredicate(Predicate):

    def __init__(self, oracle):

        self.oracle = oracle

    def evaluate(self, state):

        if state.measurement is None:
            return False

        return self.oracle.evaluate(
            state.measurement
        )

    def __str__(self):

        return "MarkedState"


# ============================================================
# Verification Object Construction
# ============================================================

def build_verification_objects(
    oracle,
    qubits
):
    """
    Construct the semantic verification objects
    corresponding to the Grover correctness property.

    The specification states that Grover should produce
    a state satisfying the oracle predicate.
    """

    prop = GroverMarkedStateProperty(
        oracle
    )

    oracle_property = GroverOraclePreservationProperty(
    oracle
    )
    
    output_prop = GroverMarkedOutputProperty(
        oracle,
        qubits
    )

    qdl = QDLFormula(
        assumption="InitialState",
        program="Grover",
        proposition=MarkedState(
            oracle
        )
    )

    hh = HoareTriple(
        precondition="InitialState",
        program="Grover",
        predicate=MarkedStatePredicate(
            oracle
        )
    )

    return prop, output_prop, qdl, hh


# ============================================================
# Grover Verification Experiment
# ============================================================

def run_test(
    qubits,
    oracle,
    verbose=False
):
    """
    Execute the semantic Grover program and verify the
    Grover marked-state correctness properties.
    """

    # -------------------------------------------------
    # Determine marked states
    # -------------------------------------------------

    marked_states = predicate_marked_states(
        qubits,
        oracle.function
    )

    marked_state_count = len(
        marked_states
    )

    # -------------------------------------------------
    # Determine optimal Grover iterations
    # -------------------------------------------------

    iterations = optimal_grover_iterations(
        qubits,
        marked_state_count
    )

    # -------------------------------------------------
    # Execute Grover
    # -------------------------------------------------

    start = time.perf_counter()

    state = GroverCircuit(
        qubits,
        oracle,
        iterations
    )

    runtime = (
        time.perf_counter()
        - start
    )

    # -------------------------------------------------
    # Build Verification Objects
    # -------------------------------------------------

    prop, output_prop, qdl, hh = (
        build_verification_objects(
            oracle,
            qubits
        )
    )

    # -------------------------------------------------
    # Semantic Property Verification
    # -------------------------------------------------

    verification = verify_property(
        prop,
        state
    )

    output_verification = verify_property(
        output_prop,
        state
    )

    # -------------------------------------------------
    # Quantum Dynamic Logic
    # -------------------------------------------------

    qdl_result = qdl.verify(
        state
    )

    # -------------------------------------------------
    # Hoare–Heisenberg Logic
    # -------------------------------------------------

    hh_result = hh.verify(
        state
    )

    # -------------------------------------------------
    # Console Output
    # -------------------------------------------------

    if verbose:

        print()

        print("=" * 70)

        print("Grover Semantic Verification")

        print("=" * 70)

        print(
            "Oracle:",
            oracle.kind.name
        )

        print(
            "Qubits:",
            qubits
        )

        print(
            "Marked States:",
            marked_state_count
        )

        print(
            "Iterations:",
            iterations
        )

        print(
            "Measurement:",
            state.measurement
        )

        print(
            "Status:",
            state.status.name
        )

        print()

        print("Grover Correctness")

        print(verification)

        print(
            "Verified:",
            verification.verified
        )

        print()

        print("Grover Output Correctness")

        print(output_verification)

        print(
            "Verified:",
            output_verification.verified
        )

        print()

        print("Quantum Dynamic Logic")

        print(qdl)

        print(
            "Verified:",
            qdl_result
        )

        print()

        print("Hoare–Heisenberg Logic")

        print(hh)

        print(
            "Verified:",
            hh_result
        )

        print()

        print("Semantic Trace")

        print(
            " -> ".join(
                state.history
            )
        )

        print()

        print("=" * 70)

    # -------------------------------------------------
    # Structured Result
    # -------------------------------------------------

    return {

        "oracle":
            oracle.kind.name,

        "qubits":
            qubits,

        "marked_states":
            marked_states,

        "marked_state_count":
            marked_state_count,

        "iterations":
            iterations,

        "measurement":
            state.measurement,

        "runtime":
            runtime,

        "verified":
            verification.verified,

        "output_verified":
            output_verification.verified,

        "qdl_formula":
            str(qdl),

        "qdl_result":
            qdl_result,

        "hh_formula":
            str(hh),

        "hh_result":
            hh_result,

        "semantic_trace":
            state.history,

        "semantic_status":
            state.status.name,

        "symbolic_output":
            state.symbolic_output

    }

