//
//  NSData+SHA256.h
//  
//
//  Created by Anton Spivak on 09.07.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (SHA256)

- (NSData *)sha256;

@end

NS_ASSUME_NONNULL_END
