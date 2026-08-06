import statistics

from .dj_verify import run_test


# ============================================================
# PROMISE ROBUSTNESS EXPERIMENT
#
# Evaluates behaviour when oracle assumptions are violated.
#
# Measures:
#
# - promise distance
# - oracle bias
# - output behaviour
# - verification outcome
# - semantic execution trace
#
# ============================================================


def promise_robustness_experiment(target_bits = 5):


    print("\n")
    print("=" * 100)
    print("PROMISE ROBUSTNESS EXPERIMENT")
    print("=" * 100)



    # -------------------------------------------------
    # Oracle Set
    #
    # Valid DJ promise instances
    # + invalid promise violations
    #
    # -------------------------------------------------

    oracle_set = [


        # -------------------------
        # Valid constant oracles
        # -------------------------

        "constant_zero",
        "constant_one",


        # -------------------------
        # Candidate balanced oracles
        #
        # Some depend on n.
        # Example:
        # majority is balanced only for odd n.
        # -------------------------

        "first_bit",
        "xor_two_bits",
        "alternating",
        "full_parity",
        "affine",
        "and_xor",
        "majority",
        
        "random_balanced",
        
        # Promise violations
        "single_marked"

    ]



    results = []

    repetitions = 20



    for oracle in oracle_set:


        probabilities = []

        last_result = None



        for _ in range(repetitions):

            result = run_test(
                oracle,
                n_target_bits= target_bits,
                verbose=False
            )


            probabilities.append(
                result["prob_zero"]
            )


            last_result = result



        avg_probability = statistics.mean(
            probabilities
        )


        std_probability = statistics.stdev(
            probabilities
        )



        results.append({

            "n":
                target_bits,
                
            "oracle":
                oracle,


            "class":
                last_result["class"],


            "distance":
                last_result["distance"],


            "bias":
                last_result["bias"],


            "output":
                last_result["output"],


            "verified":
                last_result["verified"],


            "qdl":
                last_result["qdl_result"],


            "hh":
                last_result["hh_result"],


            "prob_zero":
                avg_probability,


            "prob_std":
                std_probability,


            "trace":
                last_result["semantic_trace"],


            "status":
                last_result["semantic_status"]

        })



    # -------------------------------------------------
    # Print Summary
    # -------------------------------------------------

    print("\n")
    print("=" * 120)

    print(
        "PROMISE ROBUSTNESS SUMMARY"
    )

    print("=" * 120)



    print(

        f"{'Oracle':20}"
        f"{'Class':12}"
        f"{'Distance':10}"
        f"{'Bias':10}"
        f"{'P(0)':12}"
        f"{'Output':10}"
        f"{'Verified':10}"
        f"{'QDL':8}"
        f"{'HH'}"

    )


    print("-" * 120)



    for r in results:


        print(

            f"{r['oracle']:20}"

            f"{r['class']:12}"

            f"{r['distance']:<10}"

            f"{r['bias']:<10.4f}"

            f"{r['prob_zero']:<12.6f}"

            f"{r['output']:10}"

            f"{str(r['verified']):10}"

            f"{str(r['qdl']):8}"

            f"{str(r['hh'])}"

        )

    return results



# ============================================================
# Execute Experiment
# ============================================================


if __name__ == "__main__":

    promise_results = (
        promise_robustness_experiment()
    )