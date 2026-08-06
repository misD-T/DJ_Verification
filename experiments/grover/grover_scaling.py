"""
Grover scaling experiment.

Measures:

    - runtime
    - database size
    - optimal iterations
    - final success probability


Supports all oracle families.
"""


import time


from .grover_probability import (

    probability_amplification,

    optimal_grover_iterations

)


from .grover_oracles import (

    random_marked_oracle,

    predicate_marked_states,

    xor_first_two_bits

)




def run_scaling_experiment(

        oracle_family="single",

        min_qubits=3,

        max_qubits=8

):


    results = []



    for n in range(

            min_qubits,

            max_qubits + 1

    ):


        # -----------------------------
        # Generate oracle states
        # -----------------------------


        if oracle_family == "single":


            marked_states = [

                [0] * n

            ]



        elif oracle_family == "multiple":


            marked_states = [

                [0] * n,

                [1] * n

            ]



        elif oracle_family == "random":


            _, marked_states = random_marked_oracle(

                n,

                3

            )



        elif oracle_family == "predicate":


            marked_states = predicate_marked_states(

                n,

                xor_first_two_bits

            )



        else:

            raise ValueError(

                "Unknown oracle family"

            )




        optimal = optimal_grover_iterations(

            n,

            len(marked_states)

        )



        start = time.perf_counter()



        curve = probability_amplification(

            n,

            marked_states,

            optimal

        )



        runtime = (

            time.perf_counter()

            -

            start

        )



        results.append(

            {

                "qubits":
                    n,

                "database_size":
                    2 ** n,

                "optimal_iterations":
                    optimal,

                "runtime":
                    runtime,

                "final_probability":
                    curve[-1][1],

                "oracle_family":
                    oracle_family

            }

        )



    return results