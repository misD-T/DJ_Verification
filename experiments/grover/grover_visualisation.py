"""
Visualisation utilities for the Grover experiments.

Produces publication-quality PNG figures for:

    1. Probability amplification
    2. Oracle evaluation
    3. Scaling
    4. Search quality
    5. Database search
"""

import os

import matplotlib.pyplot as plt


RESULTS_DIR = (
    "experiments/grover/results"
)


def _ensure_results_directory():

    os.makedirs(
        RESULTS_DIR,
        exist_ok=True
    )


# ============================================================
# 1. Probability Amplification
# ============================================================

def plot_probability_amplification(
    curve,
    filename="grover_probability_amplification.png"
):

    _ensure_results_directory()

    iterations = [
        x[0]
        for x in curve
    ]

    probabilities = [
        x[1]
        for x in curve
    ]

    plt.figure(
        figsize=(8, 5)
    )

    plt.plot(
        iterations,
        probabilities,
        marker="o"
    )

    plt.xlabel(
        "Grover Iteration"
    )

    plt.ylabel(
        "Probability of Marked State"
    )

    plt.title(
        "Grover Probability Amplification"
    )

    plt.ylim(
        0,
        1.05
    )

    plt.grid(
        True,
        alpha=0.3
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            filename
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# 2. Oracle Evaluation
# ============================================================

def plot_oracle_evaluation(
    results
):

    _ensure_results_directory()

    names = [
        r.oracle
        for r in results
    ]

    probabilities = [
        r.final_probability
        for r in results
    ]

    plt.figure(
        figsize=(9, 5)
    )

    plt.bar(
        names,
        probabilities
    )

    plt.xlabel(
        "Oracle Type"
    )

    plt.ylabel(
        "Final Success Probability"
    )

    plt.title(
        "Grover Oracle Evaluation"
    )

    plt.ylim(
        0,
        1.05
    )

    plt.grid(
        axis="y",
        alpha=0.3
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "grover_oracle_evaluation.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# 3. Scaling
# ============================================================

def plot_scaling(
    results
):

    _ensure_results_directory()

    plt.figure(
        figsize=(8, 5)
    )

    oracle_families = sorted(
        set(
            r["oracle_family"]
            for r in results
        )
    )

    for family in oracle_families:

        data = sorted(
            [
                r
                for r in results
                if r["oracle_family"] == family
            ],
            key=lambda x: x["qubits"]
        )

        plt.plot(
            [
                r["qubits"]
                for r in data
            ],
            [
                r["runtime"]
                for r in data
            ],
            marker="o",
            label=family
        )

    plt.xlabel(
        "Number of Qubits"
    )

    plt.ylabel(
        "Runtime (s)"
    )

    plt.title(
        "Grover Runtime Scaling"
    )

    plt.grid(
        True,
        alpha=0.3
    )

    plt.legend()

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "grover_scaling.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# 4. Search Quality
# ============================================================

def plot_search_quality(
    results
):

    _ensure_results_directory()

    iterations = [
        r.iteration
        for r in results
    ]

    marked_probability = [
        r.marked_probability
        for r in results
    ]

    max_unmarked_probability = [
        r.max_unmarked_probability
        for r in results
    ]

    plt.figure(
        figsize=(8, 5)
    )

    plt.plot(
        iterations,
        marked_probability,
        marker="o",
        label="Marked states"
    )

    plt.plot(
        iterations,
        max_unmarked_probability,
        marker="s",
        label="Maximum unmarked state"
    )

    plt.xlabel(
        "Grover Iteration"
    )

    plt.ylabel(
        "Probability"
    )

    plt.title(
        "Grover Search Quality"
    )

    plt.ylim(
        0,
        1.05
    )

    plt.grid(
        True,
        alpha=0.3
    )

    plt.legend()

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "grover_search_quality.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()


# ============================================================
# 5. Database Search
# ============================================================

def plot_database_search(
    result
):

    _ensure_results_directory()

    curve = result["curve"]

    iterations = [
        x[0]
        for x in curve
    ]

    probabilities = [
        x[1]
        for x in curve
    ]

    plt.figure(
        figsize=(8, 5)
    )

    plt.plot(
        iterations,
        probabilities,
        marker="o"
    )

    plt.xlabel(
        "Grover Iteration"
    )

    plt.ylabel(
        "Probability of Target"
    )

    plt.title(
        "Grover Unsorted Database Search"
    )

    plt.ylim(
        0,
        1.05
    )

    plt.grid(
        True,
        alpha=0.3
    )

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULTS_DIR,
            "grover_database_search.png"
        ),
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()