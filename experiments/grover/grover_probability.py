"""
Grover probability amplification experiment.

Computes probability evolution after each Grover iteration.

Supports:

    - single marked states
    - multiple marked states
    - random marked states
    - predicate-generated marked states

Corresponds to:

GroverProbabilityExperiment.v
"""


import math


from .grover_simulator import (

    initial_state,

    grover_iteration,

    probability,

    convert_marked_states

)



# -------------------------------------------------
# Optimal Grover Iterations
# -------------------------------------------------

def optimal_grover_iterations(
        qubits,
        marked_count=1
):


    N = 2 ** qubits


    return int(

        math.floor(

            (math.pi / 4)

            *

            math.sqrt(

                N / marked_count

            )

        )

    )



# -------------------------------------------------
# Probability Amplification
# -------------------------------------------------

def probability_amplification(

        qubits,

        marked_states,

        iterations

):


    """
    Run Grover amplitude amplification.


    Parameters:

        qubits:
            number of qubits


        marked_states:

            Example:

            [
              [0,0,0],
              [1,1,1]
            ]


        iterations:
            number of Grover iterations


    Returns:

        [
          (iteration, probability)
        ]

    """



    state = initial_state(

        qubits

    )



    marked_indices = convert_marked_states(

        marked_states

    )



    results = []



    for i in range(

            iterations + 1

    ):


        p = probability(

            state,

            marked_indices

        )


        results.append(

            (

                i,

                p

            )

        )



        state = grover_iteration(

            state,

            marked_indices

        )



    return results