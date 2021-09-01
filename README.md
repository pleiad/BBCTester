# BBCTester
Black-Box Compiler Tester

A simple library for black-box testing of compilers from the [Compiler Design and Implementation course at UChile](https://users.dcc.uchile.cl/~etanter/CC5116/).

## Dependencies
- dune (>= 2.9)
- ocaml (>= 4.08.0)
- alcotest (>= 1.2.2)
- containers (>= 3.0.1)

## Installation


Download the sources as a zip archive, unzip and install the package
```bash
$ unzip BBCTester-main.zip
Archive:  BBCTester-main.zip
002d4d44e78e9655eff48580f1820961fd2ec520
   creating: BBCTester-main/
  inflating: BBCTester-main/.gitignore  
  inflating: BBCTester-main/Makefile  
  inflating: BBCTester-main/README.md  
  inflating: BBCTester-main/dune     
  inflating: BBCTester-main/dune-project  
  inflating: BBCTester-main/test.ml  
  inflating: BBCTester-main/test.mli

$ cd BBCTester-main

$ make install
dune build
dune install         
Installing ...
```

Alternatively, you can clone the repository and install
```bash
$ git clone https://github.com/pleiad/BBCTester.git
Cloning into 'BBCTester'...
remote: Enumerating objects: 19, done.
remote: Counting objects: 100% (19/19), done.
remote: Compressing objects: 100% (15/15), done.
remote: Total 19 (delta 3), reused 12 (delta 3), pack-reused 0
Receiving objects: 100% (19/19), 7.10 KiB | 7.10 MiB/s, done.
Resolving deltas: 100% (3/3), done.

$ cd BBCTester

$ make install
dune build
dune install         
Installing ...

```


# Usage

## Entrypoint

This package contains a few helper functions to parse test files (see below for the format) and generate unit-tests for alcotest in a single module `Test`. The main entrypoint of the library is the following function (from `test.mli`). 

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
  ?interpreter:(string -> string) ->
  string -> (string * unit Alcotest.test_case list) list
```


## Tests files (*.bbc)

A BBCTester test file contains both a source program to be fed to the compiler and various metadata to help testing the compiler.
Here is how it looks like:
```
NAME: add1
DESCRIPTION: increments a number

SRC:
(add1 20)

EXPECTED:
21
```


It uses the extension `.bbc` and is composed of a few sections that appear in the following order:
- `NAME:` [optional, default empty] : the name of the test
- `DESCRIPTION:` [optional, default empty] : a longer description of the content of the test
- `PARAMS:` [optional, default empty] : a `,`-separated list of pairs `VAR=VAL` that are added to the environment variables of the compiled executable
- `STATUS:` [optional, default `No error`] : either `CT error` (compile time error), `RT error` (runtime error) or `No error`/ Needs to be set to the appropriate error if the program is expected to fail either at compile time or at runtime. In that case the content of `EXPECTED:` is interpreted as a pattern (see [Str](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Str.html)) matched against the output of the failing phase.
- `SRC:` : the source of the program fed to the compiler
- `EXPECTED:` : the expected result of the program (note that debugging messages starting by `|` are ignored and shouldn't be part of the expected result). If the expected result ends with the message `|INTERPRET` then the expected result is obtained by substituting `|INTERPRET` with the result of evaluating the interpreter on the source code.
