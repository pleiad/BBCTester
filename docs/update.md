## Entrypoint

This package contains a few helper functions to parse test files (see below for the format) and generate unit-tests for alcotest. The main entrypoint of the library is the following function (from `main.mli`).

```ocaml
(* Given a [name], a [compiler], a [runtime], a [oracle], a [action] and
  the path [dir] of a directory containing tests files, produces
  unit tests for each test files in [dir]. *)
val tests_from_dir :
  name:string ->
  compiler:compiler ->
  ?runtime:runtime ->
  ?oracle:runtime ->
  ?testeable:testeable ->
  string -> (string * unit Alcotest.test_case list) list
```

```ocaml
(* Example of using tests_from_dir *)
open Bbctester.Type
open Bbctester.Main
open Bbctester.Runtime

(* .......... *)

(* Entry point of tester *)
let () =

  let compiler : compiler = 
    SCompiler ( fun _ s -> (compile_prog (parse_prog (sexp_from_string s))) ) in

  let compile_flags = Option.value (Sys.getenv_opt "CFLAGS") ~default: "-z noexecstack -g -m64 -fPIE -pie" in
  let runtime : runtime = (clang_runtime ~compile_flags "rt/sys.c") in
  
  let oracle : runtime = 
    Runtime ( fun _ s -> (
      try Ok (string_of_val (interp_prog (parse_prog (sexp_from_string s)) empty_env))
      with
      | RTError msg -> Error (RTError, msg)
      | CTError msg -> Error (CTError, msg)
      | e -> Error (RTError, "Oracle raised an unknown error :" ^ Printexc.to_string e)
    ))
  in
  
  let bbc_tests =
    let name : string = "bbc" in
    tests_from_dir ~name ~compiler ~runtime ~oracle "bbctests" in
  
  run "Tests CC5116 Compiler" (ocaml_tests @ bbc_tests)
```