module Entry = struct
  type t = {
        id : int;
  short_url : string;
  target_url : string;

  }
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
  [@@ocamlformat "disable"]

 let bike =
    let open Bike in
    let intro frameno owner stolen = {frameno; owner; stolen} in
    product intro
      @@ proj string (fun bike -> bike.frameno)
      @@ proj string (fun bike -> bike.owner)
      @@ proj (option ptime) (fun bike -> bike.stolen)
      @@ proj_end
end

let add (module Conn : Caqti_lwt.CONNECTION) a b =
  Conn.find Q.add (a, b)
[@@ocamlformat "disable"]

let resolve_ok_exn promise =
  match Lwt_main.run promise with
  | Error _ -> failwith "Oops, I encountered an error!"
  | Ok n -> n
