open Opium

let yojson_example = `Assoc [ ("name", `String "hello luke") ]

(* let find_all _ = *)
(*   let ( let* ) = Lwt_result.bind in *)
(*   let* conn = Util.connect () in *)
(*   let res = Db.find_all conn |> str_error in *)
(*   let _ = Lwt.bind res (fun r -> Lwt.return r) in *)
(*   Response.of_json yojson_example *)

let find_all _ = Lwt.return @@ Response.of_json yojson_example

let print_param_handler req =
  Printf.sprintf "Hello, %s\n" (Router.param req "name")
  |> Response.of_plain_text |> Lwt.return

let _ =
  App.empty
  |> App.get "/hello/:name" print_param_handler
  |> App.get "/entry" find_all |> App.run_command
