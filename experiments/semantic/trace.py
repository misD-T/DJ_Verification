"""
Semantic execution trace.

This module records the sequence of semantic operators
applied during quantum program execution.

The trace corresponds to the Rocq field:

    qs_history : list string

and provides a reusable mechanism for analysing
algorithm execution behaviour.
"""


from dataclasses import dataclass, field
from datetime import datetime



@dataclass
class SemanticTrace:
    """
    Records semantic execution transitions.

    Each operation represents an abstract semantic
    transition such as:

        InitialState
        Hadamard
        Oracle
        Diffusion
        Measurement

    The trace is independent of the quantum backend.
    """


    operations: list[str] = field(
        default_factory=list
    )


    timestamps: list[float] = field(
        default_factory=list
    )


    # -------------------------------------------------
    # Add operation
    # -------------------------------------------------

    def add(
        self,
        operation: str
    ):
        """
        Append a semantic transition.

        Equivalent to adding an element to:

            qs_history
        """

        self.operations.append(
            operation
        )


        self.timestamps.append(
            datetime.now().timestamp()
        )



    # -------------------------------------------------
    # Last operation
    # -------------------------------------------------

    def last(self):
        """
        Return the most recent semantic operation.
        """

        if len(self.operations) == 0:
            return None


        return self.operations[-1]



    # -------------------------------------------------
    # Length
    # -------------------------------------------------

    def size(self):
        """
        Return number of semantic transitions.
        """

        return len(
            self.operations
        )



    # -------------------------------------------------
    # Reset
    # -------------------------------------------------

    def clear(self):
        """
        Clear execution trace.
        """

        self.operations.clear()

        self.timestamps.clear()



    # -------------------------------------------------
    # Export
    # -------------------------------------------------

    def to_list(self):
        """
        Return chronological semantic trace.
        """

        return self.operations.copy()



    def summary(self):
        """
        Return readable trace summary.
        """

        return {

            "steps":
                len(self.operations),

            "operations":
                self.operations
        }