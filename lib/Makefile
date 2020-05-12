include ../Makefile.config

OCAMLC=ocamlc -g
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep
OCAMLLIB=`ocamlc -where`
CAMLJAVALIB=$(OCAMLLIB)/camljava

all: jni.cma jni.cmxa camljava.jar
byte: jni.cma camljava.jar

install:
	mkdir -p $(CAMLJAVALIB)
	cp jni.cma jni.cmi $(wildcard jni.cmxa jni.a) libcamljni.so jni.mli camljava.jar $(CAMLJAVALIB)

jni.cma: jni.cmo dllcamljni.so
	$(OCAMLC) -linkall -a -o jni.cma -custom jni.cmo \
            -ccopt "$(JNILIBOPTS)" -cclib -lcamljni -dllib -lcamljni -cclib $(JNILIBS)

jni.cmxa: jni.cmx dllcamljni.so
	$(OCAMLOPT) -linkall -a -o jni.cmxa jni.cmx \
            -ccopt "$(JNILIBOPTS)" -cclib -lcamljni -cclib "$(JNILIBS)"

dllcamljni.so: jnistubs.o
	rm -f libcamljni.so
	$(CC) -shared -o dllcamljni.so jnistubs.o $(JNILIBOPTS) -ljvm

clean::
	rm -f libcamljni.a

jni.ml: jni.mlp jni.mli ../Makefile.config
	rm -f jni.ml
	sed -e 's|%PATH%|'$(CAMLJAVALIB)/camljava.jar'|' \
                jni.mlp > jni.ml
	chmod -w jni.ml

clean::
	rm -f jni.ml

beforedepend:: jni.ml

camljava.jar: javaclasses
	jar cf camljava.jar fr/inria/caml/camljava/*.class

clean::
	rm -f camljava.jar

javaclasses:
	$(JAVAC) fr/inria/caml/camljava/*.java

clean::
	rm -f fr/inria/caml/camljava/*.class

clean::
	rm -f *.cm? *.[oa] *.cmxa

.SUFFIXES: .ml .mli .cmo .cmi .cmx

.c.o:
	$(CC) -c $(CFLAGS) $(JNIINCLUDES) -I$(OCAMLLIB) $*.c

.ml.cmo:
	$(OCAMLC) -c $*.ml

.ml.cmx:
	$(OCAMLOPT) -c $*.ml

.mli.cmi:
	$(OCAMLC) -c $*.mli

depend: beforedepend
	$(OCAMLDEP) *.mli *.ml > .depend

include .depend

