.SUFFIXES:
.SUFFIXES: .gem .o .cc .hh .rb .tar .gz .bz2

RUBY_VERSION = 1.8
MULTIARRAY_VERSION = 0.2.2

CP = cp
RM = rm -Rf
MKDIR = mkdir -p
GEM = gem$(RUBY_VERSION)
RUBY = ruby$(RUBY_VERSION)
YARDOC = yardoc
RI = ri$(RUBY_VERSION)
TAR = tar
GIT = git
SITELIBDIR = $(shell $(RUBY) -r mkmf -e "puts \"\#{Config::CONFIG['sitelibdir']}\"")

MAIN = Makefile source.gemspec README COPYING .document
LIB = $(wildcard lib/*.rb)
PKG_LIB = $(wildcard lib/multiarray/*.rb)
TEST = $(wildcard test/*.rb)
DOC = $(wildcard doc/*.rb)
SOURCES = $(MAIN) $(LIB) $(PKG_LIB) $(TEST) $(DOC)

all:: target

target::

gem:: multiarray-$(MULTIARRAY_VERSION).gem

install:: $(LIB) $(PKG_LIB)
	$(MKDIR) $(SITELIBDIR)
	$(MKDIR) $(SITELIBDIR)/multiarray
	$(CP) $(LIB) $(SITELIBDIR)
	$(CP) $(PKG_LIB) $(SITELIBDIR)/multiarray

uninstall::
	$(RM) $(addprefix $(SITELIBDIR)/,$(notdir $(LIB))) $(addprefix $(SITELIBDIR)/multiarray/,$(notdir $(PKG_LIB)))

install-gem:: multiarray-$(MULTIARRAY_VERSION).gem
	$(GEM) install --local $<

uninstall-gem::
	$(GEM) uninstall multiarray || echo Nothing to uninstall

yardoc:: README $(LIB)
	$(YARDOC)

check:: $(LIB) $(PKG_LIB) $(TEST)
	$(RUBY) -rrubygems -Ilib -Itest test/ts_multiarray.rb

push-gem:: multiarray-$(MULTIARRAY_VERSION).gem
	echo Pushing $< in 3 seconds!
	sleep 3
	$(GEM) push $<

push-git::
	echo Pushing to origin in 3 seconds!
	sleep 3
	$(GIT) push origin master

dist:: dist-gzip

dist-gzip:: multiarray-$(MULTIARRAY_VERSION).tar.gz

dist-bzip2:: multiarray-$(MULTIARRAY_VERSION).tar.bz2

multiarray-$(MULTIARRAY_VERSION).gem: $(SOURCES)
	$(GEM) build source.gemspec

multiarray-$(MULTIARRAY_VERSION).tar.gz: $(SOURCES)
	$(TAR) czf $@ $(SOURCES)

multiarray-$(MULTIARRAY_VERSION).tar.bz2: $(SOURCES)
	$(TAR) cjf $@ $(SOURCES)

clean::
	$(RM) *~ lib/*~ lib/multiarray/*~ test/*~ *.gem doc
