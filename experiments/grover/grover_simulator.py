"""
Numerical Grover simulator.

Experimental numerical backend for Grover search.

Supports:

    - single marked states
    - multiple marked states
    - arbitrary marked-state sets

This simulator is separate from the semantic verification
framework. It is used to obtain numerical probability and
runtime measurements for the experimental evaluation.
"""

import numpy as np


# ============================================================
# Helpers
# ============================================================

def bitstring_to_int(bits):
    """
    Convert a bitstring into its integer computational-basis index.

    Accepts:

        "010"

    or:

        [0, 1, 0]
    """

    if isinstance(bits, str):

        return int(bits, 2)

    value = 0

    for bit in bits:

        value = (
            value << 1
        ) | int(bit)

    return value


def convert_marked_states(marked_states):
    """
    Convert marked states into computational-basis indices.

    Accepts:

        ["000", "111"]

    or:

        [[0, 0, 0], [1, 1, 1]]

    Returns:

        [0, 7]
    """

    return [
        bitstring_to_int(state)
        for state in marked_states
    ]


# ============================================================
# Initial State
# ============================================================

def initial_state(n):
    """
    Create the uniform superposition state used by the
    numerical Grover simulator.

    The state contains 2^n amplitudes.
    """

    N = 2 ** n

    return np.ones(
        N,
        dtype=complex
    ) / np.sqrt(N)


# ============================================================
# Oracle
# ============================================================

def oracle_operator(
    state,
    marked_states
):
    """
    Apply the Grover phase oracle.

    Marked amplitudes receive a phase flip:

        alpha -> -alpha
    """

    state = state.copy()

    for index in marked_states:

        state[index] *= -1

    return state


# ============================================================
# Diffusion
# ============================================================

def diffusion_operator(state):
    """
    Apply inversion about the mean.
    """

    mean = np.mean(state)

    return (
        2 * mean
        - state
    )


# ============================================================
# Grover Iteration
# ============================================================

def grover_iteration(
    state,
    marked_states
):
    """
    Perform one complete Grover iteration:

        Oracle
            |
            v
        Diffusion
    """

    state = oracle_operator(
        state,
        marked_states
    )

    return diffusion_operator(
        state
    )


# ============================================================
# Probability
# ============================================================

def probability(
    state,
    marked_states
):
    """
    Calculate total probability of measuring one
    of the marked states.
    """

    return sum(
        abs(state[i]) ** 2
        for i in marked_states
    )