AppCore
===================

AppCore is a layer built on top of [ResearchKit](https://github.com/researchkit/ResearchKit) which forms the core of
the five initial ResearchKit apps.

It includes some of the key features of those initial ResearchKit apps,
including:

* Dashboard with progress graphs
* Data storage back end
* JSON serialization and deserialization
* Integration with Sage Bionetworks' Bridge service

Over time, we expect that some of the features in AppCore will be
migrated into ResearchKit.

Building AppCore
----------------

AppCore does not build stand-alone, but rather is built as part of other
projects. To build it, go to one of the projects that uses it, such as
[Share the Journey](https://github.com/ResearchKit/ShareTheJourney).

OpenSSL
-------

This version of AppCore differs from the version in the shipping apps
because it does not include OpenSSL, which is used in the shipping apps
for Cryptographic Message Syntax (CMS) encryption support.

CMS is used by the apps in order to protect sensitive data stored
temporarily on the phone, and while in transit. It helps reduce
requirements on back-ends, so that HTTPS endpoints can safely be
terminated earlier than the final hop, because data encryption and
decryption occurs at the application layer.

To re-enable OpenSSL, build OpenSSL as an iOS static library, add it
to the AppCore library target, and then switch the CMS code to use
OpenSSL by removing `APCCMS_NoEncryption_JustAStub.m` from the target
and adding `APCCMS_UsingOpenSSL.m` instead.


License
=======

The source in the AppCore repository is made available under the
following license unless another license is explicitly identified:

```
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
