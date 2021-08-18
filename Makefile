all:
	dune build

install: all
	dune install

uninstall: all
	dune uninstall

clean:
	dune clean
