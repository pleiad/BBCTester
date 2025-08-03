open Type
open Util


(* Find out current architecture (only supporting Linux/OS X for now) *)
let bin_format =
  let out, _ , _ = CCUnix.call "uname -s" in
  let arch = String.trim out in
  match arch with
  | "Linux" -> "elf64"
  | "Darwin" -> "macho64"
  | _ -> Fmt.failwith "Unknown architecture %s" arch


let nasm basefile =
  print_output @@ (wrap_result RTError) @@
  CCUnix.call "nasm -f %s -o %s.o %s.s" bin_format basefile basefile

let clang ~compile_flags runtime basefile =
  print_output @@ (wrap_result RTError) @@
  CCUnix.call "clang %s -o %s.run %s %s.o" compile_flags basefile runtime basefile

let gcc ~compile_flags runtime basefile =
  print_output @@ (wrap_result RTError) @@
  CCUnix.call "gcc %s -o %s.run %s %s.o" compile_flags basefile runtime basefile

let call command params file =
  let warning = true in
  process_output @@ (wrap_result ~warning RTError) @@
  CCUnix.call ~env:(Array.of_list params) command file


(** Calling the compiler (clang) and assembler (nasm) *)
let clang_runtime
    ?(compile_flags: string ="-g")
    (runtime : string) =
    fun
    (test : t)
    (input : string) ->
  let base = Filename.chop_extension test.file in
  let file = base ^ ".s" in
  let exe = base ^ ".run" in
  
  let* () = write_file RTError file input in
  let* () = nasm base in
  let* () = clang ~compile_flags runtime base in
  let* out = call "./%s" test.params exe in
  Ok out

(** Calling the compiler (gcc) and assembler (nasm) *)
let gcc_runtime
?(compile_flags: string ="-g")
(runtime : string) =
fun
(test : t)
(input : string) ->
let base = Filename.chop_extension test.file in
let file = base ^ ".s" in
let exe = base ^ ".run" in

let* () = write_file RTError file input in
let* () = nasm base in
let* () = gcc ~compile_flags runtime base in
let* out = call "./%s" test.params exe in
Ok out

(** Calling a unix command *)
let unix_command
    (command) =
    fun
    (test : t)
    (input : string) ->
  let base = Filename.chop_extension test.file in
  let file = base ^ ".s" in

  let* () = write_file RTError file input in
  let* out = call command test.params file in
  Ok out

(** Directly passing the compiled code *)
let direct_output
    ?(save_file: bool =false) =
    fun
    (test : t)
    (input : string) ->
  let base = Filename.chop_extension test.file in
  let file = base ^ ".s" in
  
  let* () =
    if save_file then
      write_file RTError file input
    else Ok () in
  Ok (process_string input)

(** Not implemented runtime *)
let not_implemented =
    fun
    (_ : t)
    (_ : string) ->
  Error (RTError, "Not implemented")
