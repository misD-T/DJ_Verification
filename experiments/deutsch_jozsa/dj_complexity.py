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

def oracle_complexity_experiment(
        target_bits=5
):


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

                n_target_bits=target_bits,

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


            "oracle_class":
                last_result["class"],


            "structural_complexity":
                last_result["structural_complexity"],
                
            "bias":
                last_result["bias"],

            "prob_zero":
                last_result["prob_zero"],

            "promise_valid":
                last_result["promise_valid"],


            "normalised_complexity":
                (
                    last_result["structural_complexity"]
                    / target_bits
                    if target_bits > 0
                    else 0
                ),
                
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
                std_runtime

        })


    return results