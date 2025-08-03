open Type


(** [read_test s] parses the content of a test file provided in the string s
    returns None if any error occurred while reading the file (prints to stderr)

    The file format is composed of a few sections that appear in the following order:
    - `NAME:` [optional, default empty] : the name of the test
    - `DESCRIPTION:` [optional, default empty] : a longer description of the content of the test
    - `PARAMS:` [optional, default empty] : a `,`-separated list of pairs `VAR=VAL` that are adde to the environment variables of the compiled executable
    - `STATUS:` [optional, default `No error`] : either `CT error` (compile time error), `RT error` (runtime error) or `No error`/ Needs to be set to the appropriate error if the program is expected to fail either at compile time or at runtime. In that case the content of `EXPECTED:` is interpreted as a pattern (see [Str](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Str.html)) matched against the output of the failing phase.
    - `SRC:` : the source of the program def to the compiler
    - `EXPECTED:` : the expected result of the program (note that debugging messages starting by `|` are ignored and shouldn't be part of the expected result). If the expected result ends with the message `|INTERPRET` then the expected result is obtained by subsituting `|INTERPRET` with the result of evaluating the interpreter on the source code.
 *)
val read_test : string -> t option
