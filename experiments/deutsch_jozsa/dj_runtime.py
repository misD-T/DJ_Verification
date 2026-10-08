import random
import statistics

from .dj_verify import run_test


# ============================================================
# Deutsch–Jozsa Scalability Experiment
#
# Evaluates:
#
# - execution time as qubit count increases
# - effect of oracle structural complexity
# - semantic execution behaviour
# - verification stability
#
# ============================================================


def scaling_experiment():

    # Ensure reproducible experimental configurations.
    random.seed(42)

    scaling_results = []

    # -------------------------------------------------
    # Number of target qubits
    # -------------------------------------------------

    qubit_sizes = [
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12
    ]

    # Number of repeated executions for each
    # qubit/oracle configuration.
    repetitions = 30

    # -------------------------------------------------
    # Run scalability experiment
    # -------------------------------------------------

    for n in qubit_sizes:

        for oracle in [
            "full_parity",
            "xor_two_bits"
        ]:

            runtimes = []
            last_result = None

            # Repeat each configuration to obtain
            # mean, median, and standard deviation.
            for _ in range(repetitions):

                result = run_test(
                    oracle,
                    n_target_bits=n,
                    verbose=False
                )

                runtimes.append(result["runtime"])
                last_result = result

            # -------------------------------------------------
            # Runtime statistics
            # -------------------------------------------------

            avg_runtime = statistics.mean(runtimes)
            median_runtime = statistics.median(runtimes)
            std_runtime = statistics.stdev(runtimes)

            # -------------------------------------------------
            # Store results
            # -------------------------------------------------

            scaling_results.append({

                "n":
                    n,

                "oracle":
                    oracle,

                "structural_complexity":
                    last_result["structural_complexity"],

                "promise_valid":
                    last_result["promise_valid"],

                "output":
                    last_result["output"],

                "verified":
                    last_result["verified"],

                "qdl":
                    last_result["qdl_result"],

                "hh":
                    last_result["hh_result"],

                "runtime_avg":
                    avg_runtime,

                "runtime_std":
                    std_runtime,

                "runtime_median":
                    median_runtime,

                "trace":
                    last_result["semantic_trace"],

                "status":
                    last_result["semantic_status"]
            })

    return scaling_results

