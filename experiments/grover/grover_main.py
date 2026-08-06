"""
Main execution file for Grover experiments.

Runs all Grover experiments across:
    - Single marked states
    - Multiple marked states
    - Random marked states
    - Predicate search
"""

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



    plot_scaling_runtime(
        results
    )


    plot_scaling_probability(
        results
    )





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



    for result in results:


        print(

            result.oracle,

            result.marked_states,

            result.final_probability

        )



    plot_oracle_evaluation(

        results

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



    comparison = {}



    for name, marked_states in experiments.items():


        print()

        print(name)

        print("-" * len(name))


        print(
            f"Marked states: {len(marked_states)}"
        )


        results = search_quality_experiment(

            qubits,

            marked_states,

            6

        )


        comparison[name] = results



        print()

        print(
            "Iteration | P(Marked) | Max Unmarked"
        )

        print(
            "-" * 40
        )


        for result in results:

            print(

                f"{result.iteration:<9}"
                f"{result.marked_probability:<12.4f}"
                f"{result.max_unmarked_probability:<15.4f}"

            )


    plot_search_quality(

        comparison

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


    print()

    print("Database")

    print("---------------------")


    for entry in result["database"]:

        marker = ""

        if entry.index == result["marked_state"]:

            marker = " <-- target"


        print(

            f"{entry.index} -> "
            f"{entry.value}"
            f"{marker}"

        )


    print()

    print("Search Result")

    print("---------------------")


    print(

        f"Target: "
        f"{result['target']}"

    )


    print(

        f"Marked state: "
        f"{result['marked_state']}"

    )


    print(

        f"Optimal iterations: "
        f"{result['optimal_iterations']}"

    )


    print(

        f"Success probability: "
        f"{float(result['final_probability']):.4f}"

    )


    print()

    print("Probability Evolution")

    print("---------------------")


    print(
        "Iteration | Probability"
    )

    print(
        "---------------------"
    )


    for iteration, probability in result["curve"]:

        print(

            f"{iteration:<9}"
            f"| {float(probability):.4f}"

        )





# ============================================================
# Main
# ============================================================


def main():


    run_single_marked_demo()


    run_probability_experiment()


    run_scaling()


    run_oracle_evaluation_experiment()


    run_search_quality()


    run_database_search()



if __name__ == "__main__":

    main()