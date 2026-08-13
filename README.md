# Quantum Program Verification Using QDL and Hoare–Heisenberg Logic

This repository contains the implementation and formal verification framework developed for an Honours dissertation investigating the verification of quantum programs using **Quantum Dynamic Logic (QDL)** and **Hoare–Heisenberg logic**.

The framework combines an executable Python semantic model with a formal Rocq/Coq development. The primary quantum algorithms implemented are:

- Deutsch–Jozsa
- Grover's search algorithm

The Python implementation provides executable quantum-program semantics, verification experiments, runtime measurements and visualisations. The Rocq/Coq development provides the formal semantic framework, quantum-state and oracle definitions, logical specifications and machine-checked correctness proofs.

This repository contains the implementation and experimental framework supporting the accompanying dissertation.

---

## Repository Structure

The repository is organised into three main components:

1. `experiments/` — executable Python semantic models and experiments;
2. `formalisations/` — shared formal foundations, oracle definitions and verification infrastructure;
3. algorithm-specific and final Rocq developments — Deutsch–Jozsa, Grover and the final framework comparison.

```text
DJ_Verification/
│
├── experiments/
│   │
│   ├── deutsch_jozsa/
│   │   ├── dj_main.py
│   │   ├── dj_circuit.py
│   │   ├── dj_oracles.py
│   │   ├── dj_verify.py
│   │   ├── dj_runtime.py
│   │   ├── dj_complexity.py
│   │   ├── dj_promise.py
│   │   └── dj_visualisation.py
│   │
│   ├── grover/
│   │   ├── grover_main.py
│   │   ├── grover_circuit.py
│   │   ├── grover_oracles.py
│   │   ├── grover_verify.py
│   │   ├── grover_probability.py
│   │   ├── grover_scaling.py
│   │   ├── grover_oracle_evaluation.py
│   │   ├── grover_search_quality.py
│   │   ├── grover_search.py
│   │   └── grover_visualisation.py
│   │
│   ├── semantic/
│   │   ├── quantum_state.py
│   │   ├── operators.py
│   │   ├── transforms.py
│   │   ├── execution_status.py
│   │   ├── trace.py
│   │   └── oracles.py
│   │
│   └── util/
│       └── result_writer.py
│
├── formalisations/
│   │
│   ├── Foundations/
│   │   ├── BitStrings.v
│   │   ├── Counting.v
│   │   └── Enumeration.v
│   │
│   ├── Oracles/
│   │   ├── BooleanFunctions.v
│   │   ├── Oracles.v
│   │   └── Promise.v
│   │
│   └── Verification/
│       ├── Balanced.v
│       └── OracleProofs.v
│
├── deutschjozsa/
│   ├── DJ.v
│   ├── DJProofs.v
│   └── Tests/
│       ├── DJCaseStudy.v
│       └── DJTests.v
│
├── grovers/
│   ├── Grover.v
│   ├── GroverCaseStudy.v
│   ├── GroverConvergenceExperiment.v
│   ├── GroverExperimentResults.v
│   ├── GroverExperiments.v
│   ├── GroverOperators.v
│   ├── GroverOracles.v
│   ├── GroverProbabilityExperiments.v
│   ├── GroverProbabilityResults.v
│   ├── GroverProbabilitySoundness.v
│   ├── GroverProofs.v
│   └── GroverTrace.v
│
├── FinalVerification/
│   ├── AlgorithmVerification.v
│   ├── CaseStudyComparison.v
│   ├── Framework.v
│   ├── FrameworkSoundness.v
│   └── LogicComparison.v
│
├── _CoqProject
├── Makefile
└── README.md
```

### `experiments/`

Contains the executable Python implementation and experimental framework.

The `deutsch_jozsa/` and `grover/` directories contain algorithm-specific experiments, while `semantic/` contains the reusable semantic execution framework.

The experiments produce structured results that can be exported to CSV files and visualised using Matplotlib.

### `formalisations/`

Contains the shared Rocq/Coq formalisation used by both algorithms.

The formalisation is divided into three areas:

