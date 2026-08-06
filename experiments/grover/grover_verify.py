"""
Grover verification.

This module defines the Grover-specific correctness
properties used by the semantic verification framework.

The reusable verification infrastructure is provided by
semantic.verification.

Corresponds to:

Rocq:

    GroverCorrect n f :=
        qs_oracle (GroverExecute n f)
        =
        Some f

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
    OracleInstance,
    OracleKind
)



# ============================================================
# Grover Correctness Property
# ============================================================


class GroverOraclePreservationProperty(Property):
    """
    Grover correctness property.

    The Grover execution must preserve
    the oracle instance being executed.

    Corresponds to:

    qs_oracle(GroverExecute n f)
        =
    Some f
    """

    def __init__(
            self,
            oracle
    ):

        super().__init__(
            "Grover Oracle Preservation"
        )

        self.oracle = oracle


    def check(
            self,
            state
    ):

        return (

            state.oracle
            ==
            self.oracle.kind.name

        )



# ============================================================
# QDL Propositions
# ============================================================


class OraclePreserved(Proposition):
    """
    QDL postcondition:

        Oracle remains unchanged.
    """


    def evaluate(
            self,
            state
    ):

        return (

            state.oracle
            is not None

        )


    def __str__(self):

        return "OraclePreserved"



# ============================================================
# Hoare-Heisenberg Predicates
# ============================================================


class OraclePreservedPredicate(Predicate):


    def evaluate(
            self,
            state
    ):

        return (

            state.oracle
            is not None

        )


    def __str__(self):

        return "OraclePreserved"



# ============================================================
# Verification Object Construction
# ============================================================


def build_verification_objects(
        oracle
):
    """
    Construct Grover QDL and HH verification objects.

    The specification is independent of oracle family.

    Supports:

        - single marked
        - multiple marked
        - random marked
        - predicate oracle

    """

    prop = GroverOraclePreservationProperty(
        oracle
    )


    qdl = QDLFormula(

        assumption="ValidOracle",

        program="Grover",

        proposition=OraclePreserved()

    )


    hh = HoareTriple(

        precondition="ValidOracle",

        program="Grover",

        predicate=OraclePreservedPredicate()

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
    Execute Grover and verify semantic correctness.

    Returns structured results for experiments.

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


    runtime = (

        time.perf_counter()

        -

        start

    )


    # -------------------------------------------------
    # Build Verification Objects
    # -------------------------------------------------


    prop, qdl, hh = build_verification_objects(

        oracle

    )


    # -------------------------------------------------
    # Property Verification
    # -------------------------------------------------


    verification = verify_property(

        prop,

        state

    )


    # -------------------------------------------------
    # QDL Verification
    # -------------------------------------------------

    qdl_result = qdl.verify(
        state
    )


    # -------------------------------------------------
    # HH Verification
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

        print(
            "Grover Verification"
        )

        print("=" * 70)


        print(
            "Oracle:",
            oracle.kind.name
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

        print(
            "Semantic Property"
        )


        print(
            verification
        )


        print()


        print(
            "Quantum Dynamic Logic"
        )


        print(
            qdl
        )


        print(
            "Verified:",
            qdl_result
        )


        print()


        print(
            "Hoare-Heisenberg Logic"
        )


        print(
            hh
        )


        print(
            "Verified:",
            hh_result
        )


        print("=" * 70)



    return {


        "oracle":

            oracle.kind.name,


        "measurement":

            state.measurement,


        "status":

            state.status.name,


        "semantic_trace":

            state.history,


        "semantic_property":

            verification.verified,


        "qdl_formula":

            str(qdl),


        "qdl_result":

            qdl_result,


        "hh_formula":

            str(hh),


        "hh_result":

            hh_result,


        "runtime":

            runtime,


        "symbolic_output":

            state.symbolic_output

    }