"""
Grover oracle evaluation experiment.

Evaluates:

    - Single marked
    - Multiple marked
    - Random marked
    - Predicate

using the same Grover simulator.
"""


from dataclasses import dataclass



from .grover_probability import (

    probability_amplification,

    optimal_grover_iterations

)


from .grover_oracles import (

    random_marked_oracle,

    predicate_marked_states,

    xor_first_two_bits

)



@dataclass
class OracleEvaluationResult:


    oracle: str

    marked_states: int

    optimal_iterations: int

    final_probability: float





def evaluate_oracle(

        name,

        qubits,

        marked_states

):


    optimal = optimal_grover_iterations(

        qubits,

        len(marked_states)

    )


    curve = probability_amplification(

        qubits,

        marked_states,

        optimal

    )


    return OracleEvaluationResult(

        oracle=name,

        marked_states=len(marked_states),

        optimal_iterations=optimal,

        final_probability=
            curve[-1][1]

    )





def run_oracle_evaluation(

        qubits=5

):


    results = []



    # ------------------------------------
    # Single marked
    # ------------------------------------

    results.append(

        evaluate_oracle(

            "Single Marked",

            qubits,

            [

                [0] * qubits

            ]

        )

    )



    # ------------------------------------
    # Multiple marked
    # ------------------------------------

    results.append(

        evaluate_oracle(

            "Multiple Marked",

            qubits,

            [

                [0] * qubits,

                [1] * qubits

            ]

        )

    )



    # ------------------------------------
    # Random marked
    # ------------------------------------

    random_oracle, random_states = random_marked_oracle(

        qubits,

        3

    )


    results.append(

        evaluate_oracle(

            "Random Marked",

            qubits,

            random_states

        )

    )



    # ------------------------------------
    # Predicate
    # ------------------------------------

    predicate_states = predicate_marked_states(

        qubits,

        xor_first_two_bits

    )


    results.append(

        evaluate_oracle(

            "Predicate",

            qubits,

            predicate_states

        )

    )


    return results
