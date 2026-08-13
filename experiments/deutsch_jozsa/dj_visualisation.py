"""
dj_visualisation.py

Visualisation utilities for the Deutsch–Jozsa experiments.

The visualisations are organised around four experimental questions:

1. How does execution scale with the number of qubits?
2. How does oracle structure affect execution cost?
3. How robust is verification when the Deutsch–Jozsa promise is violated?
4. Do QDL and Hoare–Heisenberg verification agree?

These plots use the structured dictionaries produced by the
Deutsch–Jozsa experiment modules.
"""

import os

import matplotlib.pyplot as plt


# ============================================================
# Output Directory
# ============================================================

RESULTS_DIR = "experiments/deutsch_jozsa/results"


def _ensure_results_directory():
    """
    Ensure that the experiment results directory exists.
    """

    os.makedirs(
        RESULTS_DIR,
        exist_ok=True
    )


# ============================================================
# Scaling Runtime
# ============================================================

def plot_scaling_runtime(results):
    """
    Plot runtime against the number of target qubits.

    Used to evaluate scalability of the Deutsch–Jozsa
    implementation.
    """

    _ensure_results_directory()

    plt.figure(figsize=(8, 5))

    oracle_groups = {}

    for r in results:

        oracle_groups.setdefault(
            r["oracle"],
            []
        ).append(r)

    for oracle, data in oracle_groups.items():

        data = sorted(
            data,
            key=lambda x: x["n"]
        )

        plt.plot(

            [x["n"] for x in data],

            [x["runtime_avg"] for x in data],

            marker="o",

            label=oracle
        )

    plt.xlabel(
        "Number of Target Qubits"
    )

    plt.ylabel(
        "Average Runtime (s)"
    )

    plt.title(
        "Deutsch–Jozsa Runtime Scaling"
    )

    plt.grid(True)

    plt.legend()

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_runtime_scaling.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Oracle Runtime
# ============================================================

