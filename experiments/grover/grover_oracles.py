"""
Classical oracle definitions for Grover search.

Each oracle maps a computational-basis bitstring to:

    True  -> marked
    False -> unmarked

These correspond to the OracleInstance definitions
used by the semantic verification framework.
"""

import random

from typing import (
    List,
    Callable
)

from ..semantic.oracles import (
    OracleInstance,
    OracleKind
)


BitString = str


# ============================================================
# Helper Functions
# ============================================================

def all_bitstrings(n: int):

    return [
        format(
            i,
            f"0{n}b"
        )
        for i in range(
            2 ** n
        )
    ]


# ============================================================
# Single Marked Oracle
# ============================================================

def single_marked_oracle(
    marked: BitString
) -> OracleInstance:

    def oracle_function(
        x: BitString
    ) -> bool:

        return x == marked

    return OracleInstance(
        kind=OracleKind.SINGLE_MARKED,
        function=oracle_function
    )


# ============================================================
# Multiple Marked Oracle
# ============================================================

def multiple_marked_oracle(
    marked_states: List[BitString]
) -> OracleInstance:

    def oracle_function(
        state: BitString
    ) -> bool:

        return state in marked_states

    return OracleInstance(
        kind=OracleKind.MULTIPLE_MARKED,
        function=oracle_function
    )


# ============================================================
# Random Marked Oracle
# ============================================================

def random_marked_oracle(
    n: int,
    number_marked: int
):

    states = all_bitstrings(n)

    if number_marked <= 0:
        raise ValueError(
            "number_marked must be greater than zero"
        )

    if number_marked > len(states):
        raise ValueError(
            "number_marked cannot exceed database size"
        )

    marked_states = random.sample(
        states,
        number_marked
    )

    return (
        multiple_marked_oracle(
            marked_states
        ),
        marked_states
    )


# ============================================================
# Predicate Oracle
# ============================================================

def predicate_oracle(
    predicate: Callable[[BitString], bool]
) -> OracleInstance:

    def oracle_function(
        state: BitString
    ) -> bool:

        return predicate(state)

    return OracleInstance(
        kind=OracleKind.PREDICATE,
        function=oracle_function
    )


# ============================================================
# Predicate Marked State Extraction
# ============================================================

def predicate_marked_states(
    n: int,
    predicate: Callable[[BitString], bool]
):

    states = all_bitstrings(n)

    return [
        state
        for state in states
        if predicate(state)
    ]


# ============================================================
# Example Predicates
# ============================================================

def xor_first_two_bits(
    state: BitString
):

    return (
        int(state[0])
        ^ int(state[1])
    ) == 1


def first_bit_is_one(
    state: BitString
):

    return state[0] == "1"