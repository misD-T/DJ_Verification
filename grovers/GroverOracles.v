(*************************************************************)
(* GroverOracles.v                                           *)
(*                                                           *)
(* Oracle Definitions for Grover Search                      *)
(*                                                           *)
(* This file defines the oracle functions used by the        *)
(* Grover search algorithm.                                  *)
(*                                                           *)
(* The initial implementation is intentionally restricted    *)
(* to a single marked element so that the verification       *)
(* framework can first be demonstrated before extending      *)
(* to more general search problems.                          *)
(*************************************************************)

From Coq Require Import Bool List.

Import ListNotations.

Require Import DJ.Foundations.BitStrings.
Require Import DJ.Oracles.BooleanFunctions.
Require Import DJ.Oracles.Oracles.

(*************************************************************)
(* Marked Element                                            *)
(*************************************************************)

(*
   Initial case study:

       marked = |11>

   This represents the unique solution that Grover's
   algorithm should amplify.
*)

Definition marked_state : BitString :=
  [true; true].

(*************************************************************)
(* Oracle Function                                           *)
(*************************************************************)

(*
   The oracle returns true exactly on the marked state.

   Later this can be generalised to multiple marked
   elements or arbitrary predicates.
*)

Definition grover_oracle_fun : Oracle :=
fun x =>

bitstring_eqb x marked_state.

(*************************************************************)
(* Oracle Instance                                           *)
(*************************************************************)

Definition oracle_grover : OracleInstance :=
{|
  oracle_kind := OKGrover;
  oracle_function := grover_oracle_fun
|}.

(*************************************************************)
(* Oracle Properties                                         *)
(*************************************************************)

(*
   These definitions are placeholders for future extensions.

   Examples:

     - Multiple marked elements
     - Parameterised search problems
     - Randomised search instances
*)

Definition SingleMarked : Prop :=

forall x,

grover_oracle_fun x = true

<->

x = marked_state.

(*************************************************************)
(* Future Extensions                                         *)
(*************************************************************)

(*
   Possible future oracle families:

   - Multiple marked states

   - Random marked states

   - Parameterised search predicates

   - SAT instances

   - Graph search instances

*)