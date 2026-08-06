"""
Deutsch–Jozsa verification.

This module defines the Deutsch–Jozsa specific correctness
properties used by the semantic verification framework.

The reusable verification infrastructure is provided by
semantic.verification.
"""

from __future__ import annotations

import time

from ..semantic import (
    QuantumState,
    InitialState,
    HadamardOperator,
    OracleOperator,
    MeasurementOperator,
    ExecutionStatus,

    # Verification framework
    Property,
    VerificationResult,
    verify_property,

    Proposition,
    Predicate,

    QDLFormula,
    HoareTriple
)


from .dj_circuit import *
from .dj_oracles import *

# ============================================================
# Deutsch–Jozsa Correctness Properties
# ============================================================

class ConstantOutputProperty(Property):
    """
    Deutsch–Jozsa correctness property for constant oracles.

    A constant oracle should always produce the all-zero output.
    """

    def __init__(self, n_target_bits):

        super().__init__(
            "Constant → OutputZero"
        )

        self.expected = "0" * n_target_bits


    def check(self, output):

        return output == self.expected


class BalancedOutputProperty(Property):
    """
    Deutsch–Jozsa correctness property for balanced oracles.

    A balanced oracle should never produce the all-zero output.
    """

    def __init__(self, n_target_bits):

        super().__init__(
            "Balanced → Not(OutputZero)"
        )

        self.expected = "0" * n_target_bits


    def check(self, output):

        return output != self.expected


class UndefinedProperty(Property):
    """
    Used for invalid Deutsch–Jozsa oracle promises.
    """

    def __init__(self):

        super().__init__(
            "Undefined Specification"
        )


    def check(self, output):

        return None


# ============================================================
# Quantum Dynamic Logic Propositions
# ============================================================

class OutputZero(Proposition):

    def evaluate(self, output):

        return output == ("0" * len(output))


    def __str__(self):

        return "OutputZero"


class NotOutputZero(Proposition):

    def evaluate(self, output):

        return output != ("0" * len(output))


    def __str__(self):

        return "Not(OutputZero)"


class UndefinedProposition(Proposition):

    def evaluate(self, output):

        return None


    def __str__(self):

        return "Undefined"


# ============================================================
# Hoare–Heisenberg Predicates
# ============================================================

class OutputZeroPredicate(Predicate):

    def evaluate(self, output):

        return output == ("0" * len(output))


    def __str__(self):

        return "OutputZero"


class NotOutputZeroPredicate(Predicate):

    def evaluate(self, output):

        return output != ("0" * len(output))


    def __str__(self):

        return "Not(OutputZero)"


# ============================================================
# Deutsch–Jozsa Formula Construction
# ============================================================

def build_verification_objects(category, n_target_bits):
    """
    Construct the semantic verification objects required for
    the specified oracle category.

    Returns
    -------
    property
        Correctness property.

    qdl
        Quantum Dynamic Logic formula.

    hh
        Hoare–Heisenberg triple.
    """

    if category == "Constant":

        prop = ConstantOutputProperty(
            n_target_bits
        )

        qdl = QDLFormula(
        assumption="ConstantOracle",
        program = "DJ",
        proposition=OutputZero()
        )

        hh = HoareTriple(
            precondition="ConstantOracle",
            program="DJ",
            predicate=OutputZeroPredicate()
        )

    elif category == "Balanced":

        prop = BalancedOutputProperty(
            n_target_bits
        )

        qdl = QDLFormula(
            assumption="BalancedOracle",
            program = "DJ",
            proposition=NotOutputZero()
        )

        hh = HoareTriple(
            precondition="BalancedOracle",
            program="DJ",
            predicate=NotOutputZeroPredicate()
        )

    else:

        prop = UndefinedProperty()

        qdl = QDLFormula(
            assumption="InvalidOracle",
            program="DJ",
            proposition=UndefinedProposition()
        )

        hh = None

    return prop, qdl, hh

# ============================================================
# Deutsch–Jozsa Verification Experiment
# ============================================================

def run_test(oracle_type, n_target_bits, verbose = False):
    """
    Execute a Deutsch–Jozsa experiment and verify the
    semantic correctness property.

    Returns
    -------
    dict
        Structured experiment results used by the
        complexity, runtime, and promise robustness
        experiments.
    """

    # -------------------------------------------------
    # Execute Program
    # -------------------------------------------------

    start_time = time.perf_counter()

    probs,state = ExecuteDJ(oracle_type, n_target_bits)

    runtime = time.perf_counter() - start_time

    output = most_likely_bitstring(probs)

    prob_zero = float(probs[0])

    # -------------------------------------------------
    # Oracle Categories
    # -------------------------------------------------

    constant_oracles = {
        "constant_zero",
        "constant_one",
    }

    balanced_oracles = {
        "first_bit",
        "parity",
        "full_parity",
        "xor_two_bits",
        "alternating",
        "affine",
        "and_xor",
        "random_balanced",
    }

    if oracle_type in constant_oracles:

        category = "Constant"

    elif oracle_type in balanced_oracles:

        category = "Balanced"

    else:

        category = "Invalid"

    # -------------------------------------------------
    # Build Verification Objects
    # -------------------------------------------------

    prop, qdl, hh = build_verification_objects(
        category,
        n_target_bits
    )

    # -------------------------------------------------
    # Property Verification
    # -------------------------------------------------

    verification = verify_property(
        prop,
        output
    )

    # -------------------------------------------------
    # Quantum Dynamic Logic
    # -------------------------------------------------

    qdl_result = qdl.verify(output)

    # -------------------------------------------------
    # Hoare–Heisenberg Logic
    # -------------------------------------------------

    if hh is None:

        hh_result = False

    else:

        hh_result = hh.verify(output)

    # -------------------------------------------------
    # Console Output
    # -------------------------------------------------

    if verbose:

        print()

        print("=" * 70)

        print("Oracle:", oracle_type)

        print("Category:", category)

        print("Output:", output)

        print(f"P(0...0): {prob_zero:.6f}")

        print(f"Runtime: {runtime:.6f} s")

        print()

        print("Verification Property")

        print(verification)

        print()

        print("Quantum Dynamic Logic")

        print(qdl)

        print("Verified:", qdl_result)

        print()

        print("Hoare–Heisenberg Logic")

        if hh is None:

            print("Undefined")

        else:

            print(hh)

            print("Verified:", hh_result)

        print("=" * 70)

    # -------------------------------------------------
    # Structured Result
    # -------------------------------------------------

    return {

        "oracle": oracle_type,

        "category": category,

        "class": oracle_class(
            oracle_type,
            n_target_bits
        ),

        "complexity": oracle_complexity(
            oracle_type,
            n_target_bits
        ),

        "distance": promise_distance(
            oracle_type,
            n_target_bits
        ),

        "bias": oracle_bias(
            oracle_type,
            n_target_bits
        ),

        "output": output,

        "prob_zero": prob_zero,

        "runtime": runtime,

        "verified": verification.verified,

        "qdl_formula": str(qdl),

        "qdl_result": qdl_result,

        "hh_formula": (
            str(hh)
            if hh is not None
            else "Undefined"
        ),

        "hh_result": hh_result,
        
        "semantic_trace":
            state.history,


        "semantic_status":
            state.status.name,


        "semantic_measurement":
            state.measurement,


        "symbolic_output":
            state.symbolic_output,
}
