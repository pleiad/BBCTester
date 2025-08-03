open Type


let status_match =
  let open Alcotest in
  testable Fmt.(using string_of_status string) (=)

let string_ignore =
  function
    | _ ->
  let open Alcotest in
  let matches _ _ = true in
  testable (pp string) matches

let string_match =
  function
    | NoError -> Alcotest.string
    | _ ->
  let open Alcotest in
  let matches pat s =
    try let _ = Str.(search_forward (regexp pat) s 0) in true
    with Not_found -> false
  in
  testable (pp string) matches


(** Test pairs giving access to the first component when testing the second component *)
let dep_pair : type a b. a Alcotest.testable -> (a -> b Alcotest.testable) -> (a * b) Alcotest.testable =
  fun cmp1 cmp2 ->
  let open Alcotest in
  let cmp_pair (x1, x2) (y1, y2) = equal cmp1 x1 y1 && equal (cmp2 x1) x2 y2 in
  testable (fun fmt p -> pp (pair cmp1 (cmp2 (fst p))) fmt p) cmp_pair


(* Testing the status of running a test *)
let compare_status =
  fun (_ : t) ->
  dep_pair status_match string_ignore


(* Testing the result of running a test *)
let compare_results =  
  fun (_ : t) ->
  dep_pair status_match string_match
