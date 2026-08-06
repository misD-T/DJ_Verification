(*************************************************************)
(* GroverProbabilityResults.v                                *)
(*                                                           *)
(* Analysis of Grover probability amplification experiments  *)
(*                                                           *)
(* Oracle-family independent probability analysis            *)
(*************************************************************)


From Coq Require Import List Arith Reals.

Import ListNotations.


Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.Oracles.

Require Import Quantum.QuantumState.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverOracles.
Require Import Grover.GroverConvergenceExperiment.
Require Import Grover.GroverExperiments.
Require Import Grover.GroverExperimentResults.
Require Import Grover.GroverProbabilityExperiments.



(*************************************************************)
(* Probability Curves                                        *)
(*************************************************************)


Definition GroverProbabilityCurve
           (n : nat)
           (f : OracleInstance)
           : list (nat * R)
:=

ProbabilityCurve
  (GroverProbabilityExperiment n f).



(*************************************************************)
(* Example Curves                                             *)
(*************************************************************)


(* Single marked state *)

Definition GroverProbabilityCurve_single_n3
:

list (nat * R)

:=

GroverProbabilityCurve
 3
 (oracle_grover_single (all_zeros 3)).



Definition GroverProbabilityCurve_single_n4
:

list (nat * R)

:=

GroverProbabilityCurve
 4
 (oracle_grover_single (all_zeros 4)).



Definition GroverProbabilityCurve_single_n5
:

list (nat * R)

:=

GroverProbabilityCurve
 5
 (oracle_grover_single (all_zeros 5)).



(* Multiple marked states *)

Definition GroverProbabilityCurve_multiple
:

list (nat * R)

:=

GroverProbabilityCurve
 2
 oracle_grover_two.



(*************************************************************)
(* Curve Structural Properties                                *)
(*************************************************************)


Lemma GroverProbabilityCurve_length :

forall n f,

length
 (GroverProbabilityCurve n f)

=

length
 (GroverProbabilityExperiment n f).


Proof.

intros n f.

unfold GroverProbabilityCurve.

unfold ProbabilityCurve.

apply map_length.

Qed.



(*************************************************************)
(* Marked State Correctness                                  *)
(*************************************************************)


Lemma GroverProbability_records_marked_state :

forall n f d,

In d
 (GroverProbabilityExperiment n f)

->

exists marked,

GroverMarkedState n f = Some marked

/\

DataState d = marked.


Proof.

intros n f d H.


unfold GroverProbabilityExperiment in H.


apply GroverConvergenceData_state.


exact H.


Qed.



(*************************************************************)
(* Experiment Length                                         *)
(*************************************************************)


Lemma GroverProbability_length :

forall n f marked,

GroverMarkedState n f = Some marked

->

length
 (GroverProbabilityExperiment n f)

=

length
 (ExampleGroverTrace n f).


Proof.

intros n f marked H.


unfold GroverProbabilityExperiment.


unfold GroverConvergenceData.


rewrite H.


simpl.


apply TraceToData_length.


Qed.



(*************************************************************)
(* Final Probability                                         *)
(*************************************************************)


Fixpoint FinalProbability
         (data : list GroverDataPoint)
         : option R :=


match data with

| [] =>

    None


| [d] =>

    Some (DataProbability d)


| _ :: rest =>

    FinalProbability rest

end.



Definition GroverFinalProbability
           (n : nat)
           (f : OracleInstance)
:=

FinalProbability
(
 GroverProbabilityExperiment n f
).



(*************************************************************)
(* Probability Query                                         *)
(*************************************************************)


Fixpoint ProbabilityAt
         (i : nat)
         (curve : list (nat * R))
         : option R :=


match curve with


| [] =>

    None


| (iteration,p)::rest =>


    if Nat.eqb i iteration

    then Some p

    else ProbabilityAt i rest


end.



Definition ProbabilityAtIteration
           (n : nat)
           (f : OracleInstance)
           (i : nat)
:=

ProbabilityAt
 i
 (GroverProbabilityCurve n f).



(*************************************************************)
(* Example Queries                                           *)
(*************************************************************)


Definition P_single_n5_it0 :=

ProbabilityAtIteration
5
(oracle_grover_single (all_zeros 5))
0.



Definition P_single_n5_it1 :=

ProbabilityAtIteration
5
(oracle_grover_single (all_zeros 5))
1.



Definition P_multiple_it0 :=

ProbabilityAtIteration
2
oracle_grover_two
0.



(*************************************************************)
(* Iteration Extraction                                      *)
(*************************************************************)


Definition GroverProbabilityIterations
           (n : nat)
           (f : OracleInstance)
           : list nat
:=

map
 DataIteration
 (GroverProbabilityExperiment n f).



(*************************************************************)
(* Prevent Huge Reduction During Computation                  *)
(*************************************************************)


Opaque
GroverProbabilityCurve_single_n5.
