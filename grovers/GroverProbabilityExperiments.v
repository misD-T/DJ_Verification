(*************************************************************)
(* GroverProbabilityExperiment.v                             *)
(*                                                           *)
(* Probability amplification experiments for Grover search   *)
(*                                                           *)
(*************************************************************)

From Coq Require Import List Arith Reals.

Import ListNotations.


Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOracles.
Require Import Grover.GroverTrace.

Require Import Grover.GroverConvergenceExperiment.
Require Import Grover.GroverExperiments.
Require Import Grover.GroverExperimentResults.



(*************************************************************)
(* Probability Experiment                                    *)
(*************************************************************)


Definition GroverProbabilityExperiment
           (n:nat)
           (f:OracleInstance)
           : list GroverDataPoint :=

GroverConvergenceData n f.



(*************************************************************)
(* Single Marked Experiments                                 *)
(*************************************************************)


Definition GroverProbability_single_n3 :=

GroverProbabilityExperiment
    3
    (oracle_grover_single (all_zeros 3)).



Definition GroverProbability_single_n5 :=

GroverProbabilityExperiment
    5
    (oracle_grover_single (all_zeros 5)).



(*************************************************************)
(* Multiple Marked Experiment                                *)
(*************************************************************)


Definition GroverProbability_multiple :=

GroverProbabilityExperiment
    3
    oracle_grover_two.



(*************************************************************)
(* Predicate Search Experiment                               *)
(*************************************************************)




Definition GroverProbability_predicate :=

GroverProbabilityExperiment
    3
    (oracle_grover_predicate even_parity).



(*************************************************************)
(* Probability Curve Extraction                              *)
(*************************************************************)


Definition ProbabilityCurve

(data : list GroverDataPoint)

:

list (nat * R)

:=

map

(fun d =>

(
 DataIteration d,

 DataProbability d

))

data.



(*************************************************************)
(* Example Curves                                            *)
(*************************************************************)


Definition GroverProbabilityCurve_single_n5 :=

ProbabilityCurve
    GroverProbability_single_n5.



Definition GroverProbabilityCurve_multiple :=

ProbabilityCurve
    GroverProbability_multiple.



Definition GroverProbabilityCurve_predicate :=

ProbabilityCurve
    GroverProbability_predicate.



(*************************************************************)
(* Structural Property                                       *)
(*************************************************************)


Lemma GroverProbabilityCurve_length :

forall data,

length
(ProbabilityCurve data)

=

length data.


Proof.

intros data.

unfold ProbabilityCurve.

apply map_length.

Qed.