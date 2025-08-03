include module type of Type


(** [testfiles_in_dir path] collects the content of all thet `*.bbc` files
    found at [path]; uses `find` (GNU findutils) *)
val testfiles_in_dir : string -> string list

(** [test_from_dir ~runtime ~compiler dir] generates alcotest tests
    for each test file present in [dir] and its subdirectories using
    [runtime] as path to a C runtime to be linked against and [compiler]
    to process the sources.
    [compile_flags] are passed to the C compiler (clang),
    defaulting to "-g".
    The optional [oracle] parameter is an oracle (eg. an interpreter, reference compiler) to be invoked on source files.
    It should return a result status together with the expected output of the corresponding program,
    that will be substituted in the first mention of `|ORACLE` in a test file, if any. *)
val tests_from_dir :
    ?compile_flags:string ->
    runtime:string ->
    compiler:(string -> out_channel -> unit) ->
    ?oracle:(string -> status * string) ->
    string -> (string * unit Alcotest.test_case list) list
