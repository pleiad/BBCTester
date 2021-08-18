
(** Expected status of a test *)
type status =
  | CTError
    (* Compile-time error *)
  | RTError
    (* Run-time error *)
  | NoError
    (* No error *)


(** Conversion functions between string and status *)
(* Accepted strings:
   - "fail", "RT error"  <-> RTError
   - "CT error"  <-> CTError
   - anything else correspond to NoError *)
val status_of_string : string -> status
val string_of_status : status -> string


(** Ocaml representation of test files
 * All strings are enforced to be trimmed.
 *)
type t =
  { name : string
    (* Name of the test *)
  ; description : string
    (* Description of the test *)
  ; params : string list
    (* parameters passed to the test as environment variables *)
  ; status : status
    (* Expected status of the result *)
  ; src : string
    (* source program for the test *)
  ; expected : string
    (* expected result of the test *) }

(** [read_test s] parses the content of a test file provided in the string s
 * returns None if any error occurred while reading the file (prints to stderr)
 *
 * The file format is composed of a few sections that appear in the following order:
 * - `NAME:` [optional, default empty] : the name of the test
 * - `DESCRIPTION:` [optional, default empty] : a longer description of the content of the test
 * - `PARAMS:` [optional, default empty] : a `,`-separated list of pairs `VAR=VAL` that are adde to the environment variables of the compiled executable
 * - `STATUS:` [optional, default `No error`] : either `CT error` (compile time error), `RT error` (runtime error) or `No error`/ Needs to be set to the appropriate error if the program is expected to fail either at compile time or at runtime. In that case the content of `EXPECTED:` is interpreted as a pattern (see [Str](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Str.html)) matched against the output of the failing phase.
 * - `SRC:` : the source of the program def to the compiler
 * - `EXPECTED:` : the expected result of the program (note that debugging messages starting by `|` are ignored and shouldn't be part of the expected result). If the expected result ends with the message `|INTERPRET` then the expected result is obtained by subsituting `|INTERPRET` with the result of evaluating the interpreter on the source code.
 *)
val read_test : string -> t option

(* A compiler is a function taking an output formatter and a filename *)
type compiler = Format.formatter -> string -> unit

(* [testfiles_in_dir path] collects the content of all thet `*.test` files
 * found at [path]; uses `find` (GNU findutils)
 *)
val testfiles_in_dir : string -> string list

(* Given the path of a C runtime file [runtime], a [compiler] and
  the path [dir] of a directory containing tests files, produces
  unit tests for each test files in [dir].
 [compile_flags] are passed to the C compiler (clang),
 defaults to "-g".  *)
val tests_from_dir :
  ?compile_flags:string ->
  runtime:string ->
  compiler:compiler ->
  ?interpreter:(string -> string) ->
  string -> (string * unit Alcotest.test_case list) list
