"""
Grover scaling experiment.

Measures:

    - number of qubits
    - database size
    - optimal Grover iterations
    - runtime
    - final success probability

Supports:

    - single marked
    - multiple marked
    - random marked
    - predicate-generated marked states
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

        # ----------------------------------------------------
        # Generate marked states
        # ----------------------------------------------------

        if oracle_family == "single":

            marked_states = [
                "0" * n
            ]

        elif oracle_family == "multiple":

            marked_states = [
                "0" * n,
                "1" * n
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

        # ----------------------------------------------------
        # Optimal iterations
        # ----------------------------------------------------

        optimal = optimal_grover_iterations(
            n,
            len(marked_states)
        )

        # ----------------------------------------------------
        # Runtime
        # ----------------------------------------------------

        start = time.perf_counter()

        curve = probability_amplification(
            n,
            marked_states,
            optimal
        )

        runtime = (
            time.perf_counter()
            - start
        )

        # ----------------------------------------------------
        # Results
        # ----------------------------------------------------

        results.append(
            {
                "qubits": n,

                "database_size":
                    2 ** n,

                "marked_states":
                    len(marked_states),

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