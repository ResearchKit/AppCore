-------------------------------
Setting up Encryption
-------------------------------

(Placeholder.  This ReadMe presumes some knowledge of how
this project uses encryption.  We're still evolving this.)


How to use these files:
- Pick the encryption .m file you want to use, or make your own (examples below)
- Add only ONE of those files to the AppCore target.
- Add any libraries you need for your file to work.


This project ships with two examples:
1.  A stub, which doesn't encrypt anything; it merely returns what you pass it
2.  An OpenSSL wrapper, which encrypts the specified data using OpenSSL


The project is configured to use #2, OpenSSL.  You can see how as follows:
3.  In the Project Explorer (at left), select the file APCCMS_UsingOpenSSL.m.  In the File Inspector (at right), you'll see that that file has a checkmark next to "APCAppCore".
4.  In the Project Explorer, select the file "APCCMS_NoEncryption.m". In the File Inspector, you'll see that that file does NOT have a checkmark next to "APCAppCore."
5.  In the Project Explorer, select the file "APCAppCore.xcodeproj".  You will see the editor window for the project file itself.  Click the "Build Phases" tab, and then expand the "Link Binary With Libraries" item.  You will see the library "openssl.framework" in the list.


To change the project to use the "no encryption" version:
-  Swap the checkmarks for files #3 and #4, above.
-  You may also remove the OpenSSL framework from disk, and remove it from the project using the project editor (#5, above).
