let get_uri () = "postgres://example-username:pass@localhost:5432/shorty-db"

(* let str_error promise = *)
(*   Lwt.bind promise (fun res -> *)
(*       res |> Result.map_error Caqti_error.show |> Lwt.return) *)

let str_error promise =
  Lwt.bind promise (fun res ->
      res |> Result.map_error Caqti_error.show |> Lwt.return)

let connect () =
  let uri = get_uri () in
  Caqti_lwt_unix.connect (Uri.of_string uri)

(** For `utop` interactions interactions. See `README.md`.
 *)
let connect_exn () =
  let conn_promise = connect () in
  match Lwt_main.run conn_promise with
  | Error err ->
      let msg =
        Printf.sprintf "Abort! We could not get a connection. (err=%s)\n"
          (Caqti_error.show err)
      in
      failwith msg
  | Ok module_ -> module_
