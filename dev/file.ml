open Type


let test_regexp =
  Str.regexp "NAME:\\|DESCRIPTION:\\|PARAMS:\\|STATUS:\\|SRC:\\|EXPECTED:\\|END"

let get_opt s dflt tokens =
  let open Str in
  match tokens with
  | Delim s' :: Text content :: rest when s = s' ->
    String.trim content, rest
  | all -> dflt, all

let parse_content filename content =
  let open Str in
  let toks = full_split test_regexp content in
  let name, toks = get_opt "NAME:" Filename.(chop_extension @@ basename filename) toks in
  let description, toks = get_opt "DESCRIPTION:" "" toks in
  let params_string, toks = get_opt "PARAMS:" "" toks in
  let params = List.map String.trim (String.split_on_char ',' params_string) in
  let status, toks = get_opt "STATUS:" "ok" toks in
  match toks with
  | Delim "SRC:" :: Text src ::
    Delim "EXPECTED:" :: Text expected :: ( [] | Delim "END" :: _ ) ->
    Some { file = filename; name; description; params; status = status_of_string status;
           src; expected = String.trim expected }
  | _ -> (Printf.fprintf stderr "Wrong format in test file %s" filename ; None)


let read_test filename =
  if Sys.file_exists filename
  then
    CCIO.(with_in filename read_all)
    |> String.trim
    |> parse_content filename
  else
    (Printf.fprintf stderr "Test file %s not found." filename ; None)
