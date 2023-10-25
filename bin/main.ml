open Opium
open Repo
open Repo.Db

module Local = struct
  type entry_list = Entry.t list [@@deriving yojson]

  let json entries = entry_list_to_yojson entries
end

let yojson_example name = `Assoc [ ("name", `String ("hello " ^ name)) ]

let convert_to_response entries =
  let as_json = Response.of_json @@ Local.json entries in
  Lwt_result.return as_json

let find_all _ =
  let output =
    let ( let* ) = Lwt_result.bind in
    let* conn = Util.connect () in
    let entries = Db.find_all conn in
    Lwt_result.bind entries convert_to_response
  in
  Lwt.bind output (fun r ->
      match r with Ok r -> Lwt.return r | Error _ -> raise @@ Failure "")

let print_param_handler req =
  yojson_example (Router.param req "name") |> Response.of_json |> Lwt.return

let _ =
  App.empty
  |> App.get "/hello/:name" print_param_handler
  |> App.get "/entry" find_all |> App.run_command
