include Type


let testfiles_in_dir dir =
  CCUnix.with_process_in ("find " ^ dir ^ " -name '*.bbc'") ~f: CCIO.read_lines_l


let oracle_from_legacy (oracle : (string -> status * string) option) : runtime option =
  match oracle with
  | Some runtime ->
    Some (fun _ s ->
    (match runtime s with
    | NoError, value -> Ok (value)
    | error, value -> Error (error, value)))
  | None -> None

let tests_from_dir ?(compile_flags="-g") ~runtime ~compiler ?oracle dir =
  let compiler = OCompiler (fun _ -> compiler) in
  let runtime = Runtime.clang_runtime ~compile_flags runtime in
  let oracle = oracle_from_legacy oracle in

  let open Alcotest in
  let to_test testfile =
    let testname, exec_test = Main.make_test ~compiler ~runtime ?oracle testfile in
    Main.name_from_file "" testfile, [test_case testname `Quick exec_test]
  in
  testfiles_in_dir dir
  |> List.map to_test
  |> List.sort (fun (s1,_) (s2,_) -> String.compare s1 s2)

(* Use as follow: *)
(* run "Tests" @@ List.map tests_from_dir [ "failing"; "tests"] *)
