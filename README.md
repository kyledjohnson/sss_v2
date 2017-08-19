SeventeenSeventySix 1.0.11
=============

What is SeventeenSeventySix?
--------------

[SeventeenSeventySix](https://z.cash/) is an implementation of the "Zerocash" protocol.
Based on Bitcoin's code, it intends to offer a far higher standard of privacy
through a sophisticated zero-knowledge proving scheme that preserves
confidentiality of transaction metadata. Technical details are available
in our [Protocol Specification](https://github.com/seventeenseventysix/zips/raw/master/protocol/protocol.pdf).

This software is the SeventeenSeventySix client. It downloads and stores the entire history
of SeventeenSeventySix transactions; depending on the speed of your computer and network
connection, the synchronization process could take a day or more once the
blockchain has reached a significant size.

Security Warnings
-----------------

See important security warnings in
[doc/security-warnings.md](doc/security-warnings.md).

**SeventeenSeventySix is experimental and a work-in-progress.** Use at your own risk.

Deprecation Policy
------------------

This release is considered deprecated 16 weeks after the release day. There
is an automatic deprecation shutdown feature which will halt the node some
time after this 16 week time period. The automatic feature is based on block
height and can be explicitly disabled.

Where do I begin?
-----------------
We have a guide for joining the main SeventeenSeventySix network:
https://github.com/seventeenseventysix/seventeenseventysix/wiki/1.0-User-Guide

### Need Help?

* See the documentation at the [SeventeenSeventySix Wiki](https://github.com/seventeenseventysix/seventeenseventysix/wiki)
  for help and more information.
* Ask for help on the [SeventeenSeventySix](https://forum.z.cash/) forum.

Participation in the SeventeenSeventySix project is subject to a
[Code of Conduct](code_of_conduct.md).

Building
--------

Build SeventeenSeventySix along with most dependencies from source by running
./zcutil/build.sh. Currently only Linux is officially supported.

License
-------

For license information see the file [COPYING](COPYING).
