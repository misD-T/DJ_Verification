import statistics

from .dj_verify import run_test


# ============================================================
# Deutsch–Jozsa Scalability Experiment
#
# Evaluates:
#
# - execution time
# - semantic execution behaviour
# - verification stability
# - scaling with qubit count
#
# ============================================================


def scaling_experiment():


    print("\n")
    print("=" * 90)
    print("DEUTSCH-JOZSA SCALABILITY EXPERIMENT")
    print("=" * 90)

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
        9
    ]



    repetitions = 10



    for n in qubit_sizes:

        # -------------------------------------------------
        # Test oracle families
        #
        # Linear growth:
        # parity
        #
        # Full register:
        # full_parity
        #
        # -------------------------------------------------


        for oracle in [
            "full_parity",
            "xor_two_bits",
        ]:



            runtimes = []


            last_result = None



            for _ in range(repetitions):


                result = run_test(
                    oracle,
                    n_target_bits= n,
                    verbose=False
                )


                runtimes.append(
                    result["runtime"]
                )


                last_result = result



            avg_runtime = statistics.mean(
                runtimes
            )


            std_runtime = statistics.stdev(
                runtimes
            )



            scaling_results.append({


                "n":
                    n,


                "oracle":
                    oracle,


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


                "trace":
                    last_result["semantic_trace"],


                "status":
                    last_result["semantic_status"]

            })



    # -------------------------------------------------
    # Summary
    # -------------------------------------------------


    print("\n")
    print("=" * 110)

    print(
        "SCALING SUMMARY"
    )

    print("=" * 110)



    for r in scaling_results:


        print(

            f"n={r['n']:2} "

            f"{r['oracle']:15}"

            f"Output={r['output']:10}"

            f"Verified={str(r['verified']):5}"

            f"QDL={str(r['qdl']):5}"

            f"HH={str(r['hh']):5}"

            f"Avg={r['runtime_avg']:.6f}s "

            f"Std={r['runtime_std']:.6f}s"

        )


        print(
            " Trace:",
            " -> ".join(
                r["trace"]
            )
        )



    return scaling_results



# ============================================================
# Execute Experiment
# ============================================================


if __name__ == "__main__":

    scaling_results = (
        scaling_experiment()
    )