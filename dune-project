(lang dune 3.11)

(name shorty)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name shorty)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune
  lwt
  lwt_ppx
  caqti
  caqti-lwt
  caqti-driver-postgresql
  ppx_inline_test
  ; api
  opium
)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
