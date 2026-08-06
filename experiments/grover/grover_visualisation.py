"""
Grover visualisation utilities.

Creates plots for Grover probability amplification.

Input:
    [(iteration, probability)]

Output:
    probability amplification graphs.
"""


import matplotlib.pyplot as plt



def plot_probability_amplification(
        comparison_results,
        optimal_iterations
):
    """
    Plot probability amplification for every oracle family.

    comparison_results:

        {

            "Single": [(iteration,p),...],

            "Multiple": [...],

            "Random": [...],

            "Predicate": [...]

        }

    """

    plt.figure(figsize=(9,6))

    for oracle_name, results in comparison_results.items():

        iterations = [

            x[0]

            for x in results

        ]

        probabilities = [

            x[1]

            for x in results

        ]

        plt.plot(

            iterations,

            probabilities,

            marker="o",

            label=oracle_name

        )

        if oracle_name in optimal_iterations:

            plt.axvline(

                optimal_iterations[oracle_name],

                linestyle="--",

                alpha=0.35

            )

    plt.xlabel("Grover Iteration")

    plt.ylabel("Probability of Marked State")

    plt.title("Grover Probability Amplification")

    plt.ylim(0,1.05)

    plt.grid(True)

    plt.legend()

    plt.savefig(

        "experiments/grover/results/grover_probability_amplification.png",

        dpi=300,

        bbox_inches="tight"

    )

    plt.close()

# -------------------------------------------------
# Scaling Runtime
# -------------------------------------------------

def plot_scaling_runtime(all_results):

    plt.figure(figsize=(8,5))

    for oracle_name, results in all_results.items():

        qubits = [

            r["qubits"]

            for r in results

        ]

        runtimes = [

            r["runtime"]

            for r in results

        ]

        plt.plot(

            qubits,

            runtimes,

            marker="o",

            label=oracle_name

        )

    plt.xlabel("Number of Qubits")

    plt.ylabel("Runtime (seconds)")

    plt.title("Grover Runtime Scaling")

    plt.grid(True)

    plt.legend()

    plt.savefig(

        "experiments/grover/results/grover_runtime_scaling.png",

        dpi=300,

        bbox_inches="tight"

    )

    plt.close()

# -------------------------------------------------
# Scaling Probability
# -------------------------------------------------

def plot_scaling_probability(all_results):

    plt.figure(figsize=(8,5))

    for oracle_name, results in all_results.items():

        qubits = [

            r["qubits"]

            for r in results

        ]

        probabilities = [

            r["final_probability"]

            for r in results

        ]

        plt.plot(

            qubits,

            probabilities,

            marker="o",

            label=oracle_name

        )

    plt.xlabel("Number of Qubits")

    plt.ylabel("Final Success Probability")

    plt.title("Grover Success Probability Scaling")

    plt.ylim(0,1.05)

    plt.grid(True)

    plt.legend()

    plt.savefig(

        "experiments/grover/results/grover_probability_scaling.png",

        dpi=300,

        bbox_inches="tight"

    )

    plt.close()

# ============================================================
# Oracle Evaluation Plot
# ============================================================


def plot_oracle_evaluation(results):
    """
    Plot final success probability
    for different Grover oracle families.
    """


    oracles = [
        result.oracle
        for result in results
    ]


    probabilities = [
        result.final_probability
        for result in results
    ]


    plt.figure(
        figsize=(8,5)
    )


    bars = plt.bar(
        oracles,
        probabilities
    )


    for bar, probability in zip(
            bars,
            probabilities
    ):

        plt.text(
            bar.get_x() + bar.get_width()/2,
            probability + 0.02,
            f"{probability:.4f}",
            ha="center"
        )


    plt.xlabel(
        "Oracle Family"
    )


    plt.ylabel(
        "Final Probability of Marked State"
    )


    plt.title(
        "Grover Oracle Family Evaluation"
    )


    plt.ylim(
        0,
        1.05
    )


    plt.xticks(
        rotation=45
    )


    plt.grid(
        axis="y"
    )


    plt.savefig(
        "experiments/grover/results/grover_oracle_evaluation.png",
        dpi=300,
        bbox_inches="tight"
    )


    plt.close()

# ============================================================
# Search Quality Plot
# ============================================================

def plot_search_quality(comparison):

    plt.figure(figsize=(9,6))

    for oracle_name, results in comparison.items():

        iterations = [

            r.iteration

            for r in results

        ]

        probabilities = [

            r.marked_probability

            for r in results

        ]

        plt.plot(

            iterations,

            probabilities,

            marker="o",

            label=oracle_name

        )

    plt.xlabel("Grover Iteration")

    plt.ylabel("Probability of Marked State")

    plt.title("Grover Search Quality")

    plt.ylim(0,1.05)

    plt.grid(True)

    plt.legend()

    plt.savefig(

        "experiments/grover/results/grover_search_quality.png",

        dpi=300,

        bbox_inches="tight"

    )

    plt.close()