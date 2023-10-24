open Opium

let print_param_handler req =
  Printf.sprintf "Hello, %s\n" (Router.param req "name")
  |> Response.of_plain_text
  |> Lwt.return

let _ =
  App.empty
  |> App.get "/hello/:name" print_param_handler
  |> App.run_command
