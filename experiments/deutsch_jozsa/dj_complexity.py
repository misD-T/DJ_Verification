from dj_verify import run_test

# -------------------------
# ORACLE COMPLEXITY EXPERIMENT
# -------------------------

def oracle_complexity_experiment():

    print("\n")
    print("=" * 80)
    print("ORACLE COMPLEXITY EXPERIMENT")
    print("=" * 80)

    oracle_set = [

        "first_bit",
        "alternating",
        "xor_two_bits",
        "full_parity",
        "affine",
        "and_xor",
        "random_balanced"
        "quarter_ones",
        "three_quarter_ones",
        "almost_balanced",
        "two_marked"
    ]

    results = []

    repetitions = 10

    for oracle in oracle_set:

        runtimes = []

        last_result = None

        for _ in range(repetitions):

            result = run_test(oracle)

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

            "avg_runtime":
                avg_runtime,

            "std_runtime":
                std_runtime,

            "distance": 
                last_result["distance"],
            })

    print("\n")
    print("=" * 100)
    print("ORACLE COMPLEXITY SUMMARY")
    print("=" * 100)

    for r in results:

        print(
            f"{r['oracle']:15} "
            f"{r['class']:12} "
            f"Complexity={r['complexity']:3} "
            f"Output={r['output']:8} "
            f"Verified={str(r['verified']):5} "
            f"Avg={r['avg_runtime']:.6f}s "
            f"Std={r['std_runtime']:.6f}s "
            f"Distance={r['distance']:2}"
        )

    return results

# -------------------------
# RUN ORACLE COMPLEXITY EXPERIMENT
# -------------------------
oracle_complexity_results = (
    oracle_complexity_experiment()
)