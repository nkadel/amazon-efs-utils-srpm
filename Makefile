#
# Build mock and local RPM versions of tools for ansible
#

# Assure that sorting is case sensitive
LANG=C

MOCKS+=centos+epel-7-x86_64
MOCKS+=centos-stream+epel-8-x86_64
MOCKS+=centos-stream+epel-9-x86_64
MOCKS+=fedora-37-x86_64

REPOS+=repo/el/7
REPOS+=repo/el/8
REPOS+=repo/el/9
REPOS+=repo/fedora/37
REPOS+=repo/amazon/2

REPODIRS := $(patsubst %,%/x86_64/repodata,$(REPOS)) $(patsubst %,%/SRPMS/repodata,$(REPOS))

REPODIRS := $(patsubst %,%/x86_64/,$(REPOS)) $(patsubst %,%/SRPMS/,$(REPOS))

REPOBASEDIR:=`/bin/pwd`/./repo

SPEC := `ls *.spec`

all:: $(MOCKS)

repodirs: $(REPOS) $(REPODIRS)
repos: $(REPOS) $(REPODIRS)
$(REPOS):
	install -d -m 755 $@

.PHONY: $(REPODIRS)
$(REPODIRS): $(REPOS)
	@install -d -m 755 `dirname $@`
	/usr/bin/createrepo_c -q `dirname $@`

.PHONY: getsrc
getsrc::
	spectool -g $(SPEC)

srpm:: src.rpm

#.PHONY:: src.rpm
src.rpm:: Makefile
	@rm -rf rpmbuild
	@rm -f $@
	@echo "Building SRPM with $(SPEC)"
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--define '_sourcedir $(PWD)' \
		-bs $(SPEC) --nodeps
	mv rpmbuild/SRPMS/*.src.rpm src.rpm

.PHONY: build
build:: src.rpm
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--rebuild $?

.PHONY: $(MOCKS)
$(MOCKS)::
	@if [ -e $@ -a -n "`find $@ -name '*.rpm' ! -name '*.src.rpm' 2>/dev/null`" ]; then \
		echo "	Skipping RPM populated $@"; \
	else \
		echo "Building $(SPEC) in $@"; \
		rm -rf $@; \
		mock -q -r /etc/mock/$@.cfg \
		    --sources $(PWD) --spec $(SPEC) \
		    --resultdir=$(PWD)/$@; \
	fi

mock:: $(MOCKS)

install:: $(MOCKS)
	@for repo in $(MOCKS); do \
	    echo Installing $$repo; \
	    case $$repo in \
		amazonlinux-2-x86_64) yumrelease=amazon/2; yumarch=x86_64; ;; \
		*-amz2-x86_64) yumrelease=amazon/2; yumarch=x86_64; ;; \
		*-7-x86_64) yumrelease=el/7; yumarch=x86_64; ;; \
		*-8-x86_64) yumrelease=el/8; yumarch=x86_64; ;; \
		*-9-x86_64) yumrelease=el/9; yumarch=x86_64; ;; \
		*-37-x86_64) yumrelease=fedora/37; yumarch=x86_64; ;; \
		*-f37-x86_64) yumrelease=fedora/37; yumarch=x86_64; ;; \
		*-rawhide-x86_64) yumrelease=fedora/rawhide; yumarch=x86_64; ;; \
		*) echo "Unrecognized release for $$repo, exiting" >&2; exit 1; ;; \
	    esac; \
	    rpmdir=$(REPOBASEDIR)/$$yumrelease/$$yumarch; \
	    srpmdir=$(REPOBASEDIR)/$$yumrelease/SRPMS; \
	    echo "Pushing SRPMS to $$srpmdir"; \
	    rsync -av $$repo/*.src.rpm --no-owner --no-group $$repo/*.src.rpm $$srpmdir/. || exit 1; \
	    createrepo_c -q $$srpmdir/.; \
	    echo "Pushing RPMS to $$rpmdir"; \
	    rsync -av $$repo/*.rpm --exclude=*.src.rpm --exclude=*debuginfo*.rpm --no-owner --no-group $$repo/*.rpm $$rpmdir/. || exit 1; \
	    createrepo_c -q $$rpmdir/.; \
	done

clean::
	rm -rf */
	rm -f *.out
	rm -f *.rpm

realclean distclean:: clean
