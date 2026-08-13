"""
Main experimental driver for the Grover experiments.

Runs:

    1. Semantic verification
    2. Probability amplification
    3. Oracle evaluation
    4. Scaling
    5. Search quality
    6. Unsorted database search

All numerical experiments are written to CSV files and
visualised as PNG figures.
"""

from dataclasses import asdict


from .grover_verify import (
    run_test
)


from .grover_probability import (
    probability_amplification,
    optimal_grover_iterations
)


from .grover_oracle_evaluation import (
    run_oracle_evaluation as execute_oracle_evaluation
)


from .grover_scaling import (
    run_scaling_experiment
)


from .grover_search_quality import (
    search_quality_experiment
)


from .grover_search import (
    grover_database_search
)


from .grover_visualisation import (
    plot_probability_amplification,
    plot_oracle_evaluation,
    plot_scaling,
    plot_search_quality,
    plot_database_search
)


from ..util.result_writer import (
    save_results_csv
)


# ============================================================
# Experiment 1
# Semantic Verification
# ============================================================

def run_semantic_verification():

    print()

    print("=" * 80)

    print("Grover Semantic Verification")

    print("=" * 80)


    qubits = 5


    # --------------------------------------------------------
    # Single marked oracle
    # --------------------------------------------------------

    from .grover_oracles import (
        single_marked_oracle
    )


    oracle = single_marked_oracle(
        "00000"
    )


    result = run_test(
        qubits,
        oracle,
        verbose=True
    )


    save_results_csv(
        "grover_semantic_verification.csv",
        [result],
        output_dir="experiments/grover/results"
    )
    
    return result


# ============================================================
# Experiment 2
# Probability Amplification
# ============================================================

def run_probability_experiment():

    print()

    print("=" * 80)

    print("Grover Probability Amplification")

    print("=" * 80)


    qubits = 5


    marked_states = [
        "00000"
    ]


    iterations = optimal_grover_iterations(
        qubits,
        len(marked_states)
    )


    curve = probability_amplification(
        qubits,
        marked_states,
        iterations
    )


    results = [

        {
            "iteration":
                iteration,

            "probability":
                probability

        }

        for iteration, probability
        in curve

    ]


    for result in results:

        print(

            f"Iteration={result['iteration']:2} "

            f"Probability={result['probability']:.6f}"

        )


    save_results_csv(
        "grover_probability.csv",
        results,
        output_dir="experiments/grover/results"
    )


    plot_probability_amplification(
        curve
    )


    return results


# ============================================================
# Experiment 3
# Oracle Evaluation
# ============================================================

def run_oracle_evaluation():

    print()

    print("=" * 80)

    print("Grover Oracle Evaluation")

    print("=" * 80)


    results = execute_oracle_evaluation()


    for result in results:

        print(

            f"{result.oracle:18}"

            f"Marked={result.marked_states:3} "

            f"Iterations={result.optimal_iterations:3} "

            f"Probability={result.final_probability:.6f}"

        )


    save_results_csv(
        "grover_oracle_evaluation.csv",
        [
            asdict(result)
            for result in results
        ],
        output_dir="experiments/grover/results"
    )


    plot_oracle_evaluation(
        results
    )


    return results


# ============================================================
# Experiment 4
# Scaling
# ============================================================

def run_scaling():

    print()

    print("=" * 80)

    print("Grover Scaling Experiment")

    print("=" * 80)


    all_results = []


    for family in [

        "single",
        "multiple",
        "random",
        "predicate"

    ]:


        results = run_scaling_experiment(

            oracle_family=family,

            min_qubits=3,

            max_qubits=8

        )


        all_results.extend(
            results
        )


    for result in all_results:

        print(

            f"n={result['qubits']:2} "

            f"{result['oracle_family']:10} "

            f"N={result['database_size']:4} "

            f"Iterations={result['optimal_iterations']:3} "

            f"Runtime={result['runtime']:.6f}s "

            f"P={result['final_probability']:.6f}"

        )


    save_results_csv(
        "grover_scaling.csv",
        all_results,
        output_dir="experiments/grover/results"
    )


    plot_scaling(
        all_results
    )


    return all_results


# ============================================================
# Experiment 5
# Search Quality
# ============================================================

def run_search_quality():

    print()

    print("=" * 80)

    print("Grover Search Quality")

    print("=" * 80)


    qubits = 5


    marked_states = [

        "00000"

    ]


    iterations = optimal_grover_iterations(

        qubits,

        len(marked_states)

    )


    results = search_quality_experiment(

        qubits,

        marked_states,

        iterations

    )


    for result in results:

        print(

            f"Iteration={result.iteration:2} "

            f"Marked={result.marked_probability:.6f} "

            f"MaxUnmarked="

            f"{result.max_unmarked_probability:.6f}"

        )


    save_results_csv(
        "grover_search_quality.csv",
        [
            asdict(result)
            for result in results
        ],
        output_dir="experiments/grover/results"
    )


    plot_search_quality(
        results
    )


    return results


# ============================================================
# Experiment 6
# Database Search
# ============================================================

def run_database_search():

    print()

    print("=" * 80)

    print("Grover Unsorted Database Search")

    print("=" * 80)


    result = grover_database_search(
        "Cherry"
    )


    print(
        "Target:",
        result["target"]
    )


    print(
        "Marked state:",
        result["marked_state"]
    )


    print(
        "Database size:",
        result["database_size"]
    )


    print(
        "Qubits:",
        result["qubits"]
    )


    print(
        "Optimal iterations:",
        result["optimal_iterations"]
    )


    print(
        "Final probability:",
        f"{result['final_probability']:.6f}"
    )


    save_results_csv(
        "grover_database_search.csv",
        [
            {
                "target": result["target"],
                "marked_state": result["marked_state"],
                "database_size": result["database_size"],
                "qubits": result["qubits"],
                "optimal_iterations": result["optimal_iterations"],
                "final_probability": result["final_probability"]
            }
        ],
        output_dir="experiments/grover/results"
    )


    plot_database_search(
        result
    )


    return result


# ============================================================
# Main
# ============================================================

def main():

    run_semantic_verification()

    run_probability_experiment()

    run_oracle_evaluation()

    run_scaling()

    run_search_quality()

    run_database_search()


if __name__ == "__main__":

    main()

