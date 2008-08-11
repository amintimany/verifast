open Verifast

let _ =
  let print_msg l msg =
    print_endline (string_of_loc l ^ ": " ^ msg)
  in
  let verify verbose path =
    try
      let channel = open_in path in
      let stream = Stream.of_channel channel in
      verify_program verbose path stream (fun _ -> ()) (fun _ -> ());
      print_endline "0 errors found";
      exit 0
    with
      ParseException (l, msg) -> print_msg l ("Parse error" ^ (if msg = "" then "." else ": " ^ msg)); exit 1
    | StaticError (l, msg) -> print_msg l msg; exit 1
    | SymbolicExecutionError (ctxts, phi, l, msg) ->
        let _ = print_endline "Trace:" in
        let _ = List.iter (fun c -> print_endline (string_of_context c)) (List.rev ctxts) in
        (*
        let _ = print_endline ("Heap: " ^ string_of_heap h) in
        let _ = print_endline ("Env: " ^ string_of_env env) in
        *)
        let _ = print_endline ("Failed query: " ^ simp phi) in
        let _ = print_msg l msg in
        exit 1
  in
  match Sys.argv with
    [| _; path |] -> verify false path
  | [| _; "-verbose"; path |] -> verify true path
  | _ ->
    print_endline "Verifast 0.2 for C";
    print_endline "Usage: verifast [-verbose] filepath";
    print_endline "Note: Requires z3.exe."