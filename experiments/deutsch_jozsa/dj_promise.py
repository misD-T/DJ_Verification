from dj_verify import run_test

# -------------------------
# PROMISE ROBUSTNESS EXPERIMENT
# -------------------------

def promise_robustness_experiment():

    print("\n")
    print("=" * 100)
    print("PROMISE ROBUSTNESS EXPERIMENT")
    print("=" * 100)

    oracle_set = [

        # Promise satisfied
        "constant_zero",
        "constant_one",

        "first_bit",
        "full_parity",
        
        "almost_balanced_1",
        "almost_balanced_2",
        "almost_balanced_4",
        "almost_balanced_8",

        # Near-promise violations
        "almost_balanced",
        "quarter_ones",
        "three_quarter_ones",

        # Larger violations
        "two_marked",
        "majority",
        "single_marked"
    ]

    results = []

    
    for oracle in oracle_set:
        probabilities = []
        for _ in range(20):

            result = run_test(oracle)

            probabilities.append(
                result["prob_zero"]
            )

        avg_prob = statistics.mean(
            probabilities
        )

        std_prob = statistics.stdev(
            probabilities
        )

        results.append({

            "oracle":
                result["oracle"],

            "distance":
                result["distance"],

            "bias":
                result["bias"],

            "output":
                result["output"],

            "verified":
                result["verified"],

            "prob_zero":
                avg_prob,

            "prob_std":
                std_prob
        })

    print("\n")
    print("=" * 100)
    print("PROMISE ROBUSTNESS SUMMARY")
    print("=" * 100)

    print(
        f"{'Oracle':20}"
        f"{'Distance':10}"
        f"{'Bias':10}"
        f"{'P(0...0)':12}"
        f"{'Std':12}"
        f"{'Output':12}"
        f"{'Verified'}"
    )

    print("-" * 100)

    for r in results:

        print(
            f"{r['oracle']:20}"
            f"{r['distance']:<10}"
            f"{r['bias']:<10.4f}"
            f"{r['prob_zero']:<12.6f}"
            f"{r['prob_std']:<12.6f}"
            f"{r['output']:12}"
            f"{str(r['verified'])}"
        )

    return results

# -------------------------
# TESTS
# -------------------------
oracle_families = [

    # Constant
    "constant_zero",
    "constant_one",

    # Balanced
    "xor_two_bits",
    "first_bit",
    "alternating",
    "full_parity",
    "affine",
    "and_xor",
    "random_balanced",
    
    # Near Promise
    "almost_balanced",
    "quarter_ones",
    "three_quarter_ones",
    "two_marked",

    # Invalid / promise violations
    "majority",
    "single_marked"
]

promise_robustness_experiment()

"""
results = []

for oracle in oracle_families:

    print("\n")
    print("=" * 60)

    result = run_test(oracle)

    results.append(result)

print("\n\nSUMMARY TABLE")
print("=" * 80)

for r in results:

    print(
        f"{r['oracle']:15} "
        f"{r['class']:12} "
        f"Complexity={r['complexity']:3} "
        f"Output={r['output']:8} "
        f"Verified={r['verified']} "
        f"Distance={r['distance']} "
    )

    print(
        f"    QDL: {r['qdl_formula']}"
    )

    print(
        f"    QDL Verification: {r['qdl_result']}"
    )

    print()
"""