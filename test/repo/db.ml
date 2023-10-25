open Repo.Db.Entry

let str_error promise =
  Lwt.bind promise (fun res ->
      res |> Result.map_error Caqti_error.show |> Lwt.return)

(* let drop_id_from_entry triple = *)
(*   let _, b, c = triple in *)
(*   (b, c) *)
let drop_id_from_entry triple = (triple.short_url, triple.target_url)

let%test_unit "PostgreSQL: add (asynchronously)" =
  let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in
  let will_add a b =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Util.connect () |> str_error in
    Repo.Db.add conn a b |> str_error
  in
  Lwt_main.run (will_add 1 2) => Ok 3

let%test_unit "Able to add to the database" =
  let ( => ) =
    [%test_eq:
      ((Base.string * Base.string) Base.list, Base.string) Base.Result.t]
  in
  let input_url = "hello" in
  let target_url = "luke" in
  let add_entry =
    let ( let* ) = Lwt_result.bind in
    let* conn = Repo.Util.connect () |> str_error in
    let* _ = Repo.Db.insert conn input_url target_url |> str_error in
    Lwt_result.bind (Repo.Db.find_all conn) (fun res ->
        Lwt_result.return @@ List.map drop_id_from_entry res)
    |> str_error
  in
  Lwt_main.run add_entry => Ok [ (input_url, "luke") ]
