(*************************************************************)
(* GroverOracles.v                                           *)
(*                                                           *)
(* Oracle Definitions for Grover Search                      *)
(*                                                           *)
(*************************************************************)

From Coq Require Import Bool List Arith.

Import ListNotations.

Require Import forms.Foundations.BitStrings.
Require Import forms.Oracles.BooleanFunctions.
Require Import forms.Oracles.Oracles.


(*************************************************************)
(* Single Marked Oracle                                      *)
(*************************************************************)

(*
   Marks exactly one basis state.

   Equivalent to Python:

       single_marked_oracle(marked)
*)


Definition grover_single_marked
        (marked : BitString)
        : Oracle :=

fun x =>

bitstring_eqb x marked.



Definition oracle_grover_single
        (marked : BitString)
        : OracleInstance :=

{|
 oracle_kind := OKSingleMarked;
 oracle_function := grover_single_marked marked
|}.



(*************************************************************)
(* Multiple Marked Oracle                                    *)
(*************************************************************)

(*
   General Grover oracle.

   Marks every state contained in the marked list.

   Equivalent to Python:

       multiple_marked_oracle(marked_states)

   Examples:

       [ [true;true];
         [false;false] ]

       represents two marked states.

*)


Definition multiple_marked_oracle
        (marked_states : list BitString)
        : Oracle :=

fun x =>

existsb
    (bitstring_eqb x)
    marked_states.



Definition oracle_grover_multiple
        (marked_states : list BitString)
        : OracleInstance :=

{|
 oracle_kind := OKMultipleMarked;
 oracle_function := multiple_marked_oracle marked_states
|}.



(*************************************************************)
(* Example Multiple Marked Instances                         *)
(*************************************************************)


Definition marked_states_two : list BitString :=

[
 [true;true];

 [false;false]
].



Definition oracle_grover_two : OracleInstance :=

oracle_grover_multiple
    marked_states_two.



(*************************************************************)
(* Quarter Marked Instance                                   *)
(*************************************************************)

(*
   Quarter marked search.

   This is not a new oracle family.
   It is simply a multiple marked oracle where
   approximately N/4 states are marked.

   Example:

       first two bits are 1

   For n-bit inputs:

       11xxx...

*)


Definition quarter_marked
        (x : BitString)
        : bool :=

match x with

| true :: true :: _ =>
    true

| _ =>
    false

end.



Definition oracle_grover_quarter : OracleInstance :=

{|
 oracle_kind := OKMultipleMarked;

 oracle_function := quarter_marked
|}.



(*************************************************************)
(* Predicate Oracle                                           *)
(*************************************************************)

(*
   Arbitrary search predicate.

   Equivalent to Python:

       predicate_oracle(predicate)
*)


Definition predicate_oracle
        (P : BitString -> bool)
        : Oracle :=

fun x => P x.



Definition oracle_grover_predicate
        (P : BitString -> bool)
        : OracleInstance :=

{|
 oracle_kind := OKGroverPredicate;

 oracle_function := predicate_oracle P
|}.



(*************************************************************)
(* Example Predicates                                        *)
(*************************************************************)


Definition even_parity
        (x : BitString)
        : bool :=

Nat.even
(
 length
 (
  filter (fun b => b) x
 )
).



(*************************************************************)
(* Oracle Properties                                         *)
(*************************************************************)


Definition SingleMarked
        (marked : BitString)
        : Prop :=

forall x,

grover_single_marked marked x = true

<->
 
x = marked.



Definition MultipleMarked
        (marked_states : list BitString)
        : Prop :=

forall x,

multiple_marked_oracle marked_states x = true

<->

In x marked_states.



Definition PredicateMarked
        (P : BitString -> bool)
        : Prop :=

exists x,

P x = true.

(*************************************************************)
(* Future Extensions                                         *)
(*************************************************************)

   (*
      Possible future oracle families:

      - SAT search oracles

      - Graph search oracles

      - Constraint satisfaction predicates

      - Domain-specific search predicates

   *)