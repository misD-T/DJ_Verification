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


def promise_robustness_experiment(target_bits=5):


    oracle_set = [

        # Valid constant oracles

        "constant_zero",
        "constant_one",


        # Balanced / candidate balanced

        "first_bit",
        "xor_two_bits",
        "alternating",
        "full_parity",
        "affine",
        "and_xor",
        "majority",

        "random_balanced",


        # Promise violation

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

                n_target_bits=target_bits,

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



    return results



# ============================================================
# Execute Experiment
# ============================================================


if __name__ == "__main__":


    results = promise_robustness_experiment()


    for r in results:

        print(r)