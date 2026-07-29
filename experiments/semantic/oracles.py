"""
Semantic oracle representation.

Corresponds to the Rocq definitions:

Inductive OracleKind := ...

Record OracleInstance :=
{
    oracle_kind : OracleKind;
    oracle_function : Oracle
}.

The semantic layer defines the reusable oracle abstraction.
Concrete oracle implementations are provided by algorithm modules.
"""


from dataclasses import dataclass
from enum import Enum
from typing import Callable



# -------------------------------------------------
# Oracle Kinds
#
# Corresponds to Rocq:
#
# Inductive OracleKind :=
#
# -------------------------------------------------

class OracleKind(Enum):

    CONSTANT_ZERO = "ConstantZero"

    CONSTANT_ONE = "ConstantOne"


    FIRST_BIT = "FirstBit"

    PARITY = "Parity"

    FULL_PARITY = "FullParity"

    XOR_TWO_BITS = "XorTwoBits"


    AFFINE = "Affine"


    AND_XOR = "AndXor"


    EXAMPLE_BALANCED = "ExampleBalanced"


    SINGLE_MARKED = "SingleMarked"

    MAJORITY = "Majority"


    ALTERNATING = "Alternating"


    GROVER = "Grover"



# -------------------------------------------------
# Oracle Function Type
#
# Equivalent to Rocq:
#
# Definition Oracle := ...
#
# -------------------------------------------------

OracleFunction = Callable[[str], bool]



# -------------------------------------------------
# Oracle Instance
#
# Corresponds to Rocq:
#
# Record OracleInstance :=
# {
#   oracle_kind : OracleKind;
#   oracle_function : Oracle
# }.
#
# -------------------------------------------------

@dataclass
class OracleInstance:

    kind: OracleKind

    function: OracleFunction



    def evaluate(
        self,
        bits: str
    ) -> bool:
        """
        Evaluate oracle function.

        Equivalent to:

        oracle_function f bits
        """

        return self.function(bits)