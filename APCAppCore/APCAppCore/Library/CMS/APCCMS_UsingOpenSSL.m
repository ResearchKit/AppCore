// 
//  APCCMS_UsingOpenSSL.m
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCCMS.h"
#import <openssl/pem.h>
#import <openssl/cms.h>
#import <openssl/err.h>


/**
 Remember, only include ONE of these encryption .m files
 in your project.  See ENCRYPTION_README.txt for more
 information.
 */
NSData * cmsEncrypt(NSData *data, NSString *identityPath, NSError * __autoreleasing *error) {
    BIO *in = NULL, *out = NULL, *tbio = NULL;
    X509 *rcert = NULL;
    STACK_OF(X509) *recips = NULL;
    CMS_ContentInfo *cms = NULL;
    BIO *chain = NULL;
    NSData *returnValue = nil;
    int ret = 1;
    
    /*
     * On OpenSSL 1.0.0 and later only:
     * for streaming set CMS_STREAM
     */
    int flags = CMS_STREAM | CMS_BINARY;
    
    OpenSSL_add_all_algorithms();
    ERR_load_crypto_strings();
    
    /* Read in recipient certificate */
    tbio = BIO_new_file([identityPath UTF8String], "r");
    
    if (!tbio)
        goto err;
    
    rcert = PEM_read_bio_X509(tbio, NULL, 0, NULL);
    
    if (!rcert)
        goto err;
    
    /* Create recipient STACK and add recipient cert to it */
    recips = sk_X509_new_null();
    
    if (!recips || !sk_X509_push(recips, rcert))
        goto err;
    
    /* sk_X509_pop_free will free up recipient STACK and its contents
     * so set rcert to NULL so it isn't freed up twice.
     */
    rcert = NULL;
    
    /* Open content being encrypted */
    
    in = BIO_new_mem_buf((void *)[data bytes], (int)[data length]);
    
    if (!in)
        goto err;
    
    
    /* encrypt content */
    cms = CMS_encrypt(recips, in, EVP_aes_128_cbc(), flags);
    
    if (!cms)
        goto err;
    
    out = BIO_new(BIO_s_mem());
    if (!out)
        goto err;
    
    // Stream the encrypted data into the buffer as DER
    if (!i2d_CMS_bio_stream(out, cms, in, flags))
        goto err;
    
    // Success
    ret = 0;
    
    // Convert the data
    BUF_MEM *bptr = NULL;
    BIO_get_mem_ptr(out, &bptr);
    returnValue = [NSData dataWithBytes:bptr->data length:bptr->length];
    
err:
    
    if (ret)
    {
        if (error) {
            *error = [NSError errorWithDomain:@"openssl" code:ret userInfo:nil];
        }
        fprintf(stderr, "Error Encrypting Data\n");
        ERR_print_errors_fp(stderr);
    }
    
    if (cms)
        CMS_ContentInfo_free(cms);
    if (rcert)
        X509_free(rcert);
    if (recips)
        sk_X509_pop_free(recips, X509_free);
    
    if (in)
        BIO_free(in);
    if (out)
        BIO_free(out);
    if (chain)
        BIO_free(chain);
    if (tbio)
        BIO_free(tbio);
    
    return returnValue;
}
