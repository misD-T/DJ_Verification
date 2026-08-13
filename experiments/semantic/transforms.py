"""
Semantic quantum transformations.

These functions represent the abstract transformations
defined in the Rocq framework.

They are independent of quantum circuit backends.
"""


import numpy as np


def HadamardTransform(
    amplitudes: np.ndarray,
    qubits: int
) -> np.ndarray:
    """
    Apply the tensor-product Hadamard transformation
    H^{⊗n} to a quantum amplitude state.

    This implements the actual linear Hadamard
    transformation rather than simply replacing the
    state with a uniform superposition.
    """

    state = np.asarray(
        amplitudes,
        dtype=complex
    )

    dimension = 2 ** qubits

    if state.size != dimension:
        raise ValueError(
            "Amplitude vector size does not "
            "match the number of qubits."
        )

    result = state.copy()

    for qubit in range(qubits):

        step = 2 ** qubit
        block = 2 * step

        scale = 1 / np.sqrt(2)

        for start in range(
            0,
            dimension,
            block
        ):

            for offset in range(step):

                i = start + offset
                j = i + step

                a = result[i]
                b = result[j]

                result[i] = (
                    a + b
                ) * scale

                result[j] = (
                    a - b
                ) * scale

    return result