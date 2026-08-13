"""
Deutsch-Jozsa oracle implementations.

This module contains algorithm-specific oracle behaviour.

The semantic representation of an oracle is defined in:

    semantic.oracle

This file provides concrete instances used by:
    - oracle verification
    - promise robustness experiments
    - oracle complexity experiments
"""


import numpy as np


from ..semantic.oracles import (
    OracleKind,
    OracleInstance
)



# -------------------------------------------------
# Oracle Analysis
# -------------------------------------------------

def is_balanced(f):

    ones = np.sum(f)

    return ones == len(f) / 2



def oracle_class(
    oracle_type,
    target_bits
):
    """
    Classify an oracle according to its actual truth table
    and the Deutsch-Jozsa promise.

    Returns:
        Constant  - all outputs are identical
        Balanced  - exactly half of inputs map to 1
        Invalid   - violates the Deutsch-Jozsa promise
    """

    f = dj_function(
        oracle_type,
        target_bits,
        verbose=False
    )

    ones = int(np.sum(f))
    total = len(f)

    if ones == 0 or ones == total:
        return "Constant"

    if ones * 2 == total:
        return "Balanced"

    return "Invalid"


def oracle_structural_complexity(
    oracle_type,
    target_bits
):
    """
    Return a structural complexity score for the oracle.

    The score represents the number of input bits directly
    involved in the oracle's Boolean construction.

    This is an experimental structural measure rather than
    a formal computational complexity measure.
    """

    scores = {

        "constant_zero": 0,

        "constant_one": 0,

        "first_bit": 1,

        "alternating": 1,

        "xor_two_bits": 2,

        "parity": target_bits,

        "full_parity": target_bits,

        "affine": target_bits,

        "and_xor": target_bits,

        "random_balanced": 2 ** target_bits
    }

    return scores.get(
        oracle_type,
        None
    )



def oracle_bias(
    oracle_type,
    target_bits
):

    f = dj_function(
        oracle_type,
        target_bits,
        verbose=False
    )


    return np.sum(f) / len(f)



# -------------------------------------------------
# Truth Table Generation
#
# Used for experiments
# -------------------------------------------------

def dj_function(
    oracle_type,
    target_bits,
    verbose=False
):

    n = 2 ** target_bits



    if oracle_type == "constant_zero":

        f = np.zeros(n)



    elif oracle_type == "constant_one":

        f = np.ones(n)



    elif oracle_type in [
        "first_bit"
    ]:

        f = np.zeros(n)

        for x in range(n):

            bits = format(
                x,
                f"0{target_bits}b"
            )

            f[x] = int(bits[0])



    elif oracle_type in [
        "parity",
        "full_parity"
    ]:

        f = np.zeros(n)

        for x in range(n):

            bits = format(
                x,
                f"0{target_bits}b"
            )

            value = 0

            for bit in bits:
                value ^= int(bit)

            f[x] = value



    elif oracle_type == "xor_two_bits":

        f = np.zeros(n)

        for x in range(n):

            bits = format(
                x,
                f"0{target_bits}b"
            )

            f[x] = (
                int(bits[0])
                ^
                int(bits[1])
            )



    elif oracle_type == "alternating":

        f = np.array(
            [
                i % 2
                for i in range(n)
            ]
        )



    elif oracle_type == "affine":

        f = np.zeros(n)

        a = [
            1 if i % 2 == 0 else 0
            for i in range(target_bits)
        ]

        b = 1


        for x in range(n):

            bits = format(
                x,
                f"0{target_bits}b"
            )

            value = b


            for i in range(target_bits):

                value ^= (
                    a[i]
                    &
                    int(bits[i])
                )


            f[x] = value



    elif oracle_type == "and_xor":

        f = np.zeros(n)

        for x in range(n):

            bits = format(
                x,
                f"0{target_bits}b"
            )

            value = (
                int(bits[0])
                &
                int(bits[1])
            )


            for bit in bits[2:]:

                value ^= int(bit)


            f[x] = value



    elif oracle_type == "random_balanced":

        f = np.zeros(n)


        indices = np.random.choice(
            range(n),
            size=n//2,
            replace=False
        )


        f[indices] = 1



    elif oracle_type == "majority":

        f = np.zeros(n)


        for x in range(n):

            bits = format(
                x,
                f"0{target_bits}b"
            )


            if sum(map(int,bits)) > target_bits/2:

                f[x] = 1



    elif oracle_type == "single_marked":

        f = np.zeros(n)

        f[-1] = 1



    else:

        raise ValueError(
            f"Unknown oracle {oracle_type}"
        )


    if verbose:

        print("Oracle:", oracle_type)
        print("Balanced:", is_balanced(f))
        print("Bias:", np.sum(f)/len(f))


    return f



# -------------------------------------------------
# Semantic Oracle Constructors
#
# These correspond to Rocq:
#
# oracle_first_bit
# oracle_parity
# oracle_affine
#
# -------------------------------------------------

def create_oracle(
    oracle_type,
    target_bits
):


    table = dj_function(
        oracle_type,
        target_bits,
        verbose=False
    )


    def oracle(bits):

        index = int(bits,2)

        return bool(
            table[index]
        )


    kind_map = {

        "constant_zero":
            OracleKind.CONSTANT_ZERO,

        "constant_one":
            OracleKind.CONSTANT_ONE,

        "first_bit":
            OracleKind.FIRST_BIT,

        "parity":
            OracleKind.PARITY,

        "full_parity":
            OracleKind.FULL_PARITY,

        "xor_two_bits":
            OracleKind.XOR_TWO_BITS,

        "affine":
            OracleKind.AFFINE,

        "and_xor":
            OracleKind.AND_XOR,
            
        "random_balanced":
            OracleKind.RANDOM_BALANCED,

        "single_marked":
            OracleKind.SINGLE_MARKED,

        "majority":
            OracleKind.MAJORITY,

        "alternating":
            OracleKind.ALTERNATING
    }


    return OracleInstance(

        kind=kind_map[oracle_type],

        function=oracle

    )

def promise_distance(oracle_type, target_bits):

    f = dj_function(
        oracle_type,
        target_bits,
        verbose=False
    )

    ones = np.sum(f)

    total = len(f)

    distance = abs(
        ones - total/2
    )

    return int(distance)