open Opium
open Repo
open Repo.Db

let convert_to_response entries =
  let as_json = Response.of_json @@ Model.entries_to_json entries in
  Lwt_result.return as_json

let find_all _ =
  Logs.info (fun m -> m "Finding all");
  let get_all =
    let ( let* ) = Lwt_result.bind in
    let* conn = Util.connect () in
    let entries = Db.find_all conn in
    Lwt_result.bind entries convert_to_response
  in
  Lwt.bind get_all (fun r ->
      match r with Ok r -> Lwt.return r | Error _ -> raise @@ Failure "")

let put_entry req =
  Logs.info (fun l -> l "adding entry");
  let insert =
    let open Lwt.Syntax in
    let+ json = Request.to_json_exn req in
    let entry = Model.entry_of_yojson json in
    (* manually declare let* as from Lwt_result as it's also available on the base Lwt *)
    let ( let* ) = Lwt_result.bind in
    let* conn = Util.connect () in
    match entry with
    | Ok e -> Db.insert conn e.short_url e.target_url
    | Error e -> raise @@ Failure e
  in
  let bind_insert insert_response =
    Lwt.bind insert_response (fun bind_response ->
        Lwt.return
        @@
        match bind_response with
        | Ok _ -> Response.of_plain_text "Hooray"
        | Error _ ->
            Response.of_plain_text ~status:`Bad_request
              "Oh no something went wrong")
  in

  Lwt.bind insert bind_insert

let _ =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Starting run");
  App.empty |> App.get "/entry" find_all |> App.put "/entry" put_entry
  |> App.run_command
