module Model = struct
  type entry = { short_url : string; target_url : string } [@@deriving yojson]
  type entry_list = entry list [@@deriving yojson]

  let entries_to_json entries = entry_list_to_yojson entries

  let tuple_to_entry tup =
    let a, b = tup in
    let entry : entry = { short_url = a; target_url = b } in
    entry

  let entry_to_json (a : entry) = entry_to_yojson a
end

module Q = struct
  open Caqti_request.Infix

  (*
    Caqti infix operators

    ->! decodes a single row
    ->? decodes zero or one row
    ->* decodes many rows
    ->. expects no row
  *)

  (* `add` takes 2 ints (as a tuple), and returns 1 int *)
  let add = Caqti_type.(t2 int int ->! int) "SELECT ? + ?"

  let insert =
    Caqti_type.(t2 string string ->. unit)
      {|
       INSERT INTO entry (short_url, target_url)
       VALUES (?, ?)
      |}

  let select =
    Caqti_type.(unit ->* t2 string string)
      {|
       SELECT short_url
            , target_url
       FROM entry 
      |}
end

let add (module Conn : Caqti_lwt.CONNECTION) a b = Conn.find Q.add (a, b)

let insert (module Conn : Caqti_lwt.CONNECTION) short_url target_url =
  Conn.exec Q.insert (short_url, target_url)

let find_all (module Conn : Caqti_lwt.CONNECTION) =
  let result_tuples = Conn.collect_list Q.select () in
  Lwt_result.bind result_tuples (fun xs ->
      let out = List.map Model.tuple_to_entry xs in
      Lwt_result.return out)

let resolve_ok_exn promise =
  match Lwt_main.run promise with
  | Error _ -> failwith "Oops, I encountered an error!"
  | Ok n -> n
