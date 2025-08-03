open Type


(** Helper functions on strings and processes *)
let filter_lines pred s =
  CCString.split ~by:"\n" s
  |> List.filter pred
  |> String.concat "\n"

let is_comment_line s =
  not (CCString.prefix ~pre:"|" s)

let process_string out =
  String.trim out |> filter_lines is_comment_line


(* Produce a result out of the return data from the compiler/assembler *)
let wrap_result ?(warning = false) error (out, err, retcode) =
  if retcode = 0 && (warning || String.equal "" err)
  then Ok out
  else Error (error, out ^ err)

let print_output out =
  let* out = out in
  print_string out; Ok ()

let process_output out =
  let* out = out in
  Ok (process_string out)


(** extract values from result *)
let handle_result result =
  match result with
  | Ok out -> NoError, out
  | Error err -> err


let process_out_channel error file channel =
  try Ok (CCIO.with_out file channel)
  with e -> Error (error, Printexc.to_string e)

let write_file error file string =
  try Ok (CCIO.with_out file (fun o -> output_string o string))
  with e -> Error (error, Printexc.to_string e)

let read_file error file =
  try Ok (process_string @@ (CCIO.with_in file CCIO.read_all))
  with e -> Error (error, Printexc.to_string e)


(* Capture stdout from a function *)
let has_pending_data fd =
  try
    let ready_fds, _, _ = Unix.select [fd] [] [] 0.0 in
    List.length ready_fds > 0
  with _ -> false

let capture_stdout (f : unit -> 'a) : string * 'a =
  let stdout_original = Unix.dup Unix.stdout in
  let (pipe_read, pipe_write) = Unix.pipe () in

  Unix.set_nonblock pipe_read;
  Unix.dup2 pipe_write Unix.stdout;
  Unix.close pipe_write;
  
  let buffer = Buffer.create 4096 in
  let string_buffer = Bytes.create 4096 in
  
  let result = 
    try 
      let r = f () in
      flush stdout;
      
      let rec read_remaining () =
        if has_pending_data pipe_read then
          match Unix.read pipe_read string_buffer 0 4096 with
          | 0 -> ()  (* EOF *)
          | bytes_read -> 
              Buffer.add_subbytes buffer string_buffer 0 bytes_read;
              read_remaining ()
          | exception Unix.Unix_error(Unix.EAGAIN, _, _) -> 
              Unix.sleepf 0.001;  (* Pequeña pausa si el pipe está temporalmente vacío *)
              if has_pending_data pipe_read then read_remaining ()
      in
      read_remaining ();
      Ok r
    with e -> Error e
  in
  
  Unix.dup2 stdout_original Unix.stdout;
  Unix.close stdout_original;
  Unix.close pipe_read;
  
  match result with
  | Ok v -> (Buffer.contents buffer, v)
  | Error e -> raise e
