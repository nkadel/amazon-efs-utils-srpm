amazon-efs-utils-srpm
==========-==========

Wrapper for SRPM building tools for amazon-efs-utils .

Uses git repo from:

* https://github.com/aws/efs-utils/

Modified .spec file from:

https://github.com/aws/efs-utils/blob/master/amazon-efs-utils.spec

Building RPMs
=============

Ideally, install "mock" and use that to build for both RHEL 7 through
9 and Fedora 37. Run these commands at the top directory.

* make getsrc # Get source tarvalls for all SRPMs

* make cfgs # Create local .cfg configs for "mock".
* * centos+epel-7-x86_64.cfg # Used for some Makefiles
* * centos-stream+epel-8-x86_64.cfg # Used for some Makefiles
* * centos-stream+epel-9-x86_64.cfg # Used for some Makefiles
* * centos-stream+epel-9-x86_64.cfg # Used for some Makefiles
* * centos-stream+fedora-37-x86_64.cfg # Used for some Makefiles

* make repos # Creates local local yum repositories in $PWD/ansiblerepo
* * repo/el/7
* * repo/el/8
* * repo/el/8
* * repo/fedora/37

* make # Make all distinct versions using "mock"

Building locally
----------------

* make build

Nico Kadel-Garcia <nkadel@gmail.com>
