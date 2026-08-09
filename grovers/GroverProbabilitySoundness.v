(*************************************************************)
(* GroverProbabilitySoundness.v                               *)
(*                                                           *)
(* Correctness bridge between Grover traces and probability   *)
(* experiments                                               *)
(*************************************************************)

From Coq Require Import List Arith Reals.

Import ListNotations.

Require Import forms.Foundations.BitStrings.

Require Import Quantum.QuantumState.
Require Import Quantum.AmplitudeSemantics.

Require Import Grover.GroverConvergenceExperiment.
Require Import Grover.GroverTrace.
Require Import Grover.GroverExperimentResults.
Require Import Grover.GroverProbabilityExperiments.
Require Import Grover.GroverProbabilityResults.

Lemma ProbabilityCurve_length :

forall data,

length (ProbabilityCurve data)
=
length data.

Proof.

  intros data.

  unfold ProbabilityCurve.

  apply map_length.

Qed.

Lemma ProbabilityCurve_iterations_preserved :

forall data d,

In d data
->

In
(DataIteration d,
 DataProbability d)
(ProbabilityCurve data).

Proof.

  intros data d H.

  unfold ProbabilityCurve.

  induction data as [|x xs IH].

  - simpl in H.
    contradiction.

  - simpl.

    destruct H as [H | H].

    + subst x.

      left.

      reflexivity.

    + right.

      apply IH.

      exact H.

Qed.

Lemma GroverExperiment_state_is_marked :

forall n f marked d,

GroverMarkedState n f = Some marked
->

In d (GroverConvergenceData n f)

->

DataState d = marked.

Proof.

  intros n f marked d Hmarked Hd.

  destruct (GroverConvergenceData_state n f d Hd)
    as [m [Hm Hstate]].

  rewrite Hmarked in Hm.

  inversion Hm.

  exact Hstate.

Qed.