#### `Foundations/`

Provides common mathematical and computational definitions used throughout the formal development, including:

- bitstring representations;
- counting;
- enumeration of computational states.

#### `Oracles/`

Provides the formal definitions and properties of oracle functions, including:

- Boolean functions;
- oracle instances;
- oracle classification; and
- Deutsch–Jozsa promise conditions.

#### `Verification/`

Contains reusable verification definitions and proofs, including:

- balanced-oracle reasoning; and
- oracle correctness proofs.

### `deutschjozsa/`

Contains the algorithm-specific formalisation of Deutsch–Jozsa.

Important files include:

```text
DJ.v
DJProofs.v
Tests/DJCaseStudy.v
Tests/DJTests.v
```

`DJ.v` defines the formal Deutsch–Jozsa program and associated semantics, while `DJProofs.v` contains correctness results for the algorithm.

The `Tests/` directory contains formal tests and the Deutsch–Jozsa case study.

### `grovers/`

Contains the formalisation and experimental developments associated with Grover's search algorithm.

This includes:

- the Grover algorithm;
- Grover operators;
- oracle definitions;
- execution traces;
- correctness proofs;
- probability experiments;
- convergence experiments;
- soundness results; and
- formal case-study results.

### `FinalVerification/`

Contains the final verification framework used to bring together the algorithm-specific developments and compare the verification approaches.

Important components include:

```text
Framework.v
FrameworkSoundness.v
AlgorithmVerification.v
LogicComparison.v
CaseStudyComparison.v
```

These files provide the final framework, soundness reasoning, algorithm verification and comparison between the logical approaches.

---

# Requirements

## Python

The experimental framework requires:

- Python 3.10 or later
- NumPy
- Matplotlib

The project also uses Python standard-library modules including:

```python
from __future__ import annotations

import time
import math
import random
import statistics

from dataclasses import dataclass
from typing import List, Callable
from enum import Enum
from abc import ABC, abstractmethod
from datetime import datetime
```

These modules are part of Python's standard library and do not require separate installation.

---

## Rocq / Coq

The formal development was developed and tested using:

```text
Coq 8.19.0
OCaml 4.14.1
```

The current repository uses the **Coq Proof Assistant** and the `coqc` compiler command.

Check the installed version with:

```bash
coqc -v
```

The expected environment is:

```text
The Coq Proof Assistant, version 8.19.0
compiled with OCaml 4.14.1
```

The formal development uses standard Coq libraries. For example:

```coq
From Coq Require Import List Bool Arith Reals.
```

These libraries are included with Coq and do not require separate installation.

---

# Python Installation

From the repository root, create a virtual environment:

