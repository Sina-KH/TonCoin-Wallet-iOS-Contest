#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>
#import "GTTONKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface TONError : NSObject

@property (nonatomic, strong, readonly) NSString *text;

@end

@interface TONKey : NSObject

@property (nonatomic, strong, readonly) NSString *publicKey;
@property (nonatomic, strong, readonly) NSData *secret;

- (instancetype)initWithPublicKey:(NSString *)publicKey secret:(NSData *)secret;

@end

@interface TONTransactionId : NSObject

@property (nonatomic, readonly) int64_t lt;
@property (nonatomic, strong, readonly) NSData * _Nonnull transactionHash;

- (instancetype)initWithLt:(int64_t)lt transactionHash:(NSData * _Nonnull)transactionHash;

@end

@interface TONAccountState : NSObject

@property (nonatomic, readonly) bool isInitialized;
@property (nonatomic, readonly) bool isRWallet;
@property (nonatomic, readonly) int64_t balance;
@property (nonatomic, readonly) int64_t unlockedBalance;

@property (nonatomic, readonly) int32_t seqno;
@property (nonatomic, strong, readonly) TONTransactionId * _Nullable lastTransactionId;
@property (nonatomic, readonly) int64_t syncUtime;

- (instancetype)initWithIsInitialized:(bool)isInitialized isRWallet:(bool)isRWallet balance:(int64_t)balance unlockedBalance:(int64_t)unlockedBalance seqno:(int32_t)seqno lastTransactionId:(TONTransactionId * _Nullable)lastTransactionId syncUtime:(int64_t)syncUtime;

@end

@protocol TONTransactionMessageContents <NSObject>

@end

@interface TONTransactionMessageContentsRawData : NSObject <TONTransactionMessageContents>

@property (nonatomic, strong, readonly) NSData * _Nonnull data;

- (instancetype)initWithData:(NSData * _Nonnull)data;

@end

@interface TONTransactionMessageContentsPlainText : NSObject <TONTransactionMessageContents>

@property (nonatomic, strong, readonly) NSString * _Nonnull text;

- (instancetype)initWithText:(NSString * _Nonnull)text;

@end

@interface TONEncryptedData : NSObject

@property (nonatomic, strong, readonly) NSString * _Nonnull sourceAddress;
@property (nonatomic, strong, readonly) NSData * _Nonnull data;

- (instancetype)initWithSourceAddress:(NSString * _Nonnull)sourceAddress data:(NSData * _Nonnull)data;

@end

@interface TONTransactionMessageContentsEncryptedText : NSObject <TONTransactionMessageContents>

@property (nonatomic, strong, readonly) TONEncryptedData * _Nonnull encryptedData;

- (instancetype)initWithEncryptedData:(TONEncryptedData * _Nonnull)encryptedData;

@end

@interface TONTransactionMessage : NSObject

@property (nonatomic, readonly) int64_t value;
@property (nonatomic, strong, readonly) NSString * _Nonnull source;
@property (nonatomic, strong, readonly) NSString * _Nonnull destination;
@property (nonatomic, strong, readonly) id<TONTransactionMessageContents> _Nonnull contents;
@property (nonatomic, strong, readonly) NSData * _Nonnull bodyHash;

- (instancetype)initWithValue:(int64_t)value source:(NSString * _Nonnull)source destination:(NSString * _Nonnull)destination contents:(id<TONTransactionMessageContents> _Nonnull)contents bodyHash:(NSData * _Nonnull)bodyHash;

@end

@interface TONTransaction : NSObject

@property (nonatomic, strong, readonly) NSData * _Nonnull data;
@property (nonatomic, strong, readonly) TONTransactionId * _Nonnull transactionId;
@property (nonatomic, readonly) int64_t timestamp;
@property (nonatomic, readonly) int64_t storageFee;
@property (nonatomic, readonly) int64_t otherFee;
@property (nonatomic, strong, readonly) TONTransactionMessage * _Nullable inMessage;
@property (nonatomic, strong, readonly) NSArray<TONTransactionMessage *> * _Nonnull outMessages;
@property (nonatomic, readonly) bool isInitialization;

- (instancetype)initWithData:(NSData * _Nonnull)data transactionId:(TONTransactionId * _Nonnull)transactionId timestamp:(int64_t)timestamp storageFee:(int64_t)storageFee otherFee:(int64_t)otherFee inMessage:(TONTransactionMessage * _Nullable)inMessage outMessages:(NSArray<TONTransactionMessage *> * _Nonnull)outMessages isInitialization:(bool)isInitialization;

@end

@interface TONExternalRequest : NSObject

@property (nonatomic, strong, readonly) NSData * _Nonnull data;
@property (nonatomic, copy, readonly) void (^onResult)(NSData * _Nullable, NSString * _Nullable);

