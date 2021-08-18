bbctester.opam:
	dune build @install

install: bbctester.opam
	opam install .

clean:
	dune clean
	rm bbctester.opam
