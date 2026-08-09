from .dj_runtime import scaling_experiment
from .dj_complexity import oracle_complexity_experiment
from .dj_promise import promise_robustness_experiment

from .dj_visualisation import (
    plot_scaling_runtime,
    plot_oracle_runtime,
    plot_oracle_complexity,
    plot_promise_probability,
    plot_promise_distance,
)

from .dj_verify import run_test

from ..util.result_writer import save_results_csv

def run_semantic_verification():

    print("=" * 80)
    print("Deutsch–Jozsa Semantic Verification")
    print("=" * 80)


    tests = [

        "constant_zero",
        "constant_one",
        "full_parity",
        "xor_two_bits"

    ]


    results=[]


    for oracle in tests:


        result = run_test(

            oracle,

            n_target_bits=5

        )


        results.append(result)



        print()

        print(
            f"Oracle: {result['oracle']}"
        )

        print(
            f"Class: {result['class']}"
        )

        print(
            f"Output: {result['output']}"
        )

        print(
            f"Verified: {result['verified']}"
        )

        print(
            f"QDL: {result['qdl_result']}"
        )

        print(
            f"HH: {result['hh_result']}"
        )


    save_results_csv(

        "dj_semantic_verification.csv",

        results

    )

# ============================================================
# Experiment 1
# Scalability
# ============================================================

def run_scaling():

    print()
    print("=" * 80)
    print("Deutsch–Jozsa Scalability Experiment")
    print("=" * 80)


    results = scaling_experiment()



    print()
    print("=" * 110)
    print("SCALING SUMMARY")
    print("=" * 110)



    for r in results:


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



    save_results_csv(

        "dj_scaling.csv",

        results

    )


    plot_scaling_runtime(

        results

    )


# ============================================================
# Experiment 2
# Oracle Complexity
# ============================================================


def run_oracle_complexity():

    print("="*80)
    print("Deutsch–Jozsa Oracle Complexity Experiment")
    print("="*80)


    results = oracle_complexity_experiment()


    for r in results:

        print(
            f"{r['oracle']:18}"
            f"{r['oracle_class']:12}"
            f"C={r['complexity']:3}"
            f"Verified={r['verified']}"
            f"Runtime={r['avg_runtime']:.6f}s"
        )


    save_results_csv(
        "dj_oracle_complexity.csv",
        results
    )


    plot_oracle_runtime(results)

    plot_oracle_complexity(results)



# ============================================================
# Experiment 3
# Promise Robustness
# ============================================================


def run_promise_robustness():

    print()
    print("=" * 80)
    print("Deutsch–Jozsa Promise Robustness Experiment")
    print("=" * 80)



    results = promise_robustness_experiment()



    print()

    print("=" * 120)

    print("PROMISE ROBUSTNESS SUMMARY")

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



    save_results_csv(

        "dj_promise_robustness.csv",

        results

    )



    plot_promise_probability(

        results

    )


    plot_promise_distance(

        results

    )



# ============================================================
# Main
# ============================================================


def main():


    # -------------------------------------------------
    # Numerical Experiments
    # -------------------------------------------------

    run_semantic_verification()
    
    run_scaling()


    run_oracle_complexity()


    run_promise_robustness()



if __name__ == "__main__":

    main()
    
# python3 -m experiments.deutsch_jozsa.dj_main
#source venv/bin/activate