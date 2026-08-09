"""
grover_oracles.py

Classical oracle definitions for Grover search.

Each oracle maps a bitstring state to:
    True  -> marked state
    False -> unmarked state

These correspond to the OracleInstance definitions
used in the Rocq verification framework.
"""

import random
from typing import List, Callable
from ..semantic.oracles import (
    OracleInstance,
    OracleKind
)

BitString = str


# ============================================================
# Helper Functions
# ============================================================

def bitstring_to_int(bits: BitString) -> int:
    """
    Convert bitstring representation to integer.

    Example:
        [1,0,1] -> 5
    """

    value = 0

    for bit in bits:
        value = (value << 1) | bit

    return value



def all_bitstrings(n: int):

    states = []

    for i in range(2 ** n):

        states.append(
            format(i, f"0{n}b")
        )

    return states



# -------------------------------------------------
# Single marked state oracle
# -------------------------------------------------

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

def random_marked_oracle(n: int, number_marked: int):
    """
    Generates a random oracle containing
    a chosen number of marked states.
    """

    states = all_bitstrings(n)

    marked_states = random.sample(
        states,
        number_marked
    )

    return (
        multiple_marked_oracle(marked_states), 
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
    """
    Enumerates all states satisfying a predicate.

    Used for experiments where Grover is
    parameterised by a search predicate.
    """

    states = all_bitstrings(n)

    return [

        state

        for state in states

        if predicate(state)

    ]

# ============================================================
# Example Predicates
# ============================================================

def xor_first_two_bits(state: BitString):
    """
    Marks states where:

        x0 XOR x1 = 1
    """

    return (int(state[0]) ^ int(state[1])) == 1



def first_bit_is_one(state: BitString):
    """
    Marks half the database.

    Useful for testing many marked states.
    """

    return state[0] == "1"