```bash
python3 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

Install the external dependencies:

```bash
pip install numpy matplotlib
```

Verify the installation:

```bash
python3 -c "import numpy, matplotlib; print('Python dependencies OK')"
```

---

# Coq Installation

The recommended environment is:

```text
Coq 8.19.0
OCaml 4.14.1
```

Coq can be installed using `opam`.

Check whether `opam` is installed:

```bash
opam --version
```

If required, initialise `opam`:

```bash
opam init
eval $(opam env)
```

Create an OCaml 4.14.1 switch:

```bash
opam switch create 4.14.1
eval $(opam env)
```

Install Coq 8.19.0:

```bash
opam install coq.8.19.0
```

Then verify:

```bash
coqc -v
```

---

# Compiling the Formal Development

The repository contains a `_CoqProject` configuration and Makefile for compiling the formal development.

From the repository root:

```bash
make
```

The Makefile uses `_CoqProject` to determine the `.v` files and their dependencies.

If the generated Coq Makefile needs to be regenerated after changes to `_CoqProject`, run:

```bash
rm -f Makefile.coq
make
```

The build generates compiled Coq artefacts such as:

```text
.vo
.vos
.vok
.glob
.aux
```

These files are generated automatically and do not need to be edited manually.

---

# Running the Python Experiments

The Python experiments should be executed from the repository root so that the package-relative imports resolve correctly.

## Deutsch–Jozsa

Run the Deutsch–Jozsa experiment suite with:

```bash
python3 -m experiments.deutsch_jozsa.dj_main
```

The experiments investigate aspects including:

- runtime scalability;
- oracle complexity;
- promise robustness;
- semantic execution;
- verification behaviour;
- QDL verification; and
- Hoare–Heisenberg verification.

Experimental results can be exported to CSV files for further analysis.

---

## Grover

Run the Grover experiment suite with:

```bash
python3 -m experiments.grover.grover_main
```

The Grover experiments investigate:

- semantic execution;
- semantic verification;
- probability amplification;
- runtime scaling;
- oracle evaluation;
- search quality; and
- database search.

The semantic verification experiments consider several oracle families, including:

- single marked states;
- multiple marked states;
- random marked states; and
- predicate-based search.

---

# Semantic Verification Framework

The Python semantic framework provides an executable representation of quantum-program behaviour.

Semantic states can record:

- qubit count;
- computational state;
- oracle information;
- measurement results;
- execution history;
- execution status; and
- symbolic output.

For example, a Grover execution produces a semantic trace similar to:

```text
InitialState -> H -> Oracle -> Diffusion -> Measurement
```

This provides an executable representation of the operations performed during program execution.

The algorithm-specific verification modules construct correctness properties and logical specifications over these semantic states.

For example:

```text
experiments/deutsch_jozsa/dj_verify.py
experiments/grover/grover_verify.py
```

These modules evaluate:

1. a semantic correctness property;
2. a Quantum Dynamic Logic specification; and
3. a Hoare–Heisenberg specification.

---

# Experimental Results

The Python framework exports structured experimental results to CSV files.

These CSV files provide a reproducible intermediate format for analysing experimental data and generating dissertation figures.

Examples of Grover result files include:

```text
grover_semantic_verification.csv
grover_probability_amplification.csv
grover_scaling.csv
grover_oracle_evaluation.csv
grover_search_quality.csv
grover_database_search.csv
```

The Deutsch–Jozsa experiments similarly produce structured data for experiments involving:

```text
scalability
oracle complexity
promise robustness
semantic verification
```

The exact output files depend on the experiments executed.

---

# Visualisations

The Python framework contains dedicated visualisation modules:

```text
experiments/deutsch_jozsa/dj_visualisation.py
experiments/grover/grover_visualisation.py
```

These generate plots for experimental analysis, including:

- runtime scaling;
- probability amplification;
- oracle complexity;
- search quality;
- promise robustness; and
- other experiment-specific measurements.

---

# Formal Verification

The Rocq/Coq development provides the machine-checked component of the framework.

The shared formalisation in:

```text
formalisations/
```

provides the foundational definitions, oracle definitions and reusable verification infrastructure.

The algorithm-specific developments are then contained in:

```text
deutschjozsa/
grovers/
```

The final verification framework is contained in:

```text
FinalVerification/
```

This separation allows common formal definitions and verification infrastructure to be reused while keeping algorithm-specific developments independent.

---

# Reproducibility

For reproduction of the experimental and formal results, the following environment is recommended:

```text
Python 3.10+
NumPy
Matplotlib

Coq 8.19.0
OCaml 4.14.1
```

The recommended procedure is:

### 1. Clone the repository

```bash
git clone https://github.com/misD-T/DJ_Verification.git
cd DJ_Verification
```

### 2. Install Python dependencies

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install numpy matplotlib
```

### 3. Verify Coq

```bash
coqc -v
```

### 4. Compile the formal development

```bash
make
```

### 5. Run Deutsch–Jozsa

```bash
python3 -m experiments.deutsch_jozsa.dj_main
```

### 6. Run Grover

```bash
python3 -m experiments.grover.grover_main
```

---

# Notes on Experimental Reproducibility

Runtime measurements depend on the hardware and operating system used to execute the experiments.

Experiments involving randomly generated oracle instances may also produce different results between executions unless a fixed random seed is specified.

Runtime and randomised experimental results should therefore be interpreted as empirical measurements rather than deterministic benchmark values.

---