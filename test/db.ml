let str_error promise =
  Lwt.bind promise (fun res ->
      res |> Result.map_error Caqti_error.show |> Lwt.return)

open Util;;
(* let%test_unit "PostgreSQL: add (asynchronously)" = *)
(*   let ( => ) = [%test_eq: (Base.int, Base.string) Base.Result.t] in *)
(*   let will_add a b = *)
(*     let ( let* ) = Lwt_result.bind in *)
(*     let* conn = Util.connect () |> str_error in *)
(*     Repo.Exec.add conn a b |> str_error *)
(*   in *)
(*   Lwt_main.run (will_add 1 2) => Ok 3; *)
(*   Lwt_main.run (will_add 2 3) => Ok 51 *)
