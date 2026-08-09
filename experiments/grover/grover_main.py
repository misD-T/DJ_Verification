"""
Main execution file for Grover experiments.

Runs all Grover experiments across:
    - Single marked states
    - Multiple marked states
    - Random marked states
    - Predicate search
"""


from ..util.result_writer import save_results_csv

from .grover_oracles import (

    single_marked_oracle,
    multiple_marked_oracle,
    random_marked_oracle,
    predicate_oracle,
    predicate_marked_states,
    xor_first_two_bits

)


from .grover_circuit import (
    GroverCircuit
)


from .grover_probability import (

    probability_amplification,
    optimal_grover_iterations

)


from .grover_scaling import (
    run_scaling_experiment
)


from .grover_oracle_evaluation import (
    run_oracle_evaluation
)


from .grover_search_quality import (
    search_quality_experiment
)


from .grover_search import (
    grover_database_search
)


from .grover_visualisation import (

    plot_probability_amplification,
    plot_scaling_runtime,
    plot_scaling_probability,
    plot_oracle_evaluation,
    plot_search_quality

)

from .grover_verify import run_test


# ============================================================
# Experiment 0
# Semantic Verification
# ============================================================

def run_semantic_verification():

    print()
    print("=" * 60)
    print("Experiment 0 : Semantic Verification")
    print("=" * 60)

    qubits = 5

    oracles = [

        single_marked_oracle(
            [0, 0, 0, 0, 0]
        ),

        multiple_marked_oracle(
            [
                [0, 0, 0, 0, 0],
                [1, 1, 1, 1, 1]
            ]
        ),

        random_marked_oracle(
            qubits,
            3
        )[0],

        predicate_oracle(
            xor_first_two_bits
        )

    ]

    results = []


    for oracle in oracles:

        result = run_test(
            qubits,
            oracle,
            verbose=True
        )

        results.append(result)



    save_results_csv(
        "grover_semantic_verification.csv",
        results
    )

# ============================================================
# Semantic Demonstration
# ============================================================


def run_single_marked_demo():


    print()
    print("Grover Single Marked State Demo")
    print("--------------------------------")


    qubits = 5


    marked = [
        0,0,0,0,0
    ]


    oracle = single_marked_oracle(
        marked
    )


    state = GroverCircuit(

        qubits,

        oracle,

        1

    )


    print(
        state.summary()
    )




# ============================================================
# Experiment 1
# Probability Amplification
# ============================================================


def run_probability_experiment():


    print()
    print("="*60)
    print("Experiment 1 : Probability Amplification")
    print("="*60)


    qubits = 5


    experiments = {


        "Single Marked":

        [
            [
                0,0,0,0,0
            ]
        ],


        "Multiple Marked":

        [

            [
                0,0,0,0,0
            ],

            [
                1,1,1,1,1
            ]

        ],


        "Random Marked":

        random_marked_oracle(

            qubits,

            3

        )[1],



        "Predicate":

        predicate_marked_states(

            qubits,

            xor_first_two_bits

        )

    }



    comparison_results = {}

    optimal_iterations = {}



    for name, marked_states in experiments.items():


        optimal = optimal_grover_iterations(

            qubits,

            len(marked_states)

        )


        results = probability_amplification(

            qubits,

            marked_states,

            optimal + 2

        )


        comparison_results[name] = results

        optimal_iterations[name] = optimal



        print()
        print(name)
        print("-"*len(name))


        print(
            f"Marked states: {len(marked_states)}"
        )


        print(
            f"Optimal iterations: {optimal}"
        )


        for iteration, probability in results:


            print(

                f"{iteration:<5} "
                f"{probability:.4f}"

            )


    rows = []


    for name, data in comparison_results.items():

        for iteration, probability in data:

            rows.append({

                "experiment":
                    name,

                "iteration":
                    iteration,

                "probability":
                    probability,

                "optimal_iteration":
                    optimal_iterations[name]

            })


    save_results_csv(
        "grover_probability_amplification.csv",
        rows
    )



    plot_probability_amplification(
        comparison_results,
        optimal_iterations
    )




# ============================================================
# Experiment 2
# Scaling
# ============================================================


