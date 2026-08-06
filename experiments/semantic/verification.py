"""
Reusable semantic verification framework.

This module provides the reusable verification infrastructure
used by the semantic framework.

It corresponds to the verification layer of the Rocq framework
and is intentionally independent of any particular quantum
algorithm.

Algorithm-specific correctness properties are implemented
separately by individual algorithms (e.g. Deutsch–Jozsa,
Grover).
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass

# ============================================================
# Correctness Properties
# ============================================================

class Property(ABC):
    """
    Abstract semantic correctness property.

    Every algorithm defines its own concrete properties by
    subclassing Property.
    """

    def __init__(self, name: str):

        self.name = name


    @abstractmethod
    def check(self, output):
        """
        Evaluate whether the property holds.
        """
        pass


# ============================================================
# Verification Result
# ============================================================

@dataclass
class VerificationResult:
    """
    Result of semantic verification.
    """

    property_name: str

    output: str

    verified: bool | None


# ============================================================
# Verification Engine
# ============================================================

def verify_property(
    property_obj: Property,
    output
) -> VerificationResult:
    """
    Evaluate a semantic correctness property.
    """

    result = property_obj.check(output)

    return VerificationResult(

        property_name=property_obj.name,

        output=output,

        verified=result
    )


# ============================================================
# Quantum Dynamic Logic (QDL)
# ============================================================

class Proposition(ABC):
    """
    Abstract Quantum Dynamic Logic proposition.

    A proposition represents the postcondition that must
    hold after execution of a quantum program.
    """

    @abstractmethod
    def evaluate(self, output):
        pass



@dataclass
class QDLFormula:
    """
    Quantum Dynamic Logic formula.

    Represents:

        Assumption -> [Program] Proposition

    Corresponds to the semantic judgement:

        P -> [alpha] Q

    where:

        P:
            Program assumption

        alpha:
            Quantum program

        Q:
            Correctness proposition
    """

    assumption: str

    program: str

    proposition: Proposition


    def verify(
        self,
        output: str
    ) -> bool:

        """
        Evaluate the postcondition.

        This corresponds to checking whether
        the resulting program state satisfies Q.
        """

        return self.proposition.evaluate(
            output
        )


    def __str__(self):

        return (
            f"{self.assumption}"
            f" -> [{self.program}] "
            f"{self.proposition}"
        )



# ============================================================
# Hoare–Heisenberg Logic
# ============================================================

class Predicate(ABC):
    """
    Abstract Hoare–Heisenberg predicate.

    Represents a property over the final quantum state.
    """

    @abstractmethod
    def evaluate(
        self,
        output
    ):
        pass



@dataclass
class HoareTriple:
    """
    Hoare–Heisenberg triple.

    Represents:

        {Precondition} Program {Predicate}

    Corresponding to:

        {P} alpha {Q}

    where:

        P:
            Initial state assumption

        alpha:
            Quantum program execution

        Q:
            Final state predicate
    """

    precondition: str

    program: str

    predicate: Predicate


    def verify(
        self,
        output: str
    ) -> bool:

        """
        Check whether the final output
        satisfies the predicate.
        """

        return self.predicate.evaluate(
            output
        )


    def __str__(self):

        return (
            f"{{{self.precondition}}} "
            f"{self.program} "
            f"{{{self.predicate}}}"
        )