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


    repetitions = 10



    stochastic_oracles = {
    "random_balanced"
    }
    
    for oracle in oracle_set:


        probabilities = []


        last_result = None

        oracle_repetitions = (
            10
            if oracle in stochastic_oracles
            else 1
        )

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


        std_probability = (
            statistics.stdev(probabilities)
            if len(probabilities) > 1
            else 0.0
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
                
            "promise_distance_normalised":
                last_result["distance"]
                / last_result["truth_table_size"],

            "promise_valid":
                last_result["promise_valid"],
                
            "verification_reason":
                last_result["verification_reason"],

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