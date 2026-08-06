"""
Numerical Grover simulator.

Supports:

    - single marked states
    - multiple marked states
    - arbitrary marked-state sets

Experimental backend.
"""

import numpy as np



# ============================================================
# Helpers
# ============================================================


def bitstring_to_int(bits):

    value = 0

    for bit in bits:

        value = (
            value << 1
        ) | int(bit)

    return value



def convert_marked_states(marked_states):

    """
    Convert:

        [
          [0,1,0],
          [1,1,1]
        ]

    into:

        [
          2,
          7
        ]

    """

    return [

        bitstring_to_int(state)

        for state in marked_states

    ]



# ============================================================
# Initial State
# ============================================================


def initial_state(n):

    N = 2 ** n

    return np.ones(
        N
    ) / np.sqrt(N)



# ============================================================
# Oracle
# ============================================================


def oracle_operator(
        state,
        marked_states
):


    state = state.copy()


    for index in marked_states:

        state[index] *= -1


    return state



# ============================================================
# Diffusion
# ============================================================


def diffusion_operator(state):

    mean = np.mean(state)

    return 2 * mean - state



# ============================================================
# Grover Iteration
# ============================================================


def grover_iteration(
        state,
        marked_states
):


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


    return sum(

        abs(state[i]) ** 2

        for i in marked_states

    )