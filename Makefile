#AS  = $(shell which gas)
CC  = $(shell which gcc)
CXX = $(shell which g++)

CFLAGS    = -Wall -Wextra -pedantic -O0 -lm
CXXFLAGS  = -Wall -Wextra -pedantic -O0

FAST_MATH = -ffast-math

TAG = isnan
SAY = $(shell which echo) -e "[$(TAG)]"

### Targets

all: gas obj test

clean:
	@$(SAY) "removing all intermediate files, objects, and executables"
	@$(RM) -fv *.s *.o *.gcc *.gxx

gas: $(TAG).slow.gcc.s $(TAG).slow.gxx.s $(TAG).fast.gcc.s $(TAG).fast.gxx.s
	@$(SAY) "finished building assemblies ($^) results:"
	diff "$(TAG).slow.gcc.s" "$(TAG).fast.gcc.s" || true
	diff "$(TAG).slow.gxx.s" "$(TAG).fast.gxx.s" || true

obj: $(TAG).slow.gcc.o $(TAG).slow.gxx.o $(TAG).fast.gcc.o $(TAG).fast.gxx.o
	@$(SAY) "finished building objects ($^) results:"
	@nm    "$(TAG).slow.gcc.o" "$(TAG).fast.gcc.o"
	@nm -C "$(TAG).slow.gxx.o" "$(TAG).fast.gxx.o"

test: $(TAG).slow.gcc   $(TAG).slow.gxx   $(TAG).fast.gcc   $(TAG).fast.gxx
	@$(SAY) "finished building executables ($^) results:"
	@-"./$(TAG).slow.gcc"; $(SAY) "$(TAG).slow.gcc thinks result is: $$?"
	@-"./$(TAG).fast.gcc"; $(SAY) "$(TAG).fast.gcc thinks result is: $$?"
	@-"./$(TAG).slow.gxx"; $(SAY) "$(TAG).slow.gxx thinks result is: $$?"
	@-"./$(TAG).fast.gxx"; $(SAY) "$(TAG).fast.gxx thinks result is: $$?"

.PHONY: all clean gas obj test

### Assemblies with/without FAST_MATH

%.slow.gcc.s: %.c
	@$(SAY) "AS   '$^' --> '$@'"
	@$(CC)  $(CFLAGS)   -S "$^" -o "$@"

%.slow.gxx.s: %.cpp
	@$(SAY) "AS   '$^' --> '$@'"
	@$(CXX) $(CXXFLAGS) -S "$^" -o "$@"

%.fast.gcc.s: %.c
	@$(SAY) "AS   '$^' --> '$@'"
	@$(CC)  $(CFLAGS)   -S "$^" -o "$@" $(FAST_MATH)

%.fast.gxx.s: %.cpp
	@$(SAY) "AS   '$^' --> '$@'"
	@$(CXX) $(CXXFLAGS) -S "$^" -o "$@" $(FAST_MATH)

### Objects with/without FAST_MATH

%.slow.gcc.o: %.c
	@$(SAY) "CC   '$^' --> '$@'"
	@$(CC)  $(CFLAGS)   -c "$^" -o "$@"

%.slow.gxx.o: %.cpp
	@$(SAY) "CXX  '$^' --> '$@'"
	@$(CXX) $(CXXFLAGS) -c "$^" -o "$@"

%.fast.gcc.o: %.c
	@$(SAY) "CC   '$^' --> '$@'"
	@$(CC)  $(CFLAGS)   -c "$^" -o "$@" $(FAST_MATH)

%.fast.gxx.o: %.cpp
	@$(SAY) "CXX  '$^' --> '$@'"
	@$(CXX) $(CXXFLAGS) -c "$^" -o "$@" $(FAST_MATH)

### Executables with/without FAST_MATH

%.slow.gcc: %.slow.gcc.o
	@$(SAY) "LINK '$^' --> '$@'"
	@$(CC)  $(CFLAGS)   "$^" -o "$@"

%.slow.gxx: %.slow.gxx.o
	@$(SAY) "LINK '$^' --> '$@'"
	@$(CXX) $(CXXFLAGS) "$^" -o "$@"

%.fast.gcc: %.fast.gcc.o
	@$(SAY) "LINK '$^' --> '$@'"
	@$(CC)  $(CFLAGS)   "$^" -o "$@" $(FAST_MATH)

%.fast.gxx: %.fast.gxx.o
	@$(SAY) "LINK '$^' --> '$@'"
	@$(CXX) $(CXXFLAGS) "$^" -o "$@" $(FAST_MATH)
