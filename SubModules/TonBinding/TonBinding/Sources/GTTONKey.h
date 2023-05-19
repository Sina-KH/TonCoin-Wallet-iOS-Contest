//
//  GTTONKey.h
//  
//
//  Created by Anton Spivak on 01.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTTONKey : NSObject

@property (nonatomic, strong, readonly) NSString *publicKey;
@property (nonatomic, strong, readonly) NSData *encryptedSecretKey;

- (instancetype)initWithPublicKey:(NSString *)publicKey
               encryptedSecretKey:(NSData *)encryptedSecretKey;

+ (NSData * _Nullable)createSignatureWithData:(NSData *)data privateKey:(NSData *)key;

@end

NS_ASSUME_NONNULL_END
