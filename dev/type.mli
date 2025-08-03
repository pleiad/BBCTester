
(** Expected status of a test *)
type status =
  | CTError
    (** Compile-time error *)
  | RTError
    (** Run-time error *)
  | NoError
    (** No error *)


(** Conversion functions between string and status *)

(** [status_of_string s] accepts the following strings s :
    - "fail", "RT error"  <-> RTError
    - "CT error"  <-> CTError
    - anything else correspond to NoError *)
val status_of_string : string -> status

val string_of_status : status -> string


(** Ocaml representation of test files
    All strings are enforced to be trimmed.
 *)
type t =
  { file : string
    (** Name of the test file *)
  ; name : string
    (** Name of the test *)
  ; description : string
    (** Description of the test *)
  ; params : string list
    (** Parameters passed to the test as environment variables *)
  ; status : status
    (** Expected status of the result *)
  ; src : string
    (** Source program for the test *)
  ; expected : string
    (** expected result of the test *) }


(** Bind operator for results *)
val ( let* ) : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result


(** A compiler is a function that takes a source program as a string,
and return a string containing the result of the compilation. *)
type compiler =
| Compiler of (t -> string -> (string, status * string) result)
| OCompiler of (t -> string -> out_channel -> unit)
| SCompiler of (t -> string -> string)

(** A runtime is a function that takes a source program as a string,
and return a string containing the result of the execution. *)
type runtime = (t -> string -> (string, status * string) result)

type testeable = (t -> (status * string) Alcotest.testable)
