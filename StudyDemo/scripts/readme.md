Overview
========================================

In addition to its survey, active task, and consent components,
ResearchKit provides tools for formatting and uploading research data
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

Uploads can be formatted using `RKDataArchive` in several different
ways, but the preferred format is `RKDataArchiveFormatZip`. In this
format, each upload may consist of one or more files, all zipped
together. In addition, the metadata will be written to a file called
"info.json" which is also included in the zip.

The common zip and metadata structure, together with the
human-readable JSON serialization formats for recorded data, should
facilitate the development of open source processing tools.


Encryption
----------------------------------------

We recommend using TLS / HTTPS for transport. This can be accomplished
with `RKUploader` by using an https endpoint.

Data collected using ResearchKit will often be highly personal
information which needs to be handled with care. The basic standard is
that so long as such data remains personally identifiable, it ought to
be "encrypted at rest". `RKUploader` provides facilities to make it easy
to send research data to a server while ensuring it is always encrypted at
rest.

`RKUploader` uses `NSURLSession` to implement background uploads, so
that if there is no network connectivity when the upload is made, the
upload can be executed in the background when connectivity is
restored. However, for this to work, the files to be uploaded must be
stored on the filesystem of the iOS device, and at best can be
encrypted with `NSFileProtectionCompleteUntilFirstUnlock`, which is
not particularly secure. For this reason, `RKUploader` provides
support for encrypting each zip package using Cryptographic Message
Syntax (CMS; see RFC 5083), the same technology used for secure
email. This feature is enabled by providing an X.509 PEM certificate
when creating an `RKUploader`. This public key encryption technology
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


Transport
----------------------------------------

Three headers are included with each uploaded message. This can aid in
routing messages for storage, without needing to decrypt the data on
receipt. This could be useful, for instance, in a server architecture
where the web front end does not have access to the private key, and
merely forwards each received package on to a private server.

These headers are:

* X-ResearchKit-UploadUUID - a unique identifier for this upload. Use
  this to uniquely identify uploaded messages, in case the same
  message should be received twice.

* X-ResearchKit-SubjectUUID - a unique identifier for the
  participant. Use this to keep data related to the same subject
  together. This subject UUID is specific to the study, so each
  participant will have a different subject UUID for each study in
  which they participate.

* X-ResearchKit-StudyIdentifier - identifier for the study.


Package size limits
----------------------------------------

All data for a message is held in memory on the device while
performing serialization, packaging using `RKDataArchiver`, and
encryption. As such, each individual upload should not be too
large. At this stage we have not tested maximum package size, but an
uncompressed size < 1 MB should be ok.

This is fine for survey results, accelerometer data, and even sound,
but may prove limiting for high resolution imagery.



Practical instructions
========================================

Generating a new researcher private key and certificate
----------------------------------------

Use the cert_gen.sh script. This requires openssl in your path.

This will generate three useful files:

    - rsaprivkey.pem - your private key in PEM format
    - rsapubkey.pem - your public key in PEM format
    - rsacert.pem - your certificate in PEM format

The certificate must be included and "investigator.pem" in your study
bundle. Retain these original files in order to permit decrypting
the data uploaded with CMS.


Decrypting data
----------------------------------------

To decrypt zipped data using studyResults.py you need:

   - a Python installation, >= 2.5 and < 3.0
   - your investigator private key in PEM format
   - your investigator certificate in PEM format
   - a version of openssl that supports CMS

On the Mac, we recommend installing a current openssl with brew:

"""
brew install openssl
"""

(this will install a new openssl under /usr/local/Cellar/openssl/...)

You can pass the exact path to the correct openssl binary in the
--openssl argument to studyResults.py if performing a manual decrypt.


Test server
----------------------------------------

A demonstration server, "study_server.py", is provided as a proof of
concept. This is a WSGI simple_server, which provides an endpoint
/api/upload. If an app's RKUploader is pointed at this endpoint, the
server will decode uploaded data and print it to the console.

The script run_server.sh shows how to start the study_server in the
default configuration, suitable for testing against the iOS simulator
on the local machine. It assumes that openssl has been installed using
brew.


Use of studyResults script
----------------------------------------

"""
$ python studyResults.py --help
usage: studyResults.py [-h] [-k KEY] [-i IDENTITY] [-o OUT] [--openssl OPENSSL] [-v]
                       zipOrDir

positional arguments:
  zipOrDir              path to downloaded zip file, or to unzipped directory containing
                        encrypted data

optional arguments:
  -h, --help            show this help message and exit
  -k KEY, --key KEY     researcher private key PEM file
  -i IDENTITY, --identity IDENTITY
                        researcher certificate as PEM file
  -o OUT, --out OUT     directory in which to place output
  --openssl OPENSSL     path to OpenSSL binary to use
  -v, --verbose         describe files being decrypted
"""

    - Use the openssl argument to specify openssl if it is not on your path
    - The -k and -i arguments are mandatory to specify your keys
    - The -o argument is not required; by default the output files are written to the working directory
    - The path passed as the primary argument can be the downloaded zip file

For example:

$ python studyResults.py -k rsaprivkey.pem -i rsacert.pem -o ./resultsDir ~/Downloads/Study1Download3Part0.zip



[1] https://github.com/fge/json-schema-validator

[2] http://json-schema-validator.herokuapp.com