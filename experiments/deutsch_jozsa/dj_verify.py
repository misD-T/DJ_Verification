from dj_circuit import *
from dj_oracles import *

# -------------------------
# PROPERTY DEFINITIONS
# -------------------------

class Property:

    def __init__(self, name):
        self.name = name

    def check(self, output):
        raise NotImplementedError


class ConstantOutputProperty(Property):

    def __init__(self, n_bits):
        super().__init__("Constant -> OutputZero")
        self.expected = "0" * n_bits

    def check(self, output):
        return output == self.expected


class BalancedOutputProperty(Property):

    def __init__(self, n_bits):
        super().__init__("Balanced -> Not(OutputZero)")
        self.expected = "0" * n_bits

    def check(self, output):
        return output != self.expected
    

# -------------------------
# VERIFICATION RESULT
# -------------------------

class VerificationResult:

    def __init__(self,
                 property_name,
                 output,
                 verified):

        self.property_name = property_name
        self.output = output
        self.verified = verified

    def __str__(self):

        return (
            f"Property: {self.property_name}\n"
            f"Output: {self.output}\n"
            f"Verified: {self.verified}"
        )
# -------------------------
# VERIFICATION ENGINE
# -------------------------

def verify_property(property_obj, output):

    result = property_obj.check(output)

    return VerificationResult(
        property_obj.name,
        output,
        result
    )
    

# -------------------------
# QDL REPRESENTATION
# -------------------------

class QDLFormula:

    def __init__(
        self,
        assumption,
        proposition
    ):

        self.assumption = assumption
        self.proposition = proposition

    def verify(self, output):

        return self.proposition.evaluate(output)

    def __str__(self):

        return (
            f"{self.assumption}"
            f" -> [DJ] "
            f"{self.proposition}"
        )
# -------------------------
# ATOMIC PROPOSITIONS
# -------------------------

class Proposition:

    def evaluate(self, output):
        raise NotImplementedError


class OutputZero(Proposition):

    def evaluate(self, output):

        return output == ("0" * len(output))

    def __str__(self):

        return "OutputZero"


class NotOutputZero(Proposition):

    def evaluate(self, output):

        return output != ("0" * len(output))

    def __str__(self):

        return "Not(OutputZero)"

class UndefinedProperty(Property):

    def __init__(self):

        super().__init__(
            "Undefined Specification"
        )

    def check(self, output):

        return None

class UndefinedProposition(Proposition):

    def evaluate(self, output):
        return None

    def __str__(self):
        return "Undefined"


# -------------------------
# HOARE-HEISENBERG PREDICATES
# -------------------------

class Predicate:

    def evaluate(self, output):
        raise NotImplementedError


class OutputZeroPredicate(Predicate):

    def evaluate(self, output):

        return output == ("0" * len(output))

    def __str__(self):

        return "OutputZero"


class NotOutputZeroPredicate(Predicate):

    def evaluate(self, output):

        return output != ("0" * len(output))

    def __str__(self):

        return "Not(OutputZero)"

# -------------------------
# HOARE-HEISENBERG LOGIC (Minimum Version based on Cho and Rand's Conceptual work)
# -------------------------

class HoareTriple:

    def __init__(
        self,
        precondition,
        program,
        predicate
    ):

        self.precondition = precondition
        self.program = program
        self.predicate = predicate

    def verify(self, output):

        return self.predicate.evaluate(output)

    def __str__(self):

        return (
            f"{{{self.precondition}}} "
            f"{self.program} "
            f"{{{self.predicate}}}"
        )

# -------------------------
# RUN EXPERIMENT
# -------------------------

def run_test(oracle_type):

    start_time = time.perf_counter()

    probs = deutsch_jozsa_circuit(oracle_type)
    
    prob_zero = probs[0]

    end_time = time.perf_counter()

    runtime = end_time - start_time

    print("probs:", probs)
    print(f"Runtime: {runtime:.6f} seconds")

    output = most_likely_bitstring(probs)

    constant_oracles = [
        "constant_zero",
        "constant_one"
    ]

    balanced_oracles = [
        "xor_two_bits",
        "first_bit",
        "alternating",
        "full_parity",
        "affine",
        "and_xor",
        "random_balanced"
    ]
    
    near_promise_oracles = [

        "quarter_ones",
        "three_quarter_ones",
        "almost_balanced",
        "two_marked",
        "almost_balanced_1",
        "almost_balanced_2",
        "almost_balanced_4",
        "almost_balanced_8"
    ]

    # -------------------------
    # CONSTANT
    # -------------------------

    if oracle_type in constant_oracles:

        category = "Constant"

        prop = ConstantOutputProperty(
            n_target_bits
        )

        qdl = QDLFormula(
            "ConstantOracle",
            OutputZero()
        )

        hh = HoareTriple(
            "ConstantOracle",
            "DJ",
            OutputZeroPredicate()
        )

    # -------------------------
    # BALANCED
    # -------------------------

    elif oracle_type in balanced_oracles:

        category = "Balanced"

        prop = BalancedOutputProperty(
            n_target_bits
        )

        qdl = QDLFormula(
            "BalancedOracle",
            NotOutputZero()
        )

        hh = HoareTriple(
            "BalancedOracle",
            "DJ",
            NotOutputZeroPredicate()
        )

    # -------------------------
    # INVALID
    # -------------------------

    else:

        category = "Invalid"

        print(
            "\nWARNING: Oracle violates the DJ promise."
        )

        prop = UndefinedProperty()

        qdl = QDLFormula(
            "InvalidOracle",
            UndefinedProposition()
        )

        hh = None

    # -------------------------
    # PROPERTY VERIFICATION
    # -------------------------

    verification = verify_property(
        prop,
        output
    )

    # -------------------------
    # QDL VERIFICATION
    # -------------------------

    qdl_result = qdl.verify(output)
    
    # -------------------------
    # HOARE-HEISENBERG VERIFICATION
    # -------------------------
    
    if hh is not None:
        hh_result = hh.verify(output)
    else:
        hh_result = False

    # -------------------------
    # ASSUMPTIONS
    # -------------------------

    assumption = (
        "DJ Promise Satisfied"
        if category != "Invalid"
        else "DJ Promise Violated"
    )

    print("\nAssumption:")
    print(assumption)

    print("\nVerification Result")
    print(verification)

    print("\nQDL Formula")
    print(qdl)

    print("QDL Result:", qdl_result)

    print("\nHoare-Heisenberg Formula")

    if hh is not None:

        print(hh)

        print(
            f"HH Verification: "
            f"{hh_result}"
        )

    else:

        print("Undefined")

    print("\n" + "-" * 60)

    return {
        "oracle": oracle_type,
        "distance": promise_distance(oracle_type),
        "class":
            oracle_class(
                oracle_type
            ),
        
        "complexity":
            oracle_complexity(
                oracle_type,
                n_target_bits
            ),
            
        "category":
            "Constant" if oracle_type in constant_oracles
            else "Balanced" if oracle_type in balanced_oracles
            else "Invalid",
        "output": output,
        "verified": verification.verified,
        "runtime": runtime,
        "qdl_formula": str(qdl),
        "qdl_result": qdl_result,
        "prob_zero":prob_zero,
        
        "bias":
            oracle_bias(
                oracle_type,
                n_target_bits
            ),
    }