//
//  NSData+SHA256.m
//  
//
//  Created by Anton Spivak on 09.07.2022.
//

#import "NSData+SHA256.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (SHA256)

- (NSData *)sha256 {
    NSMutableData *sha256 = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([self bytes], (CC_LONG)[self length], [sha256 mutableBytes]);
    return sha256;
}

@end