- (instancetype)initWithData:(NSData * _Nonnull)data onResult:(void (^)(NSData * _Nullable, NSString * _Nullable))onResult;

@end

@interface TONFees : NSObject

@property (nonatomic, readonly) int64_t inFwdFee;
@property (nonatomic, readonly) int64_t storageFee;
@property (nonatomic, readonly) int64_t gasFee;
@property (nonatomic, readonly) int64_t fwdFee;

- (instancetype)initWithInFwdFee:(int64_t)inFwdFee storageFee:(int64_t)storageFee gasFee:(int64_t)gasFee fwdFee:(int64_t)fwdFee;

@end

@interface TONSendGramsQueryFees : NSObject

@property (nonatomic, strong, readonly) TONFees * _Nonnull sourceFees;
@property (nonatomic, strong, readonly) NSArray<TONFees *> * _Nonnull destinationFees;

- (instancetype)initWithSourceFees:(TONFees * _Nonnull)sourceFees destinationFees:(NSArray<TONFees *> * _Nonnull)destinationFees;

@end

@interface TONPreparedSendGramsQuery : NSObject

@property (nonatomic, readonly) int64_t queryId;
@property (nonatomic, readonly) int64_t validUntil;
@property (nonatomic, strong, readonly) NSData * _Nonnull bodyHash;
@property (nonatomic, strong, readonly) NSData * _Nonnull bocData;

- (instancetype)initWithQueryId:(int64_t)queryId validUntil:(int64_t)validUntil bodyHash:(NSData *)bodyHash bocData:(NSData *)bocData;

@end

@interface TONSendGramsResult : NSObject

@property (nonatomic, readonly) int64_t sentUntil;
@property (nonatomic, strong, readonly) NSData * _Nonnull bodyHash;

- (instancetype)initWithSentUntil:(int64_t)sentUntil bodyHash:(NSData *)bodyHash;

@end

@interface TONValidatedConfig : NSObject

@property (nonatomic, readonly) int64_t defaultWalletId;

- (instancetype)initWithDefaultWalletId:(int64_t)defaultWalletId;

@end


#pragma mark - TONDNSEntry

@protocol TONDNSEntry <NSObject>
@end

#pragma mark - TONDNSEntryText

@interface TONDNSEntryText : NSObject <TONDNSEntry>