def run_scaling():


    print()
    print("="*60)
    print("Experiment 2 : Scaling")
    print("="*60)



    families = [

        "single",

        "multiple",

        "random",

        "predicate"

    ]



    results = {}



    for family in families:


        print()

        print(
            "Oracle:",
            family
        )


        family_results = run_scaling_experiment(

            oracle_family=family

        )


        results[family] = family_results



        for r in family_results:


            print(

                r["qubits"],

                r["runtime"],

                r["final_probability"]

            )



    rows=[]


    for family,data in results.items():

        for r in data:

            rows.append({

                "oracle_family":
                    family,

                "qubits":
                    r["qubits"],

                "runtime":
                    r["runtime"],

                "success_probability":
                    r["final_probability"]

            })



    save_results_csv(
        "grover_scaling.csv",
        rows
    )



    plot_scaling_runtime(results)

    plot_scaling_probability(results)





# ============================================================
# Experiment 3
# Oracle Evaluation
# ============================================================


def run_oracle_evaluation_experiment():


    print()
    print("="*60)
    print("Experiment 3 : Oracle Evaluation")
    print("="*60)



    results = run_oracle_evaluation(

        qubits=5

    )
    rows=[]


    for r in results:

        rows.append({

            "oracle":
                r.oracle,

            "marked_states":
                r.marked_states,

            "success_probability":
                r.final_probability

        })


    save_results_csv(
        "grover_oracle_evaluation.csv",
        rows
    )





# -------------------------------------------------
# Experiment 4
# Search Quality
# -------------------------------------------------

def run_search_quality():

    print()
    print("=" * 60)
    print("Experiment 4 : Search Quality")
    print("=" * 60)


    qubits = 5


    experiments = {


        # -----------------------------------------
        # Single marked state
        # -----------------------------------------

        "Single":

        [
            "00000"
        ],



        # -----------------------------------------
        # Multiple marked states
        # -----------------------------------------

        "Multiple":

        [
            "00000",
            "11111"
        ],



        # -----------------------------------------
        # Random marked states
        # -----------------------------------------

        "Random":

        random_marked_oracle(

            qubits,
            3

        )[1],



        # -----------------------------------------
        # Predicate oracle
        # -----------------------------------------

        "Predicate":

        predicate_marked_states(

            qubits,

            xor_first_two_bits

        )

    }



    comparison = {

        "Single":
            [
                "00000"
            ],

        "Multiple":
            [
                "00000",
                "11111"
            ],

        "Random":
            random_marked_oracle(
                qubits,
                3
            )[1],

        "Predicate":
            predicate_marked_states(
                qubits,
                xor_first_two_bits
            )

    }


    search_results = {}


    for name, marked_states in comparison.items():


        results = search_quality_experiment(

            qubits,

            marked_states,

            6

        )


        search_results[name] = results



    rows=[]


    for experiment,data in search_results.items():

        for r in data:

            rows.append({

                "oracle":

                    experiment,

                "iteration":

                    r.iteration,

                "marked_probability":

                    r.marked_probability,

                "max_unmarked_probability":

                    r.max_unmarked_probability

            })


    save_results_csv(
        "grover_search_quality.csv",
        rows
    )
    
    plot_search_quality(
    search_results
    )


# -------------------------------------------------
# Experiment 5
# Database Search
# -------------------------------------------------

def run_database_search():

    print()

    print("=" * 60)

    print(
        "Experiment 5 : Database Search"
    )

    print("=" * 60)


    result = grover_database_search(

        "Cherry"

    )


    rows=[]


    for iteration, probability in result["curve"]:

        rows.append({

            "target":
                result["target"],

            "marked_state":
                result["marked_state"],

            "iteration":
                iteration,

            "probability":
                probability

        })


    save_results_csv(
        "grover_database_search.csv",
        rows
    )




# ============================================================
# Main
# ============================================================

def main():

    # -------------------------------------------------
    # Semantic Demonstration
    # -------------------------------------------------

    run_single_marked_demo()

    # -------------------------------------------------
    # Semantic Verification
    # -------------------------------------------------

    run_semantic_verification()

    # -------------------------------------------------
    # Numerical Experiments
    # -------------------------------------------------

    run_probability_experiment()

    run_scaling()

    run_oracle_evaluation_experiment()

    run_search_quality()

    run_database_search()


if __name__ == "__main__":
    main()