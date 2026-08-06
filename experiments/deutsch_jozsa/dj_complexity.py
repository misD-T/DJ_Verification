import statistics

from .dj_verify import run_test


# ============================================================
# ORACLE COMPLEXITY EXPERIMENT
#
# Evaluates:
#
# - oracle classification
# - complexity score
# - verification behaviour
# - semantic execution trace
# - runtime cost
#
# ============================================================


def oracle_complexity_experiment():


    print("\n")
    print("=" * 80)
    print("ORACLE COMPLEXITY EXPERIMENT")
    print("=" * 80)
    
    target_bits = 5


    # -------------------------------------------------
    # Oracle families from Rocq OracleKind
    # -------------------------------------------------

    oracle_set = [

        # Constant

        "constant_zero",
        "constant_one",


        # Linear

        "first_bit",
        "alternating",
        "xor_two_bits",
        "full_parity",


        # Affine

        "affine",


        # Non-linear

        "and_xor",
        
        # Random
        "random_balanced"

    ]


    results = []


    repetitions = 10


    for oracle in oracle_set:


        runtimes = []


        last_result = None


        for _ in range(repetitions):


            result = run_test(
                oracle,
                n_target_bits= target_bits,
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


        results.append({

            "n":
                target_bits,
                
            "oracle":
                oracle,


            "class":
                last_result["class"],


            "complexity":
                last_result["complexity"],


            "output":
                last_result["output"],


            "verified":
                last_result["verified"],


            "qdl":
                last_result["qdl_result"],


            "hh":
                last_result["hh_result"],


            "semantic_trace":
                last_result["semantic_trace"],


            "semantic_status":
                last_result["semantic_status"],


            "avg_runtime":
                avg_runtime,


            "std_runtime":
                std_runtime,

        })


    # -------------------------------------------------
    # Display Results
    # -------------------------------------------------


    print("\n")
    print("=" * 110)

    print(
        "ORACLE COMPLEXITY SUMMARY"
    )

    print("=" * 110)



    for r in results:


        print(

            f"{r['oracle']:18} "

            f"{r['class']:12} "

            f"C={r['complexity']:3} "

            f"Output={r['output']:8} "

            f"Verified={str(r['verified']):5} "

            f"QDL={str(r['qdl']):5} "

            f"HH={str(r['hh']):5} "

            f"Avg={r['avg_runtime']:.6f}s"

        )


        print(
            " Trace:",
            " -> ".join(
                r["semantic_trace"]
            )
        )


        print(
            " Status:",
            r["semantic_status"]
        )


        print()



    return results



# ============================================================
# Execute Experiment
# ============================================================


if __name__ == "__main__":

    oracle_complexity_results = (
        oracle_complexity_experiment()
    )