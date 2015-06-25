-------------------------------
Setting up Encryption
-------------------------------

The APCCMSSupport.h header file defines an interface for an APCCMSSupport class.

By default, no implementation of this class is included in APCAppCore. If you provide an implementation and link it
into the same executable binary with APCAppCore, the cmsEncrypt() function in APCCMS.m will find it and call its
cmsEncrypt:identityPath:error: class method to encrypt data before it is sent to the back-end storage server, or before
being saved on device to be sent on later.

If you provide no implementation of this class, the default behavior of the cmsEncrypt() function is to log a warning
to the console and return the data unchanged.