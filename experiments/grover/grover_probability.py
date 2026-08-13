"""
Grover probability amplification experiment.

Measures the probability of obtaining one of the marked
states after each Grover iteration.

Supports:

    - single marked states
    - multiple marked states
    - random marked states
    - predicate-generated marked states
"""

from .grover_simulator import (
    initial_state,
    grover_iteration,
    probability,
    convert_marked_states
)


# ============================================================
# Optimal Grover Iterations
# ============================================================

def optimal_grover_iterations(
    qubits,
    marked_count=1
):
    """
    Calculate the standard approximate optimal number
    of Grover iterations.

        floor(pi/4 * sqrt(N/M))

    where:

        N = database size
        M = number of marked states
    """

    if marked_count <= 0:
        raise ValueError(
            "marked_count must be greater than zero"
        )

    N = 2 ** qubits

    return int(
        (3.141592653589793 / 4)
        * (
            N / marked_count
        ) ** 0.5
    )


# ============================================================
# Probability Amplification
# ============================================================

def probability_amplification(
    qubits,
    marked_states,
    iterations
):
    """
    Measure marked-state probability after every
    Grover iteration.

    Returns:

        [
            (iteration, probability),
            ...
        ]
    """

    if not marked_states:
        raise ValueError(
            "At least one marked state is required."
        )

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
                float(p)
            )
        )

        state = grover_iteration(
            state,
            marked_indices
        )

    return results