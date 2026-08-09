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

from .grover_oracles import (
    OracleKind
)

# ============================================================
# Grover Semantic Correctness Property
# ============================================================

class GroverSemanticProperty(Property):
    """
    Mirrors the Rocq theorem

        GroverCorrect n f

    which states that the oracle executed by the
    Grover program is preserved in the final
    semantic state.
    """

    def __init__(self, oracle):

        super().__init__(
            "Oracle Preserved"
        )

        self.oracle = oracle.kind.name

    def check(self, state):

        return state.oracle == self.oracle

# ============================================================
# Quantum Dynamic Logic Proposition
# ============================================================

class OracleTracked(Proposition):

    def evaluate(self, state):

        return state.oracle is not None

    def __str__(self):

        return "OracleTracked"


# ============================================================
# Hoare–Heisenberg Predicate
# ============================================================

class OracleTrackedPredicate(Predicate):

    def evaluate(self, state):

        return state.oracle is not None

    def __str__(self):

        return "OracleTracked"


# ============================================================
# Verification Object Construction
# ============================================================

def build_verification_objects(oracle):
    """
    Construct the semantic verification objects
    corresponding to the Rocq framework.

    Unlike the numerical experiments, the semantic
    proof is independent of the oracle family.
    """

    prop = GroverSemanticProperty(
        oracle
    )

    qdl = QDLFormula(

        assumption="InitialState",

        program="Grover",

        proposition=OracleTracked()

    )

    hh = HoareTriple(

        precondition="InitialState",

        program="Grover",

        predicate=OracleTrackedPredicate()

    )

    return prop, qdl, hh


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
    Rocq correctness properties.

    Returns structured semantic verification results.
    """

    # -------------------------------------------------
    # Execute Grover
    # -------------------------------------------------

    start = time.perf_counter()

    state = GroverCircuit(

        qubits,

        oracle,

        1

    )

    runtime = time.perf_counter() - start


    # -------------------------------------------------
    # Build Verification Objects
    # -------------------------------------------------

    prop, qdl, hh = build_verification_objects(

        oracle

    )


    # -------------------------------------------------
    # Semantic Property Verification
    # -------------------------------------------------

    verification = verify_property(

        prop,

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

        print("Oracle:", oracle.kind.name)

        print("Measurement:", state.measurement)

        print("Status:", state.status.name)

        print()

        print("Grover Correctness")

        print(verification)

        print()

        print("Quantum Dynamic Logic")

        print(qdl)

        print("Verified:", qdl_result)

        print()

        print("Hoare–Heisenberg Logic")

        print(hh)

        print("Verified:", hh_result)

        print()

        print("Semantic Trace")

        print(" -> ".join(state.history))

        print()

        print("=" * 70)


    # -------------------------------------------------
    # Structured Result
    # -------------------------------------------------

    return {

        "oracle":

            oracle.kind.name,


        "measurement":

            state.measurement,


        "runtime":

            runtime,


        "verified":

            verification.verified,


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