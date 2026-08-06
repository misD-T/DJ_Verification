"""
dj_visualisation.py

Visualisation utilities for the Deutsch–Jozsa experiments.
"""

import matplotlib.pyplot as plt


# -------------------------------------------------
# Scaling Runtime
# -------------------------------------------------

def plot_scaling_runtime(results):

    plt.figure(figsize=(8,5))

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

    plt.xlabel("Number of Target Qubits")

    plt.ylabel("Average Runtime (s)")

    plt.title("Deutsch–Jozsa Runtime Scaling")

    plt.grid(True)

    plt.legend()

    plt.savefig(
        "experiments/deutsch_jozsa/results/dj_runtime_scaling.png",
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()
    
# -------------------------------------------------
# Oracle Runtime
# -------------------------------------------------

def plot_oracle_runtime(results):

    plt.figure(figsize=(10,5))

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

    plt.xticks(rotation=45)

    plt.ylabel("Average Runtime (s)")

    plt.title("Oracle Runtime Comparison")

    plt.grid(axis="y")

    plt.savefig(
        "experiments/deutsch_jozsa/results/dj_oracle_runtime.png",
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()

# -------------------------------------------------
# Oracle Complexity
# -------------------------------------------------

def plot_oracle_complexity(results):

    plt.figure(figsize=(10,5))

    names = [
        r["oracle"]
        for r in results
    ]

    complexity = [
        r["complexity"]
        for r in results
    ]

    plt.bar(
        names,
        complexity
    )

    plt.xticks(rotation=45)

    plt.ylabel("Complexity Score")

    plt.title("Oracle Complexity")

    plt.grid(axis="y")

    plt.savefig(
        "experiments/deutsch_jozsa/results/dj_oracle_complexity.png",
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()

# -------------------------------------------------
# Promise Robustness
# -------------------------------------------------

def plot_promise_probability(results):

    plt.figure(figsize=(11,5))

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

    plt.xticks(rotation=45)

    plt.ylabel("Average P(0...0)")

    plt.title("Promise Robustness")

    plt.ylim(0,1.05)

    plt.grid(axis="y")

    plt.savefig(
        "experiments/deutsch_jozsa/results/dj_promise_probability.png",
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()

# -------------------------------------------------
# Promise Distance
# -------------------------------------------------

def plot_promise_distance(results):

    plt.figure(figsize=(11,5))

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

    plt.xticks(rotation=45)

    plt.ylabel("Promise Distance")

    plt.title("Promise Distance from Deutsch–Jozsa Specification")

    plt.grid(axis="y")

    plt.savefig(
        "experiments/deutsch_jozsa/results/dj_promise_distance.png",
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()