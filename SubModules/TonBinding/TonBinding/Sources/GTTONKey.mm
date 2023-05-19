//
//  GTTONKey.m
//  
//
//  Created by Anton Spivak on 01.02.2022.
//

#import "GTTONKey.h"

#import <openssl/evp.h>
#import <openssl/pem.h>
#import <openssl/x509.h>

#import <td/utils/Slice.h>
#import <td/utils/SharedSlice.h>

@implementation GTTONKey

- (instancetype)initWithPublicKey:(NSString *)publicKey
               encryptedSecretKey:(NSData *)encryptedSecretKey
{
    self = [super init];
    if (self != nil) {
        _publicKey = [publicKey copy];
        _encryptedSecretKey = [encryptedSecretKey copy];
    }
    return self;
}

+ (NSData * _Nullable)createSignatureWithData:(NSData *)data privateKey:(NSData *)key {
    EVP_PKEY *pkey = EVP_PKEY_new_raw_private_key(EVP_PKEY_ED25519, NULL, (unsigned char *)key.bytes , key.length);
    if (pkey == NULL) {
        // Can't import private key
        return nil;
    }
    
    EVP_MD_CTX *md_ctx = EVP_MD_CTX_new();
    if (md_ctx == NULL) {
        EVP_PKEY_free(pkey);
        
        // Can't create EVP_MD_CTX
        return nil;
    }
    
    if (EVP_DigestSignInit(md_ctx, NULL, NULL, NULL, pkey) <= 0) {
        EVP_PKEY_free(pkey);
        EVP_MD_CTX_free(md_ctx);
        
        // Can't init DigestSign
        return nil;
    }
    
    td::SecureString res(64, '\0');
    size_t len = 64;
    if (EVP_DigestSign(md_ctx, res.as_mutable_slice().ubegin(), &len, (unsigned char *)data.bytes, data.length) <= 0) {
        EVP_PKEY_free(pkey);
        EVP_MD_CTX_free(md_ctx);
        
        // Can't sign data
        return nil;
    }
    
    EVP_PKEY_free(pkey);
    EVP_MD_CTX_free(md_ctx);
    
    return [[NSData alloc] initWithBytes:res.data() length:res.size()];
}

@end
