Overview
========================================

In addition to its survey, active task, and consent components,
ResearchKit provides tools for formatting research data for upload
in a consistent and secure manner.


Preparing task content
----------------------------------------

Tasks (including surveys and active tasks) have significant textual
content and may also be localized. To ease producing this content
outside the development environment, `RKTask` instances can be
deserialized from JSON.

A JSON schema which can provide an approximate validation of manually
created JSON is included (task_schema.json). If additional custom
tasks or steps are added, the schema may need to be modified.

To use the JSON schema for validation, see [1] or [2].



Data packaging
----------------------------------------

Data collected from surveys and from certain active tasks can be
serialized to JSON using ResearchKit. Each item collected is
identified by several fields, which together are called "metadata".

* a study identifier (a string, e.g. edu.yourinsitution.research_study)

* an item identifier (e.g., task_001.step_001 for a step in a task, or
  com.apple.healthkit.HKDataTypeIdentifier for a passive data
  collection item).

* for surveys and active tasks, a task instance identifier (a UUID
  generated when the task is started) - so that multiple steps from a
  given task can be collated later

* a timestamp identifying when the upload was requested.

Uploads can be formatted in zip format using `RKDataArchive`. In this
format, each upload may consist of one or more files, all zipped
together. In addition, the metadata will be written to a file called
"info.json" which is also included in the zip.

The common zip and metadata structure, together with the
human-readable JSON serialization formats for recorded data, should
facilitate the development of open source processing tools.


Encryption
----------------------------------------

We recommend using TLS / HTTPS for transport.

Data collected using ResearchKit will often be highly personal
information which needs to be handled with care. The basic standard is
that so long as such data remains personally identifiable, it ought to
be "encrypted at rest".

`NSURLSession` may be used to implement background uploads, so
that if there is no network connectivity when the upload is made, the
upload can be executed in the background when connectivity is
restored. However, for this to work, the files to be uploaded must be
stored on the filesystem of the iOS device, and at best can be
encrypted with `NSFileProtectionCompleteUntilFirstUnlock`, which is
not particularly secure. For this reason, `RKDataArchive` provides
support for encrypting each zip package using Cryptographic Message
Syntax (CMS; see RFC 5083), the same technology used for secure
email. This feature is enabled by providing an X.509 PEM certificate
when uploading an `RKDataArchive`. This public key encryption technology
allows each piece of collected data to be encrypted at rest while
queued for upload.

The StudyDemo package includes a demo certificate. Before using this
feature in production, a new private key and certificate should be
generated and the generated certificate should be included in the iOS
project. See "Generating a new researcher private key and
certificate", below.

We recommend use of the CMS support to keep data encrypted at rest,
but certain studies which do not handle particularly sensitive data
may choose to forego use of CMS. If so, they should still use HTTPS /
TLS.


Package size limits
----------------------------------------

All data for a message is held in memory on the device while
performing CMS encryption. Therefore, if using CMS encryption,
each individual upload should not be too
large. At this stage we have not tested maximum package size, but an
uncompressed size < 1 MB should be ok.

This is fine for survey results, accelerometer data, and even sound,
but may prove limiting for high resolution imagery.




[1] https://github.com/fge/json-schema-validator

[2] http://json-schema-validator.herokuapp.com
