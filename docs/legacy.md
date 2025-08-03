## Entrypoint

This package contains a few helper functions to parse test files (see below for the format) and generate unit-tests for alcotest. The main entrypoint of the library is the following function (from `test.mli`).

```ocaml
(* Given the path of a C runtime file [runtime], a [compiler] and
  the path [dir] of a directory containing tests files, produces
  unit tests for each test files in [dir].
 [compile_flags] are passed to the C compiler (clang),
 defaults to "-g".  *)
val tests_from_dir :
  ?compile_flags:string ->
  runtime:string ->
  compiler:compiler ->
  ?oracle:(string -> status * string) ->
  string -> (string * unit Alcotest.test_case list) list
```

```ocaml
(* Example of using tests_from_dir *)
open Bbctester.Test

(* .......... *)

(* Entry point of tester *)
let () =
  let bbc_tests = 

    let compile_flags = Option.value (Sys.getenv_opt "CFLAGS") ~default:"-g" in
    let compiler : string -> out_channel -> unit = 
      fun s o -> fprintf o "%s" (compile_prog (parse_prog (sexp_from_string s))) in

    let oracle : string -> status * string = (
      fun s -> (
        try
          NoError, program_output (interp_prog (parse_prog (sexp_from_string s)) empty_env)
        with
        | RTError msg -> RTError, msg
        | CTError msg -> CTError, msg
        |  e -> RTError, "Oracle raised an unknown error :"^ Printexc.to_string e 
      )
    ) in
    tests_from_dir ~compile_flags ~compiler ~oracle ~runtime:"rt/sys.c" "bbctests" in

  run "Tests CC5116 Compiler" (ocaml_tests @ bbc_tests)
```