COQMF ?= Makefile.coq

all:
	coq_makefile -f _CoqProject -o $(COQMF)
	$(MAKE) -f $(COQMF)

clean:
	rm -f *.glob
	rm -f *.vo *.vos *.vok
	rm -f theories/*.vo theories/*.vos theories/*.vok theories/*.glob
	rm -f $(COQMF)

# TO run properly, use wsl command since that is where rocq language is installed.