module Entry = struct
  type t = { id : int; short_url : string; target_url : string }
  let tuple_to_entry tup =
                    let (a,b,c) = tup in
                    let entry: t = {id = a; short_url = b; target_url = c} in
                    entry
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
  let add =
    Caqti_type.(t2 int int ->! int)
    "SELECT ? + ?"

  let insert =
    Caqti_type.(t3 int string string ->! int)
      {|
       INSERT INTO entry (id, short_url, target_url)
       VALUES (?, ?, ?) RETURNING id
      |}

  let select =
    Caqti_type.(unit ->* t3 int string string)
      {|
       SELECT id
            , short_url
            , target_url
       FROM entry 
      |}
end

let add (module Conn : Caqti_lwt.CONNECTION) a b =
  Conn.find Q.add (a, b)

let insert (module Conn : Caqti_lwt.CONNECTION) short_url target_url =
  let id = Random.int 10000 in 
  Conn.find Q.insert (id ,short_url ,target_url)

let find_all(module Conn : Caqti_lwt.CONNECTION) =
  let result_tuples = Conn.collect_list Q.select () in
  Lwt_result.bind result_tuples (fun xs ->
      let out = List.map Entry.tuple_to_entry xs in
      Lwt_result.return out)

let resolve_ok_exn promise =
  match Lwt_main.run promise with
  | Error _ -> failwith "Oops, I encountered an error!"
  | Ok n -> n
