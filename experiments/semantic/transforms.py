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
    Semantic Hadamard amplitude transformation.

    Corresponds to Rocq:

        Definition HadamardTransform
             (amps : AmplitudeState)
             (n : nat)
             : AmplitudeState :=

        UniformAmplitudeState n.


    For the semantic model, the Hadamard operation
    produces a uniform superposition.
    """


    dimension = 2 ** qubits


    amplitude = 1 / np.sqrt(dimension)


    return np.full(
        dimension,
        amplitude
    )