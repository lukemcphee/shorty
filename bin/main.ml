open Opium
open Repo
open Repo.Db

let convert_to_response entries =
  let as_json = Response.of_json @@ Model.entries_to_json entries in
  Lwt_result.return as_json

let find_all _ =
  Logs.info (fun m -> m "Starting run");

  let get_all =
    let ( let* ) = Lwt_result.bind in
    let* conn = Util.connect () in
    let entries = Db.find_all conn in
    Lwt_result.bind entries convert_to_response
  in
  let o =
    Lwt.bind get_all (fun r ->
        match r with Ok r -> Lwt.return r | Error _ -> raise @@ Failure "")
  in
  o

let put_entry req =
  let local = 
    let open Lwt.Syntax in
    let+ json = Request.to_json_exn req in
    let ( let* ) = Lwt_result.bind in
    let entry = Model.entry_of_yojson json in
    let* conn = Util.connect () in
    let a =
      match entry with
      | Ok e -> Db.insert conn e.short_url e.target_url
      | Error _ -> raise @@ Failure ""in 
    a
  in
  Lwt.bind local (fun _ ->
      Lwt.return @@ Response.of_plain_text "") 

(* let _ = *)
(*   Lwt.bind body (fun b -> *)
(*       let _ = Logs.info (fun l -> l "body is %s" b) in *)
(*       Lwt.return b) *)
(* in *)
(* Response.of_plain_text "hmmm" *)

let _ =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Starting run");
  App.empty
  |> App.get "/entry" find_all
  |> App.put "/entry" put_entry
  |> App.run_command
