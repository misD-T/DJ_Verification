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

def main():

    print("=" * 80)
    print("Deutsch–Jozsa Semantic Verification Experiment Suite")
    print("=" * 80)


    print("\n\nRunning scalability experiment...")

    runtime_results = scaling_experiment()
    plot_scaling_runtime(runtime_results)


    print("\n\nRunning oracle complexity experiment...")

    complexity_results = (
        oracle_complexity_experiment()
    )
    
    plot_oracle_runtime(complexity_results)
    plot_oracle_complexity(complexity_results)
    
    



    print("\n\nRunning promise robustness experiment...")

    promise_results = (
        promise_robustness_experiment()
    )
    
    plot_promise_probability(promise_results)


    plot_promise_probability(promise_results)

    return {

        "runtime":
            runtime_results,

        "complexity":
            complexity_results,

        "promise":
            promise_results
    }



if __name__ == "__main__":

    results = main()
    
# python3 -m experiments.deutsch_jozsa.dj_main
#source venv/bin/activate