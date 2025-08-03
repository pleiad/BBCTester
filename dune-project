(lang dune 3.10)


(name bbctester)

; Not using opam because of not understood bug with generated `dune subst --root`
; (generate_opam_files true)

(authors "Kenji Maillard")
(maintainers "kenji@maillard.blue")

(package
  (name bbctester)
  (version 0.3)
  (synopsis "Black-box compiler tester")
  (description "Tester for the compilation lecture CC5116")
  (depends
    (ocaml (>= 4.08.0))
    (alcotest (>= 1.2.2))
    (containers (>= 3.0.1)))
  )
