"""
Grover search quality experiment.

Measures, after each Grover iteration:

    - total probability of marked states
    - maximum probability of any unmarked state
"""

from dataclasses import dataclass

from .grover_simulator import (
    initial_state,
    grover_iteration,
    convert_marked_states
)


@dataclass
class SearchQualityResult:

    iteration: int

    marked_probability: float

    max_unmarked_probability: float


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

    for i in range(
        iterations + 1
    ):

        marked_probability = sum(
            abs(state[index]) ** 2
            for index in marked_indices
        )

        unmarked_probabilities = [
            abs(state[index]) ** 2
            for index in range(
                len(state)
            )
            if index not in marked_indices
        ]

        max_unmarked = (
            max(unmarked_probabilities)
            if unmarked_probabilities
            else 0.0
        )

        results.append(
            SearchQualityResult(
                iteration=i,
                marked_probability=float(
                    marked_probability
                ),
                max_unmarked_probability=float(
                    max_unmarked
                )
            )
        )

        state = grover_iteration(
            state,
            marked_indices
        )

    return results