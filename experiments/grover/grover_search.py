"""
Grover unsorted database search demonstration.

Maps a classical database search problem
onto Grover's search space.

Example:

Database:

000 -> Apple
001 -> Banana
010 -> Cherry

Target:

Cherry

Grover searches for:

010
"""


from dataclasses import dataclass


from .grover_probability import (
    probability_amplification,
    optimal_grover_iterations
)



# ============================================================
# Database Representation
# ============================================================


@dataclass
class DatabaseEntry:

    index: str

    value: str



# ============================================================
# Database Creation
# ============================================================


def create_database():

    """
    Create example unsorted database.

    The binary index represents the
    Grover search state.
    """


    return [

        DatabaseEntry(
            "000",
            "Apple"
        ),

        DatabaseEntry(
            "001",
            "Banana"
        ),

        DatabaseEntry(
            "010",
            "Cherry"
        ),

        DatabaseEntry(
            "011",
            "Orange"
        ),

        DatabaseEntry(
            "100",
            "Pear"
        ),

        DatabaseEntry(
            "101",
            "Mango"
        ),

        DatabaseEntry(
            "110",
            "Grape"
        ),

        DatabaseEntry(
            "111",
            "Peach"
        )

    ]



# ============================================================
# Classical Lookup
# ============================================================


def find_index(
        database,
        item
):
    """
    Convert database item into
    Grover marked state.
    """


    for entry in database:

        if entry.value == item:

            return entry.index


    return None



# ============================================================
# Grover Search Experiment
# ============================================================


def grover_database_search(
        target
):


    database = create_database()


    marked_state = find_index(
        database,
        target
    )


    if marked_state is None:

        raise ValueError(
            "Target not found"
        )


    qubits = len(marked_state)


    marked_bits = [

        int(bit)

        for bit in marked_state

    ]


    optimal = optimal_grover_iterations(
        qubits
    )


    curve = probability_amplification(

        qubits,

        [
            marked_bits
        ],

        optimal

    )


    return {

        "database": database,

        "target": target,

        "marked_state": marked_state,

        "optimal_iterations":
            optimal,

        "final_probability":
            curve[-1][1],

        "curve":
            curve

    }
