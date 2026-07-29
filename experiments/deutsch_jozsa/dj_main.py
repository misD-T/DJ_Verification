from dj_runtime import *
from dj_complexity import *
from dj_promise import *

def main():

    print("Deutsch–Jozsa Experiment Suite")

    runtime_experiment()

    scaling_experiment()

    oracle_complexity_experiment()

    promise_robustness_experiment()

if __name__ == "__main__":

    main()