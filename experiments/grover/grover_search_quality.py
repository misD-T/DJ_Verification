"""
Grover search quality experiment.

Measures probability concentration during Grover search.

For each iteration:

    - probability of all marked states
    - maximum probability among unmarked states

Supports:

    - single marked states
    - multiple marked states
    - predicate-generated states
"""


from dataclasses import dataclass


from .grover_simulator import (
    initial_state,
    grover_iteration
)



@dataclass
class SearchQualityResult:


    iteration: int

    marked_probability: float

    max_unmarked_probability: float



def convert_marked_states(marked_states):

    """
    Converts different marked state formats
    into integer indices.

    Accepts:

        "00001"

        [0,0,0,0,1]

        ["00000","11111"]

    """


    indices = []


    for state in marked_states:


        if isinstance(state, list):

            state = "".join(

                str(bit)

                for bit in state

            )


        indices.append(

            int(state,2)

        )


    return indices




def search_quality_experiment(

        qubits,

        marked_states,

        iterations

):


    state = initial_state(

        qubits

    )


    marked_indices = convert_marked_states(

        marked_states

    )


    results = []



    for i in range(iterations + 1):


        # Probability of all marked states

        marked_probability = sum(

            abs(state[index]) ** 2

            for index in marked_indices

        )



        # Probability of unmarked states

        unmarked_probabilities = [

            abs(state[index]) ** 2

            for index in range(len(state))

            if index not in marked_indices

        ]



        max_unmarked = max(

            unmarked_probabilities

        )



        results.append(

            SearchQualityResult(

                iteration=i,

                marked_probability=

                    marked_probability,

                max_unmarked_probability=

                    max_unmarked

            )

        )



        state = grover_iteration(

            state,

            marked_indices

        )



    return results