@property (nonatomic, strong, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end

#pragma mark - TONDNSEntrySMCAddress

@interface TONDNSEntrySMCAddress : NSObject <TONDNSEntry>

@property (nonatomic, strong, readonly) NSString *address;

- (instancetype)initWithAddress:(NSString *)address;

@end

#pragma mark - TONDNSEntryNextResolver

@interface TONDNSEntryNextResolver : NSObject <TONDNSEntry>

@property (nonatomic, strong, readonly) NSString *address;

- (instancetype)initWithAddress:(NSString *)address;

@end

#pragma mark - TONDNS

@interface TONDNS : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSArray<TONDNSEntry> *entries;

- (instancetype)initWithName:(NSString *)name
                     entries:(NSArray<TONDNSEntry> *)entries;

@end

#pragma mark - TONLocalID

@interface TONLocalID : NSObject

@property (nonatomic, readonly) int64_t localID;

- (instancetype)initWithID:(int64_t)localID;

@end

@protocol TONExecutionStackValue <NSObject>
@end

@interface TONExecutionResult : NSObject

@property (nonatomic, assign) int32_t code;
@property (nonatomic, copy) NSArray<TONExecutionStackValue> *stack;

- (instancetype)initWithCode:(int32_t)code
                       stack:(NSArray<TONExecutionStackValue> *)stack;

@end

#pragma mark - TONExecutionResultDecimal

@interface TONExecutionResultDecimal : NSObject <TONExecutionStackValue>

@property (nonatomic, copy) NSString *value;

- (instancetype)initWithValue:(NSString *)value;

@end

#pragma mark - TONExecutionResultSlice

@interface TONExecutionResultSlice : NSObject <TONExecutionStackValue>

@property (nonatomic, copy) NSData *hex;

- (instancetype)initWithHEX:(NSData *)hex;

@end

#pragma mark - TONExecutionResultCell

@interface TONExecutionResultCell : NSObject <TONExecutionStackValue>

@property (nonatomic, copy) NSData *hex;

- (instancetype)initWithHEX:(NSData *)hex;

@end

#pragma mark - TONExecutionResultEnumeration

@interface TONExecutionResultEnumeration : NSObject <TONExecutionStackValue>

@property (nonatomic, copy) NSArray<TONExecutionStackValue> *enumeration;

- (instancetype)initWithEnumeration:(NSArray<TONExecutionStackValue> *)enumeration;

@end

@interface TON : NSObject

- (instancetype)initWithKeystoreDirectory:(NSString *)keystoreDirectory config:(NSString *)config blockchainName:(NSString *)blockchainName performExternalRequest:(void (^)(TONExternalRequest * _Nonnull))performExternalRequest enableExternalRequests:(bool)enableExternalRequests syncStateUpdated:(void (^)(float))syncStateUpdated;

- (void)updateConfig:(NSString *)config blockchainName:(NSString *)blockchainName;
- (SSignal *)validateConfig:(NSString *)config blockchainName:(NSString *)blockchainName;

- (SSignal *)createKeyWithLocalPassword:(NSData *)localPassword mnemonicPassword:(NSData *)mnemonicPassword;
- (SSignal *)getCreatedWalletAccountAddressWithPublicKey:(NSString *)publicKey initialWalletId:(int64_t)initialWalletId;
- (SSignal *)guessImportedWalletAddressWithPublicKey:(NSString *)publicKey;
//- (SSignal *)getAccountStateWithAddress:(NSString *)accountAddress;
//- (SSignal *)generateSendGramsQueryFromKey:(TONKey *)key localPassword:(NSData *)localPassword fromAddress:(NSString *)fromAddress toAddress:(NSString *)address amount:(int64_t)amount comment:(NSData *)comment encryptComment:(bool)encryptComment forceIfDestinationNotInitialized:(bool)forceIfDestinationNotInitialized timeout:(int32_t)timeout randomId:(int64_t)randomId;
//- (SSignal *)generateFakeSendGramsQueryFromAddress:(NSString *)fromAddress toAddress:(NSString *)address amount:(int64_t)amount comment:(NSData *)comment encryptComment:(bool)encryptComment forceIfDestinationNotInitialized:(bool)forceIfDestinationNotInitialized timeout:(int32_t)timeout;
- (SSignal *)estimateSendGramsQueryFees:(TONPreparedSendGramsQuery *)preparedQuery;
- (SSignal *)commitPreparedSendGramsQuery:(TONPreparedSendGramsQuery *)preparedQuery;
- (SSignal *)exportKey:(TONKey *)key localPassword:(NSData *)localPassword;
- (SSignal *)importKeyWithLocalPassword:(NSData *)localPassword mnemonicPassword:(NSData *)mnemonicPassword wordList:(NSArray<NSString *> *)wordList;
- (SSignal *)deleteKey:(TONKey *)key;
- (SSignal *)deleteAllKeys;
- (SSignal *)getTransactionListWithAddress:(NSString * _Nonnull)address lt:(int64_t)lt hash:(NSData * _Nonnull)hash;
- (SSignal *)decryptMessagesWithKey:(TONKey * _Nonnull)key localPassword:(NSData * _Nonnull)localPassword messages:(NSArray<TONEncryptedData *> * _Nonnull)messages;

- (NSData *)encrypt:(NSData *)decryptedData secret:(NSData *)data;
- (NSData * __nullable)decrypt:(NSData *)encryptedData secret:(NSData *)data;

// MARK: - NEW METHODS IN THIS VERSION

- (SSignal *)resolvedDNSWithRootDNSAccountAddress:(NSString * _Nullable)rootDNSAccountAddress
                                       domainName:(NSString *)domainName
                                         category:(NSString *)category
                                              ttl:(int32_t)ttl;

- (SSignal *)accountAddressWithCode:(NSData *)code
                               data:(NSData *)data
                          workchain:(int32_t)workchain;

- (SSignal *)getFullAccountStateWithAddress:(NSString *)accountAddress;

//- (int64_t) getCurrentSeqNo;

// Returns local id of account with given address (run local TVM machine)
- (SSignal *)accountLocalIDWithAccountAddress:(NSString *)accountAddress;

// Returns result of execution `methodName` for account with given `accountLocalID`  (run local TVM machine)
- (SSignal *)accountLocalID:(int64_t)smartcontractID
          runGetMethodNamed:(NSString *)methodName
                  arguments:(NSArray<TONExecutionStackValue> *)arguments;

- (SSignal *)prepareQueryWithDestinationAddress:(NSString *)destinationAddress
                        initialAccountStateData:(NSData * _Nullable)initialAccountStateData
                        initialAccountStateCode:(NSData * _Nullable)initialAccountStateCode
                                           body:(NSData *)body
                                       randomId:(int64_t)randomId;

- (SSignal *)exportDecryptedKeyWithEncryptedKey:(GTTONKey *)encryptedKey
                               withUserPassword:(NSData *)userPassword;

@end

NS_ASSUME_NONNULL_END
