(lang dune 2.9)


(name bbctester)
(generate_opam_files true)

(authors "Kenji Maillard")
(maintainers "kenji@maillard.blue")

(package
  (name bbctester)
  (version 0.1)
  (synopsis "Black-box compiler tester")
  (description "Tester for the compilation lecture CC5116")
  (depends
    (ocaml (>= 4.08.0))
    (alcotest (>= 1.2.2))
    (containers (>= 3.0.1)))
  )
