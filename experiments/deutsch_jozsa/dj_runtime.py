from dj_verify import run_test

# -------------------------
# SCALING EXPERIMENT
# -------------------------

def scaling_experiment():

    global n_target_bits
    global n_wires
    global dev
    global deutsch_jozsa_circuit

    scaling_results = []

    for n in [3, 4, 5, 6, 7, 8, 9]:

        print("\n")
        print("=" * 80)
        print(f"SCALING EXPERIMENT: n_target_bits = {n}")
        print("=" * 80)

        # Update global settings
        n_target_bits = n
        n_wires = n + 1

        # Rebuild device
        dev = qml.device(
            "default.qubit",
            wires=n_wires
        )

        # Rebuild QNode for new wire count
        @qml.qnode(dev)
        def deutsch_jozsa_circuit(oracle_type):

            qml.PauliX(wires=n_target_bits)

            for i in range(n_wires):
                qml.Hadamard(wires=i)

            U(oracle_type, n_target_bits)

            for i in range(n_target_bits):
                qml.Hadamard(wires=i)

            return qml.probs(
                wires=range(n_target_bits)
            )

        # -------------------------
        # PARITY
        # -------------------------

        parity_runtimes = []

        for _ in range(10):

            parity_result = run_test("parity")

            parity_runtimes.append(
            parity_result["runtime"]
            )


        # -------------------------
        # FULL PARITY
        # -------------------------

        full_parity_runtimes = []
        
        for _ in range(10):

            full_parity_result = run_test(
                "full_parity"
            )

            full_parity_runtimes.append(
                full_parity_result["runtime"]
            )
            
        
        parity_avg = statistics.mean(
            parity_runtimes
        )

        parity_std = statistics.stdev(
            parity_runtimes
        )

        full_parity_avg = statistics.mean(
            full_parity_runtimes
        )

        full_parity_std = statistics.stdev(
            full_parity_runtimes
        )

        scaling_results.append({
            "n": n,
            "oracle": "parity",
            "output": parity_result["output"],
            "verified": parity_result["verified"],
            "runtime_avg": parity_avg,
            "runtime_std": parity_std
        })
        
        scaling_results.append({
            "n": n,
            "oracle": "full_parity",
            "output": full_parity_result["output"],
            "verified": full_parity_result["verified"],
            "runtime_avg": full_parity_avg,
            "runtime_std": full_parity_std
        })

    # -------------------------
    # SUMMARY TABLE
    # -------------------------

    print("\n")
    print("=" * 80)
    print("SCALING SUMMARY")
    print("=" * 80)

    for r in scaling_results:

        print(
            f"n={r['n']:2}   "
            f"{r['oracle']:12}   "
            f"Output={r['output']}   "
            f"Verified={r['verified']}   "
            f"Avg={r['runtime_avg']:.6f}s   "
            f"Std={r['runtime_std']:.6f}s"

        )

    return scaling_results

# -------------------------
# RUN EXPERIMENT
# -------------------------

scaling_results = scaling_experiment()