def plot_oracle_runtime(results):
    """
    Compare average runtime across oracle implementations.
    """

    _ensure_results_directory()

    plt.figure(figsize=(10, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    runtimes = [
        r["avg_runtime"]
        for r in results
    ]

    plt.bar(
        names,
        runtimes
    )

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Average Runtime (s)"
    )

    plt.title(
        "Deutsch–Jozsa Oracle Runtime Comparison"
    )

    plt.grid(
        axis="y"
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_oracle_runtime.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Oracle Complexity
# ============================================================

def plot_oracle_complexity(results):
    """
    Compare the structural oracle complexity scores.

    Note:
        The complexity value is a structural score defined
        by the oracle model. It should not be interpreted as
        a formal asymptotic circuit-complexity result.
    """

    _ensure_results_directory()

    plt.figure(figsize=(10, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    complexity = [
        r["structural_complexity"]
        for r in results
    ]

    plt.bar(
        names,
        complexity
    )

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Structural Complexity Score"
    )

    plt.title(
        "Deutsch–Jozsa Oracle Structural Complexity"
    )

    plt.grid(
        axis="y"
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_oracle_complexity.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Promise Robustness — Probability
# ============================================================

def plot_promise_probability(results):
    """
    Plot P(0...0) for each oracle.

    For valid constant oracles, P(0...0) should be approximately 1.

    For valid balanced oracles, P(0...0) should be approximately 0.

    Invalid promise instances may fall between these values.
    """

    _ensure_results_directory()

    plt.figure(figsize=(11, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    probabilities = [
        r["prob_zero"]
        for r in results
    ]

    plt.bar(
        names,
        probabilities
    )

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Average P(0...0)"
    )

    plt.title(
        "Deutsch–Jozsa Promise Robustness"
    )

    plt.ylim(
        0,
        1.05
    )

    plt.grid(
        axis="y"
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_promise_probability.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Promise Distance
# ============================================================

def plot_promise_distance(results):
    """
    Plot the distance of each oracle from the balanced promise.

    Distance is measured as:

        |number_of_ones - 2^n / 2|

    A value of zero indicates a balanced oracle.

    Note:
        Constant functions have the maximum distance for a
        given n, even though they are valid Deutsch–Jozsa
        inputs. Therefore this plot measures distance from
        the BALANCED condition, not validity of the complete
        Deutsch–Jozsa promise.
    """

    _ensure_results_directory()

    plt.figure(figsize=(11, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    distance = [
        r["distance"]
        for r in results
    ]

    plt.bar(
        names,
        distance
    )

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Distance from Balanced Condition"
    )

    plt.title(
        "Oracle Distance from the Balanced Condition"
    )

    plt.grid(
        axis="y"
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_promise_distance.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Verification Comparison
# ============================================================

def plot_verification_comparison(results):
    """
    Compare verification outcomes from:

        - QDL
        - Hoare–Heisenberg

    Each successful verification is represented as 1,
    while failure or undefined verification is represented
    as 0.

    This visualisation demonstrates whether the two logical
    approaches agree on the tested oracle instances.
    """

    _ensure_results_directory()

    plt.figure(figsize=(11, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    qdl = [
        1 if r["qdl"] is True else 0
        for r in results
    ]

    hh = [
        1 if r["hh"] is True else 0
        for r in results
    ]

    positions = range(len(names))

    width = 0.35

    qdl_positions = [
        p - width / 2
        for p in positions
    ]

    hh_positions = [
        p + width / 2
        for p in positions
    ]

    plt.bar(
        qdl_positions,
        qdl,
        width=width,
        label="QDL"
    )

    plt.bar(
        hh_positions,
        hh,
        width=width,
        label="Hoare–Heisenberg"
    )

    plt.xticks(
        list(positions),
        names,
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Verification Result"
    )

    plt.yticks(
        [0, 1],
        ["False", "True"]
    )

    plt.title(
        "Verification Agreement Across Oracle Instances"
    )

    plt.ylim(
        0,
        1.2
    )

    plt.grid(
        axis="y"
    )

    plt.legend()

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_verification_comparison.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Verification Stability
# ============================================================

def plot_verification_stability(results):
    """
    Show whether the two verification approaches agree.

    A value of 1 indicates agreement.
    A value of 0 indicates disagreement.
    """

    _ensure_results_directory()

    plt.figure(figsize=(11, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    agreement = [

        1
        if r["qdl"] == r["hh"]
        else 0

        for r in results
    ]

    plt.bar(
        names,
        agreement
    )

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Agreement"
    )

    plt.yticks(
        [0, 1],
        ["Disagree", "Agree"]
    )

    plt.title(
        "QDL and Hoare–Heisenberg Verification Agreement"
    )

    plt.ylim(
        0,
        1.2
    )

    plt.grid(
        axis="y"
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_verification_agreement.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# Semantic Execution Trace
# ============================================================

def plot_semantic_trace(results):
    """
    Visualise the number of semantic transitions executed
    by each oracle.

    All valid Deutsch–Jozsa executions should follow the
    same high-level semantic structure:

        InitialState
        AncillaPreparation
        H
        Oracle
        H
        Measurement
    """

    _ensure_results_directory()

    plt.figure(figsize=(11, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    trace_lengths = [

        len(
            r["semantic_trace"]
        )

        for r in results
    ]

    plt.bar(
        names,
        trace_lengths
    )

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.ylabel(
        "Number of Semantic Transitions"
    )

    plt.title(
        "Deutsch–Jozsa Semantic Execution Trace"
    )

    plt.grid(
        axis="y"
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "dj_semantic_trace.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()
    
# -------------------------------------------------
# Semantic Execution Trace
# -------------------------------------------------

def plot_semantic_trace(results):

    plt.figure(figsize=(10, 5))

    names = [
        r["oracle"]
        for r in results
    ]

    traces = [
        r["semantic_trace"]
        for r in results
    ]

    step_counts = [
        len(trace)
        for trace in traces
    ]

    plt.bar(
        names,
        step_counts
    )

    plt.xticks(
        rotation=45
    )

    plt.ylabel(
        "Number of Semantic Steps"
    )

    plt.title(
        "Deutsch–Jozsa Semantic Execution Trace"
    )

    plt.grid(
        axis="y"
    )

    plt.savefig(
        "experiments/deutsch_jozsa/results/dj_semantic_trace.png",
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()