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


        for oracle in [

            "full_parity",

            "xor_two_bits"

        ]:


            runtimes = []


            last_result = None



            for _ in range(repetitions):


                result = run_test(

                    oracle,

                    n_target_bits=n,

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



    return scaling_results



# ============================================================
# Execute Experiment
# ============================================================

if __name__ == "__main__":


    results = scaling_experiment()

    for r in results:

        print(r)