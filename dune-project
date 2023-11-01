(lang dune 3.11)

(name shorty)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Luke McPhee")

(maintainers "Luke McPhee")

(license MIT)

(documentation https://funwithfunctors.com)

(package
 (name shorty)
 (synopsis "Simple url shortener")
 (description "URL shortener using opium and caqti (v2.x)")
 (depends ocaml dune
  lwt
  lwt_ppx
  core
  caqti
  caqti-lwt
  caqti-driver-postgresql
  ppx_inline_test
  ppx_deriving_yojson
  ; api
  opium
)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
