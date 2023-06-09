#import "TON.h"

#import "tonlib/Client.h"
#import "NSData+SHA256.h"


static td::SecureString makeSecureString(NSData * _Nonnull data) {
    if (data == nil || data.length == 0) {
        return td::SecureString();
    } else {
        return td::SecureString((const char *)data.bytes, (size_t)data.length);
    }
}

static std::string makeString(NSData * _Nonnull data) {
    if (data == nil || data.length == 0) {
        return std::string();
    } else {
        return std::string((const char *)data.bytes, ((const char *)data.bytes) + data.length);
    }
}

static NSData * _Nonnull makeData(std::string &string) {
    if (string.size() == 0) {
        return [NSData data];
    } else {
        return [[NSData alloc] initWithBytes:string.data() length:string.size()];
    }
}

static NSString * _Nullable readString(std::string &string) {
    if (string.size() == 0) {
        return @"";
    } else {
        return [[NSString alloc] initWithBytes:string.data() length:string.size() encoding:NSUTF8StringEncoding];
    }
}

static NSData * _Nullable readSecureString(td::SecureString &string) {
    if (string.size() == 0) {
        return [NSData data];
    } else {
        return [[NSData alloc] initWithBytes:string.data() length:string.size()];
    }
}

static TONTransactionMessage * _Nullable parseTransactionMessage(tonlib_api::object_ptr<tonlib_api::raw_message> &message) {
    if (message == nullptr) {
        return nil;
    }
    NSString *source = readString(message->source_->account_address_);
    NSString *destination = readString(message->destination_->account_address_);
    
    id<TONTransactionMessageContents> contents = nil;
    if (message->msg_data_->get_id() == tonlib_api::msg_dataRaw::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataRaw>(message->msg_data_);
        contents = [[TONTransactionMessageContentsRawData alloc] initWithData:makeData(msgData->body_)];
    } else if (message->msg_data_->get_id() == tonlib_api::msg_dataText::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataText>(message->msg_data_);
        NSString *text = readString(msgData->text_);
        if (text == nil) {
            contents = [[TONTransactionMessageContentsPlainText alloc] initWithText:@""];
        } else {
            contents = [[TONTransactionMessageContentsPlainText alloc] initWithText:text];
        }
    } else if (message->msg_data_->get_id() == tonlib_api::msg_dataDecryptedText::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataDecryptedText>(message->msg_data_);
        NSString *text = readString(msgData->text_);
        if (text == nil) {
            contents = [[TONTransactionMessageContentsPlainText alloc] initWithText:@""];
        } else {
            contents = [[TONTransactionMessageContentsPlainText alloc] initWithText:text];
        }
    } else if (message->msg_data_->get_id() == tonlib_api::msg_dataEncryptedText::ID) {
        auto msgData = tonlib_api::move_object_as<tonlib_api::msg_dataEncryptedText>(message->msg_data_);
        TONEncryptedData *encryptedData = [[TONEncryptedData alloc] initWithSourceAddress:source data:makeData(msgData->text_)];
        contents = [[TONTransactionMessageContentsEncryptedText alloc] initWithEncryptedData:encryptedData];
    } else {
        contents = [[TONTransactionMessageContentsRawData alloc] initWithData:[NSData data]];
    }
    
    if (source == nil || destination == nil) {
        return nil;
    }
    return [[TONTransactionMessage alloc] initWithValue:message->value_ source:source destination:destination contents:contents bodyHash:makeData(message->body_hash_)];
}

@implementation TONKey

- (instancetype)initWithPublicKey:(NSString *)publicKey secret:(NSData *)secret {
    self = [super init];
    if (self != nil) {
        _publicKey = publicKey;
        _secret = secret;
    }
    return self;
}

@end

@implementation TONAccountState

- (instancetype)initWithIsInitialized:(bool)isInitialized isRWallet:(bool)isRWallet balance:(int64_t)balance unlockedBalance:(int64_t)unlockedBalance seqno:(int32_t)seqno lastTransactionId:(TONTransactionId * _Nullable)lastTransactionId syncUtime:(int64_t)syncUtime {
    self = [super init];
    if (self != nil) {
        _isInitialized = isInitialized;
        _isRWallet = isRWallet;
        _balance = balance;
        _unlockedBalance = unlockedBalance;
        _seqno = seqno;
        _lastTransactionId = lastTransactionId;
        _syncUtime = syncUtime;
    }
    return self;
}

@end

@implementation TONTransactionId

- (instancetype)initWithLt:(int64_t)lt transactionHash:(NSData *)transactionHash {
    self = [super init];
    if (self != nil) {
        _lt = lt;
        _transactionHash = transactionHash;
    }
    return self;
}

@end

@implementation TONTransactionMessageContentsRawData

- (instancetype)initWithData:(NSData * _Nonnull)data {
    self = [super init];
    if (self != nil) {
        _data = data;
    }
    return self;
}

@end

@implementation TONTransactionMessageContentsPlainText

- (instancetype)initWithText:(NSString * _Nonnull)text {
    self = [super init];
    if (self != nil) {
        _text = text;
    }
    return self;
}

@end

@implementation TONTransactionMessageContentsEncryptedText

- (instancetype)initWithEncryptedData:(TONEncryptedData * _Nonnull)encryptedData {
    self = [super init];
    if (self != nil) {
        _encryptedData = encryptedData;
    }
    return self;
}

@end

@implementation TONTransactionMessage

- (instancetype)initWithValue:(int64_t)value source:(NSString * _Nonnull)source destination:(NSString * _Nonnull)destination contents:(id<TONTransactionMessageContents> _Nonnull)contents bodyHash:(NSData * _Nonnull)bodyHash {
    self = [super init];
    if (self != nil) {
        _value = value;
        _source = source;
        _destination = destination;
        _contents = contents;
        _bodyHash = bodyHash;
    }
    return self;
}

@end

@implementation TONTransaction

- (instancetype)initWithData:(NSData * _Nonnull)data transactionId:(TONTransactionId * _Nonnull)transactionId timestamp:(int64_t)timestamp storageFee:(int64_t)storageFee otherFee:(int64_t)otherFee inMessage:(TONTransactionMessage * _Nullable)inMessage outMessages:(NSArray<TONTransactionMessage *> * _Nonnull)outMessages  isInitialization:(bool)isInitialization {
    self = [super init];
    if (self != nil) {
        _data = data;
        _transactionId = transactionId;
        _timestamp = timestamp;
        _storageFee = storageFee;
        _otherFee = otherFee;
        _inMessage = inMessage;
        _outMessages = outMessages;
        _isInitialization = isInitialization;
    }
    return self;
}

@end

@implementation TONExternalRequest

- (instancetype)initWithData:(NSData * _Nonnull)data onResult:(void (^)(NSData * _Nullable, NSString * _Nullable))onResult {
    self = [super init];
    if (self != nil) {
        _data = data;
        _onResult = [onResult copy];
    }
    return self;
}

@end

@implementation TONFees

- (instancetype)initWithInFwdFee:(int64_t)inFwdFee storageFee:(int64_t)storageFee gasFee:(int64_t)gasFee fwdFee:(int64_t)fwdFee {
    self = [super init];
    if (self != nil) {
        _inFwdFee = inFwdFee;
        _storageFee = storageFee;
        _gasFee = gasFee;
        _fwdFee = fwdFee;
    }
    return self;
}

@end

@implementation TONSendGramsQueryFees

- (instancetype)initWithSourceFees:(TONFees * _Nonnull)sourceFees destinationFees:(NSArray<TONFees *> * _Nonnull)destinationFees {
    self = [super init];
    if (self != nil) {
        _sourceFees = sourceFees;
        _destinationFees = destinationFees;
    }
    return self;
}

@end

@implementation TONPreparedSendGramsQuery

- (instancetype)initWithQueryId:(int64_t)queryId validUntil:(int64_t)validUntil bodyHash:(NSData *)bodyHash bocData:(NSData *)bocData {
    self = [super init];
    if (self != nil) {
        _queryId = queryId;
        _validUntil = validUntil;
        _bodyHash = bodyHash;
        _bocData = bocData;
    }
    return self;
}

@end

@implementation TONSendGramsResult

- (instancetype)initWithSentUntil:(int64_t)sentUntil bodyHash:(NSData *)bodyHash {
    self = [super init];
    if (self != nil) {
        _sentUntil = sentUntil;
        _bodyHash = bodyHash;
    }
    return self;
}

@end

@implementation TONValidatedConfig

- (instancetype)initWithDefaultWalletId:(int64_t)defaultWalletId {
    self = [super init];
    if (self != nil) {
        _defaultWalletId = defaultWalletId;
    }
    return self;
}

@end

@implementation TONEncryptedData

- (instancetype)initWithSourceAddress:(NSString * _Nonnull)sourceAddress data:(NSData * _Nonnull)data {
    self = [super init];
    if (self != nil) {
        _sourceAddress = sourceAddress;
        _data = data;
    }
    return self;
}

@end

#pragma mark - TONDNSEntryText

@implementation TONDNSEntryText

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        _text = [text copy];
    }
    return self;
}

@end

#pragma mark - TONDNSEntrySMCAddress

@implementation TONDNSEntrySMCAddress

- (instancetype)initWithAddress:(NSString *)address
{
    self = [super init];
    if (self) {
        _address = [address copy];
    }
    return self;
}

@end

#pragma mark - TONDNSEntryNextResolver

@implementation TONDNSEntryNextResolver

- (instancetype)initWithAddress:(NSString *)address
{
    self = [super init];
    if (self) {
        _address = [address copy];
    }
    return self;
}

@end

#pragma mark - TONDNS

@implementation TONDNS

- (instancetype)initWithName:(NSString *)name
                     entries:(NSArray<TONDNSEntry> *)entries
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _entries = [entries copy];
    }
    return self;
}

@end

#pragma mark - TONLocalID

@implementation TONLocalID : NSObject

- (instancetype)initWithID:(int64_t)localID;
{
    self = [super init];
    if (self) {
        _localID = localID;
    }
    return self;
}

@end

@implementation TONExecutionResult

- (instancetype)initWithCode:(int32_t)code
                       stack:(NSArray<TONExecutionStackValue> *)stack
{
    self = [super init];
    if (self != nil) {
        _code = code;
        _stack = [stack copy];
    }
    return self;
}

@end

@implementation TONExecutionResultDecimal

- (instancetype)initWithValue:(NSString *)value
{
    self = [super init];
    if (self != nil) {
        _value = [value copy];
    }
    return self;
}

@end

@implementation TONExecutionResultSlice

- (instancetype)initWithHEX:(NSData *)hex;
{
    self = [super init];
    if (self != nil) {
        _hex = [hex copy];
    }
    return self;
}

@end

@implementation TONExecutionResultCell

- (instancetype)initWithHEX:(NSData *)hex;
{
    self = [super init];
    if (self != nil) {
        _hex = [hex copy];
    }
    return self;
}

@end

@implementation TONExecutionResultEnumeration

- (instancetype)initWithEnumeration:(NSArray<TONExecutionStackValue> *)enumeration
{
    self = [super init];
    if (self != nil) {
        _enumeration = [enumeration copy];
    }
    return self;
}

@end

using tonlib_api::make_object;

@interface TONReceiveThreadParams : NSObject

@property (nonatomic, readonly) std::shared_ptr<tonlib::Client> client;
@property (nonatomic, copy, readonly) void (^received)(tonlib::Client::Response &);

@end

@implementation TONReceiveThreadParams

- (instancetype)initWithClient:(std::shared_ptr<tonlib::Client>)client received:(void (^)(tonlib::Client::Response &))received {
    self = [super init];
    if (self != nil) {
        _client = client;
        _received = [received copy];
    }
    return self;
}

@end

@interface TONRequestHandler : NSObject

@property (nonatomic, copy, readonly) void (^completion)(tonlib_api::object_ptr<tonlib_api::Object> &);

@end

@implementation TONRequestHandler

- (instancetype)initWithCompletion:(void (^)(tonlib_api::object_ptr<tonlib_api::Object> &))completion {
    self = [super init];
    if (self != nil) {
        _completion = [completion copy];
    }
    return self;
}

@end

@implementation TONError

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self != nil) {
        _text = text;
    }
    return self;
}

@end

typedef enum {
    TONInitializationStatusInitializing,
    TONInitializationStatusReady,
    TONInitializationStatusError
} TONInitializationStatus;

@interface TON () {
    std::shared_ptr<tonlib::Client> _client;
    uint64_t _nextRequestId;
    NSLock *_requestHandlersLock;
    NSMutableDictionary<NSNumber *, TONRequestHandler *> *_requestHandlers;
    SPipe *_initializedStatus;
    NSMutableSet *_sendGramRandomIds;
    SQueue *_queue;
    bool _enableExternalRequests;
    NSString *_currentConfig;
    //int64_t _current_seqno_;
}

@end

@implementation TON

+ (void)receiveThread:(TONReceiveThreadParams *)params {
    while (true) {
        auto response = params.client->receive(1000);
        if (response.object) {
            params.received(response);
        }
    }
}

- (instancetype)initWithKeystoreDirectory:(NSString *)keystoreDirectory config:(NSString *)config blockchainName:(NSString *)blockchainName performExternalRequest:(void (^)(TONExternalRequest * _Nonnull))performExternalRequest enableExternalRequests:(bool)enableExternalRequests syncStateUpdated:(void (^)(float))syncStateUpdated {
    self = [super init];
    if (self != nil) {
        _queue = [SQueue mainQueue];
        _requestHandlersLock = [[NSLock alloc] init];
        _requestHandlers = [[NSMutableDictionary alloc] init];
        _initializedStatus = [[SPipe alloc] initWithReplay:true];
        _initializedStatus.sink(@(TONInitializationStatusInitializing));
        _nextRequestId = 1;
        _sendGramRandomIds = [[NSMutableSet alloc] init];
        _enableExternalRequests = enableExternalRequests;
        _currentConfig = config;
        
        _client = std::make_shared<tonlib::Client>();
        
        [self setupLogging];
        
        std::weak_ptr<tonlib::Client> weakClient = _client;
        
        NSLock *requestHandlersLock = _requestHandlersLock;
        NSMutableDictionary *requestHandlers = _requestHandlers;
        NSThread *thread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(receiveThread:) object:[[TONReceiveThreadParams alloc] initWithClient:_client received:^(tonlib::Client::Response &response) {
            if (response.object->get_id() == tonlib_api::updateSendLiteServerQuery::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::updateSendLiteServerQuery>(response.object);
                int64_t requestId = result->id_;
                NSData *data = makeData(result->data_);
                if (performExternalRequest) {
                    performExternalRequest([[TONExternalRequest alloc] initWithData:data onResult:^(NSData * _Nullable result, NSString * _Nullable error) {
                        auto strongClient = weakClient.lock();
                        if (strongClient != nullptr) {
                            if (result != nil) {
                                auto query = make_object<tonlib_api::onLiteServerQueryResult>(
                                    requestId,
                                    makeString(result)
                                );
                                strongClient->send({ 1, std::move(query) });
                            } else if (error != nil) {
                                auto query = make_object<tonlib_api::onLiteServerQueryError>(
                                    requestId,
                                    make_object<tonlib_api::error>(
                                        400,
                                        error.UTF8String
                                    )
                                );
                                strongClient->send({ 1, std::move(query) });
                            }
                        }
                    }]);
                }
                return;
            } else if (response.object->get_id() == tonlib_api::updateSyncState::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::updateSyncState>(response.object);
                if (result->sync_state_->get_id() == tonlib_api::syncStateInProgress::ID) {
                    auto syncStateInProgress = tonlib_api::move_object_as<tonlib_api::syncStateInProgress>(result->sync_state_);

                    // hold current seqno
                    //self->_current_seqno_ = syncStateInProgress->current_seqno_;

                    int32_t currentDelta = syncStateInProgress->current_seqno_ - syncStateInProgress->from_seqno_;
                    int32_t fullDelta = syncStateInProgress->to_seqno_ - syncStateInProgress->from_seqno_;
                    if (currentDelta > 0 && fullDelta > 0) {
                        float progress = ((float)currentDelta) / ((float)fullDelta);
                        syncStateUpdated(progress);
                    } else {
                        syncStateUpdated(0.0f);
                    }
                } else if (result->sync_state_->get_id() == tonlib_api::syncStateDone::ID) {
                    syncStateUpdated(1.0f);
                }
                return;
            }
            NSNumber *requestId = @(response.id);
            [requestHandlersLock lock];
            TONRequestHandler *handler = requestHandlers[requestId];
            [requestHandlers removeObjectForKey:requestId];
            [requestHandlersLock unlock];
            if (handler != nil) {
                handler.completion(response.object);
            }
        }]];
        [thread start];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:keystoreDirectory withIntermediateDirectories:true attributes:nil error:nil];
        
        SPipe *initializedStatus = _initializedStatus;
        [self requestInitWithConfigString:config blockchainName:blockchainName keystoreDirectory:keystoreDirectory enableExternalRequests:enableExternalRequests completion:^{
            initializedStatus.sink(@(TONInitializationStatusReady));
        }];
    }
    return self;
}

- (void)setupLogging {
#if DEBUG
    auto query = make_object<tonlib_api::setLogStream>(
        make_object<tonlib_api::logStreamDefault>()
    );
    _client->execute({ INT16_MAX + 1, std::move(query) });
#else
    auto query = make_object<tonlib_api::setLogStream>(
        make_object<tonlib_api::logStreamEmpty>()
    );
    _client->execute({ INT16_MAX + 1, std::move(query) });
#endif
}

- (NSData * __nullable)decrypt:(NSData *)encryptedData secret:(NSData *)data {
    auto query = make_object<tonlib_api::decrypt>(makeSecureString(encryptedData), makeSecureString(data));
    tonlib_api::object_ptr<tonlib_api::Object> result = _client->execute({ INT16_MAX + 1, std::move(query) }).object;
    
    if (result->get_id() == tonlib_api::error::ID) {
        return nil;
    } else {
        tonlib_api::object_ptr<tonlib_api::data> value = tonlib_api::move_object_as<tonlib_api::data>(result);
        return readSecureString(value->bytes_);
    }
}

- (NSData *)encrypt:(NSData *)decryptedData secret:(NSData *)data {
    auto query = make_object<tonlib_api::encrypt>(makeSecureString(decryptedData), makeSecureString(data));
    tonlib_api::object_ptr<tonlib_api::Object> result = _client->execute({ INT16_MAX + 1, std::move(query) }).object;
    
    tonlib_api::object_ptr<tonlib_api::data> value = tonlib_api::move_object_as<tonlib_api::data>(result);
    
    return readSecureString(value->bytes_);
}

- (void)requestInitWithConfigString:(NSString *)configString blockchainName:(NSString *)blockchainName keystoreDirectory:(NSString *)keystoreDirectory enableExternalRequests:(bool)enableExternalRequests completion:(void (^)())completion {
    [_queue dispatch:^{
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                //auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                //[subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else {
                //[subscriber putCompletion];
            }
            if (completion) {
                completion();
            }
        }];
        
        bool ignoreCache = false;
        #if DEBUG
        //ignoreCache = true;
        #endif
        
        auto query = make_object<tonlib_api::init>(make_object<tonlib_api::options>(
            make_object<tonlib_api::config>(
                configString.UTF8String,
                blockchainName.UTF8String,
                enableExternalRequests,
                ignoreCache
            ),
            make_object<tonlib_api::keyStoreTypeDirectory>(
                keystoreDirectory.UTF8String
            )
        ));
        self->_client->send({ requestId, std::move(query) });
    }];
}

- (SSignal *)wrapSignal:(SSignal *)signal {
    return signal;
    /*return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        [[[[_initializedStatus.signalProducer() filter:^bool(NSNumber *value) {
            int nValue = [value intValue];
            if (nValue == TONInitializationStatusReady) {
                return true;
            } else {
                return false;
            }
        }] take:1] deliverOn:_queue] startWithNext:^(__unused id ready) {
            [disposable setDisposable:[signal startWithNext:^(id next) {
                [subscriber putNext:next];
            } error:^(id error) {
                [subscriber putError:error];
            } completed:^{
                [subscriber putCompletion];
            }]];
        }];
        return disposable;
    }] startOn:_queue];*/
}

- (void)updateConfig:(NSString *)config blockchainName:(NSString *)blockchainName {
    SQueue *queue = _queue;
    [queue dispatch:^{
        if ([self->_currentConfig isEqualToString:config]) {
            return;
        }
        self->_currentConfig = config;
        
        self->_initializedStatus.sink(@(TONInitializationStatusInitializing));
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                //[subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else {
                //[subscriber putCompletion];
            }
            [queue dispatch:^{
                self->_initializedStatus.sink(@(TONInitializationStatusReady));
            }];
        }];
        
        auto query = make_object<tonlib_api::options_setConfig>(
            make_object<tonlib_api::config>(
                config.UTF8String,
                blockchainName.UTF8String,
                self->_enableExternalRequests,
                false
            )
        );
        self->_client->send({ requestId, std::move(query) });
    }];
}

- (SSignal *)validateConfig:(NSString *)config blockchainName:(NSString *)blockchainName {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::options_configInfo::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::options_configInfo>(object);
                [subscriber putNext:[[TONValidatedConfig alloc] initWithDefaultWalletId:result->default_wallet_id_]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::options_validateConfig>(
            make_object<tonlib_api::config>(
                config.UTF8String,
                blockchainName.UTF8String,
                self->_enableExternalRequests,
                false
            )
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)createKeyWithLocalPassword:(NSData *)localPassword mnemonicPassword:(NSData *)mnemonicPassword {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::key::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::key>(object);
                NSString *publicKey = [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:result->public_key_.data() length:result->public_key_.length()] encoding:NSUTF8StringEncoding];
                if (publicKey == nil) {
                    [subscriber putError:[[TONError alloc] initWithText:@"Error decoding UTF8 string in createKeyWithLocalPassword"]];
                    return;
                }
                NSData *secret = [[NSData alloc] initWithBytes:result->secret_.data() length:result->secret_.length()];
                [subscriber putNext:[[TONKey alloc] initWithPublicKey:publicKey secret:secret]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::createNewKey>(
            makeSecureString(localPassword),
            makeSecureString(mnemonicPassword),
            td::SecureString()
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)getCreatedWalletAccountAddressWithPublicKey:(NSString *)publicKey initialWalletId:(int64_t)initialWalletId {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *publicKeyData = [publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in getWalletAccountAddressWithPublicKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::accountAddress::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::accountAddress>(object);
                [subscriber putNext:[[NSString alloc] initWithUTF8String:result->account_address_.c_str()]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        tonlib_api::object_ptr<tonlib_api::InitialAccountState> initialAccountState = tonlib_api::move_object_as<tonlib_api::InitialAccountState>(make_object<tonlib_api::wallet_v3_initialAccountState>(
            makeString(publicKeyData),
            initialWalletId
        ));
        
        auto query = make_object<tonlib_api::getAccountAddress>(
            tonlib_api::move_object_as<tonlib_api::InitialAccountState>(initialAccountState),
            0,
            0
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)guessImportedWalletAddressWithPublicKey:(NSString *)publicKey {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *publicKeyData = [publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in getWalletAccountAddressWithPublicKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::accountRevisionList::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::accountRevisionList>(object);
                
                if (result->revisions_.size() != 0) {
                    [subscriber putNext:[[NSString alloc] initWithUTF8String:result->revisions_[0]->address_->account_address_.c_str()]];
                } else {
                    [subscriber putError:@"NO_ADDRESS"];
                }
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::guessAccount>(
            makeString(publicKeyData),
            ""
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

/*- (SSignal *)getAccountStateWithAddress:(NSString *)accountAddress {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::fullAccountState::ID) {
                auto fullAccountState = tonlib_api::move_object_as<tonlib_api::fullAccountState>(object);
                int32_t seqNo = -1;
                
                bool isRWallet = false;
                int64_t unlockedBalance = INT64_MAX;
                
                if (fullAccountState->account_state_->get_id() == tonlib_api::uninited_accountState::ID) {
                    seqNo = -1;
                } else if (fullAccountState->account_state_->get_id() == tonlib_api::wallet_v3_accountState::ID) {
                    auto v3AccountState = tonlib_api::move_object_as<tonlib_api::wallet_v3_accountState>(fullAccountState->account_state_);
                    seqNo = v3AccountState->seqno_;
                 } else if (fullAccountState->account_state_->get_id() == tonlib_api::rwallet_accountState::ID) {
                     auto rwalletAccountState = tonlib_api::move_object_as<tonlib_api::rwallet_accountState>(fullAccountState->account_state_);
                     isRWallet = true;
                     unlockedBalance = rwalletAccountState->unlocked_balance_;
                     seqNo = rwalletAccountState->seqno_;
                 }else {
                    [subscriber putError:[[TONError alloc] initWithText:@"Unknown type"]];
                    return;
                }
                
                TONTransactionId *lastTransactionId = nil;
                if (fullAccountState->last_transaction_id_ != nullptr) {
                    lastTransactionId = [[TONTransactionId alloc] initWithLt:fullAccountState->last_transaction_id_->lt_ transactionHash:makeData(fullAccountState->last_transaction_id_->hash_)];
                }
                [subscriber putNext:[[TONAccountState alloc] initWithIsInitialized:false isRWallet:isRWallet balance:fullAccountState->balance_ unlockedBalance:unlockedBalance seqno:-1 lastTransactionId:lastTransactionId syncUtime:fullAccountState->sync_utime_]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::getAccountState>(make_object<tonlib_api::accountAddress>(accountAddress.UTF8String));
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}*/

/*- (SSignal *)generateSendGramsQueryFromKey:(TONKey *)key localPassword:(NSData *)localPassword fromAddress:(NSString *)fromAddress toAddress:(NSString *)address amount:(int64_t)amount comment:(NSData *)comment encryptComment:(bool)encryptComment forceIfDestinationNotInitialized:(bool)forceIfDestinationNotInitialized timeout:(int32_t)timeout randomId:(int64_t)randomId {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        if ([self->_sendGramRandomIds containsObject:@(randomId)]) {
            [self->_sendGramRandomIds addObject:@(randomId)];
            
            return [[SBlockDisposable alloc] initWithBlock:^{
            }];
        }
        
        NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in sendGramsFromKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        __weak TON *weakSelf = self;
        SQueue *queue = self->_queue;
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                [queue dispatch:^{
                    __strong TON *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [self->_sendGramRandomIds removeObject:@(randomId)];
                    }
                }];
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::query_info::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::query_info>(object);
                TONPreparedSendGramsQuery *preparedQuery = [[TONPreparedSendGramsQuery alloc] initWithQueryId:result->id_ validUntil:result->valid_until_ bodyHash:makeData(result->body_hash_)];
                [subscriber putNext:preparedQuery];
                [subscriber putCompletion];
            } else {
                [subscriber putCompletion];
            }
        }];
        
        tonlib_api::object_ptr<tonlib_api::msg_Data> inputMessageData;
        if (encryptComment && comment.length != 0) {
            inputMessageData = make_object<tonlib_api::msg_dataDecryptedText>(
                makeString(comment)
            );
        } else {
            inputMessageData = make_object<tonlib_api::msg_dataText>(
                makeString(comment)
            );
        }
        std::vector<tonlib_api::object_ptr<tonlib_api::msg_message> > inputMessages;
        inputMessages.push_back(make_object<tonlib_api::msg_message>(
            make_object<tonlib_api::accountAddress>(address.UTF8String),
            makeString([NSData data]),
            amount,
            tonlib_api::move_object_as<tonlib_api::msg_Data>(inputMessageData),
            SEND_MODE
        ));
        auto inputAction = make_object<tonlib_api::actionMsg>(
            std::move(inputMessages),
            forceIfDestinationNotInitialized
        );
        
        auto query = make_object<tonlib_api::createQuery>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    makeString(publicKeyData),
                    makeSecureString(key.secret)
                ),
                makeSecureString(localPassword)
            ),
            make_object<tonlib_api::accountAddress>(fromAddress.UTF8String),
            timeout,
            tonlib_api::move_object_as<tonlib_api::Action>(inputAction),
            nil
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}*/

/*- (SSignal *)generateFakeSendGramsQueryFromAddress:(NSString *)fromAddress toAddress:(NSString *)address amount:(int64_t)amount comment:(NSData *)comment encryptComment:(bool)encryptComment forceIfDestinationNotInitialized:(bool)forceIfDestinationNotInitialized timeout:(int32_t)timeout {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::query_info::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::query_info>(object);
                TONPreparedSendGramsQuery *preparedQuery = [[TONPreparedSendGramsQuery alloc] initWithQueryId:result->id_ validUntil:result->valid_until_ bodyHash:makeData(result->body_hash_)];
                [subscriber putNext:preparedQuery];
                [subscriber putCompletion];
            } else {
                [subscriber putCompletion];
            }
        }];
        
        tonlib_api::object_ptr<tonlib_api::msg_Data> inputMessageData;
        if (encryptComment && comment.length != 0) {
            inputMessageData = make_object<tonlib_api::msg_dataDecryptedText>(
                makeString(comment)
            );
        } else {
            inputMessageData = make_object<tonlib_api::msg_dataText>(
                makeString(comment)
            );
        }
        std::vector<tonlib_api::object_ptr<tonlib_api::msg_message> > inputMessages;
        inputMessages.push_back(make_object<tonlib_api::msg_message>(
            make_object<tonlib_api::accountAddress>(address.UTF8String),
            makeString([NSData data]),
            amount,
            tonlib_api::move_object_as<tonlib_api::msg_Data>(inputMessageData),
            SEND_MODE
        ));
        auto inputAction = make_object<tonlib_api::actionMsg>(
            std::move(inputMessages),
            forceIfDestinationNotInitialized
        );
        
        auto query = make_object<tonlib_api::createQuery>(
            make_object<tonlib_api::inputKeyFake>(),
            make_object<tonlib_api::accountAddress>(fromAddress.UTF8String),
            timeout,
            tonlib_api::move_object_as<tonlib_api::Action>(inputAction),
            nil
       );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}*/

- (SSignal *)estimateSendGramsQueryFees:(TONPreparedSendGramsQuery *)preparedQuery {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::query_fees::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::query_fees>(object);
                TONFees *sourceFees = [[TONFees alloc] initWithInFwdFee:result->source_fees_->in_fwd_fee_ storageFee:result->source_fees_->storage_fee_ gasFee:result->source_fees_->gas_fee_ fwdFee:result->source_fees_->fwd_fee_];
                NSMutableArray<TONFees *> *destinationFees = [[NSMutableArray alloc] init];
                for (auto &fee : result->destination_fees_) {
                    TONFees *destinationFee = [[TONFees alloc] initWithInFwdFee:fee->in_fwd_fee_ storageFee:fee->storage_fee_ gasFee:fee->gas_fee_ fwdFee:fee->fwd_fee_];
                    [destinationFees addObject:destinationFee];
                }
                
                [subscriber putNext:[[TONSendGramsQueryFees alloc] initWithSourceFees:sourceFees destinationFees:destinationFees]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::query_estimateFees>(
            preparedQuery.queryId,
            true
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)commitPreparedSendGramsQuery:(TONPreparedSendGramsQuery *)preparedQuery {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::ok::ID) {
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::query_send>(
            preparedQuery.queryId
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)exportKey:(TONKey *)key localPassword:(NSData *)localPassword {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in exportKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::exportedKey::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::exportedKey>(object);
                NSMutableArray *wordList = [[NSMutableArray alloc] init];
                for (auto &it : result->word_list_) {
                    NSString *string = [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:it.data() length:it.size()] encoding:NSUTF8StringEncoding];
                    if (string == nil) {
                        [subscriber putError:[[TONError alloc] initWithText:@"Error decoding UTF8 string in exportedKey::word_list"]];
                        return;
                    }
                    [wordList addObject:string];
                }
                [subscriber putNext:wordList];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        auto query = make_object<tonlib_api::exportKey>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    makeString(publicKeyData),
                    makeSecureString(key.secret)
                ),
                makeSecureString(localPassword)
            )
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)importKeyWithLocalPassword:(NSData *)localPassword mnemonicPassword:(NSData *)mnemonicPassword wordList:(NSArray<NSString *> *)wordList {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::key::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::key>(object);
                NSString *publicKey = [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:result->public_key_.data() length:result->public_key_.length()] encoding:NSUTF8StringEncoding];
                if (publicKey == nil) {
                    [subscriber putError:[[TONError alloc] initWithText:@"Error decoding UTF8 string in importKeyWithLocalPassword"]];
                    return;
                }
                NSData *secret = [[NSData alloc] initWithBytes:result->secret_.data() length:result->secret_.length()];
                [subscriber putNext:[[TONKey alloc] initWithPublicKey:publicKey secret:secret]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        std::vector<td::SecureString> wordVector;
        for (NSString *word in wordList) {
            NSData *wordData = [word dataUsingEncoding:NSUTF8StringEncoding];
            wordVector.push_back(makeSecureString(wordData));
        }
        
        auto query = make_object<tonlib_api::importKey>(
            makeSecureString(localPassword),
            makeSecureString(mnemonicPassword),
            make_object<tonlib_api::exportedKey>(std::move(wordVector)));
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)deleteKey:(TONKey *)key {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in deleteKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else {
                [subscriber putCompletion];
            }
        }];
        
        auto query = make_object<tonlib_api::deleteKey>(
            make_object<tonlib_api::key>(
                makeString(publicKeyData),
                makeSecureString(key.secret)
            )
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)deleteAllKeys {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else {
                [subscriber putCompletion];
            }
        }];
        
        auto query = make_object<tonlib_api::deleteAllKeys>();
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)getTransactionListWithAddress:(NSString * _Nonnull)address lt:(int64_t)lt hash:(NSData * _Nonnull)hash {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *addressData = [address dataUsingEncoding:NSUTF8StringEncoding];
        if (addressData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in getTransactionListWithAddress"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::raw_transactions::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::raw_transactions>(object);
                NSMutableArray<TONTransaction *> *transactions = [[NSMutableArray alloc] init];
                
                TONTransactionId *initializationTransactionId = nil;
                if (result->transactions_.size() != 0 && result->previous_transaction_id_->lt_ == 0) {
                    for (int i = (int)(result->transactions_.size()) - 1; i >= 0; i--) {
                        if (result->transactions_[i]->in_msg_ == nullptr || result->transactions_[i]->in_msg_->value_ == 0) {
                            break;
                        } else {
                            int64_t value = 0;
                            if (result->transactions_[i]->in_msg_ != nullptr) {
                                value += result->transactions_[i]->in_msg_->value_;
                            }
                            for (auto &message : result->transactions_[i]->out_msgs_) {
                                value -= message->value_;
                            }
                            if (value == 0) {
                                initializationTransactionId = [[TONTransactionId alloc] initWithLt:result->transactions_[i]->transaction_id_->lt_ transactionHash:makeData(result->transactions_[i]->transaction_id_->hash_)];
                                break;
                            }
                        }
                    }
                }
                
                for (auto &it : result->transactions_) {
                    TONTransactionId *transactionId = [[TONTransactionId alloc] initWithLt:it->transaction_id_->lt_ transactionHash:makeData(it->transaction_id_->hash_)];
                    TONTransactionMessage *inMessage = parseTransactionMessage(it->in_msg_);
                    NSMutableArray<TONTransactionMessage *> * outMessages = [[NSMutableArray alloc] init];
                    for (auto &messageIt : it->out_msgs_) {
                        TONTransactionMessage *outMessage = parseTransactionMessage(messageIt);
                        if (outMessage != nil) {
                            [outMessages addObject:outMessage];
                        }
                    }
                    bool isInitialization = false;
                    if (initializationTransactionId != nil && initializationTransactionId.lt == transactionId.lt && [initializationTransactionId.transactionHash isEqualToData:transactionId.transactionHash]) {
                        isInitialization = true;
                    }
                    [transactions addObject:[[TONTransaction alloc] initWithData:makeData(it->data_) transactionId:transactionId timestamp:it->utime_ storageFee:it->storage_fee_ otherFee:it->other_fee_ inMessage:inMessage outMessages:outMessages  isInitialization:isInitialization]];
                }
                [subscriber putNext:transactions];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::raw_getTransactionsV2>(
            make_object<tonlib_api::inputKeyFake>(),
            make_object<tonlib_api::accountAddress>(
                makeString(addressData)
            ),
            make_object<tonlib_api::internal_transactionId>(
                lt,
                makeString(hash)
            ),
            20,
            true
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)decryptMessagesWithKey:(TONKey * _Nonnull)key localPassword:(NSData * _Nonnull)localPassword messages:(NSArray<TONEncryptedData *> * _Nonnull)messages {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *publicKeyData = [key.publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in decryptMessagesWithKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::msg_dataDecryptedArray::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::msg_dataDecryptedArray>(object);
                if (result->elements_.size() != messages.count) {
                    [subscriber putError:[[TONError alloc] initWithText:@"API interaction error"]];
                } else {
                    NSMutableArray<id<TONTransactionMessageContents> > *resultMessages = [[NSMutableArray alloc] init];
                    int index = 0;
                    for (auto &it : result->elements_) {
                        if (it->data_->get_id() == tonlib_api::msg_dataDecryptedText::ID) {
                            auto dataDecryptedText = tonlib_api::move_object_as<tonlib_api::msg_dataDecryptedText>(it->data_);
                            NSString *decryptedString = readString(dataDecryptedText->text_);
                            if (decryptedString != nil) {
                                [resultMessages addObject:[[TONTransactionMessageContentsPlainText alloc] initWithText:decryptedString]];
                            } else {
                                [resultMessages addObject:[[TONTransactionMessageContentsEncryptedText alloc] initWithEncryptedData:messages[index]]];
                            }
                        } else {
                            [resultMessages addObject:[[TONTransactionMessageContentsEncryptedText alloc] initWithEncryptedData:messages[index]]];
                        }
                        index++;
                    }
                    [subscriber putNext:resultMessages];
                    [subscriber putCompletion];
                }
            } else {
                assert(false);
            }
        }];
        
        std::vector<tonlib_api::object_ptr<tonlib_api::msg_dataEncrypted>> inputData;
        for (TONEncryptedData *message in messages) {
            NSData *sourceAddressData = [message.sourceAddress dataUsingEncoding:NSUTF8StringEncoding];
            if (sourceAddressData == nil) {
                continue;
            }
            
            inputData.push_back(make_object<tonlib_api::msg_dataEncrypted>(
                make_object<tonlib_api::accountAddress>(
                    makeString(sourceAddressData)
                ),
                make_object<tonlib_api::msg_dataEncryptedText>(
                    makeString(message.data)
                )
            ));
        }
        
        auto query = make_object<tonlib_api::msg_decrypt>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    makeString(publicKeyData),
                    makeSecureString(key.secret)
                ),
                makeSecureString(localPassword)
            ),
            make_object<tonlib_api::msg_dataEncryptedArray>(
                std::move(inputData)
            )
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

// MARK: - NEW METHODS IN THIS VERSION

- (SSignal *)resolvedDNSWithRootDNSAccountAddress:(NSString * _Nullable)rootDNSAccountAddress
                                       domainName:(NSString *)domainName
                                         category:(NSString *)category
                                              ttl:(int32_t)ttl {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *rootDNSAddressData = [rootDNSAccountAddress dataUsingEncoding:NSUTF8StringEncoding];
        if (rootDNSAddressData == nil) {
            rootDNSAddressData = [NSData new];
        }
        
        NSData *domainNameData = [domainName dataUsingEncoding:NSUTF8StringEncoding];
        if (domainNameData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Can't encode (UTF8) domainName."]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }
        
        NSData *categoryData = [[category dataUsingEncoding:NSUTF8StringEncoding] sha256];
        if (categoryData == nil && [categoryData length] == 32) {
            [subscriber putError:[[TONError alloc] initWithText:@"Can't encode (UTF8) category."]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }

        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::dns_resolved::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::dns_resolved>(object);
                
                
                NSMutableArray<TONDNSEntry> *entries = (NSMutableArray<TONDNSEntry> *)[NSMutableArray new];
                for (auto &resolved_entry : result->entries_) {
                    if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataText::ID) {
                        auto dns_entryDataText = tonlib_api::move_object_as<tonlib_api::dns_entryDataText>(resolved_entry->entry_);
                        TONDNSEntryText *entry = [[TONDNSEntryText alloc] initWithText:readString(dns_entryDataText->text_)];
                        [entries addObject:entry];
                    } else if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataNextResolver::ID) {
                        auto dns_entryDataNextResolver = tonlib_api::move_object_as<tonlib_api::dns_entryDataNextResolver>(resolved_entry->entry_);
                        NSString *address = readString(dns_entryDataNextResolver->resolver_->account_address_);
                        TONDNSEntryNextResolver *entry = [[TONDNSEntryNextResolver alloc] initWithAddress:address];
                        [entries addObject:entry];
                    } else if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataSmcAddress::ID) {
                        auto dns_entryDataSmcAddress = tonlib_api::move_object_as<tonlib_api::dns_entryDataSmcAddress>(resolved_entry->entry_);
                        NSString *address = readString(dns_entryDataSmcAddress->smc_address_->account_address_);
                        TONDNSEntrySMCAddress *entry = [[TONDNSEntrySMCAddress alloc] initWithAddress:address];
                        [entries addObject:entry];
                    } else if (resolved_entry->entry_->get_id() == tonlib_api::dns_entryDataAdnlAddress::ID) {
                        auto dns_entryDataText = tonlib_api::move_object_as<tonlib_api::dns_entryDataAdnlAddress>(resolved_entry->entry_);
                        continue;
                    } else {
                        continue;
                    }
                }
                
                TONDNS *dns = [[TONDNS alloc] initWithName:domainName entries:entries];
                [subscriber putNext:dns];
                [subscriber putCompletion];

            } else {
                assert(false);
            }
        }];
        
        auto category_bytes = std::array<unsigned char, 32>();
        const char *categoryDataBytes = (const char *)[categoryData bytes];
        for (int i = 0; i < [categoryData length]; i++) {
            category_bytes[i] = (unsigned char)categoryDataBytes[i];
        }
        
        auto query = make_object<tonlib_api::dns_resolve>(
            [rootDNSAddressData length] > 0 ? make_object<tonlib_api::accountAddress>(makeString(rootDNSAddressData)) : std::nullptr_t(),
            makeString(domainNameData),
            td::Bits256(category_bytes),
            ttl
        );
        
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)accountAddressWithCode:(NSData *)code
                               data:(NSData *)data
                          workchain:(int32_t)workchain {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::accountAddress::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::accountAddress>(object);
                [subscriber putNext:[[NSString alloc] initWithUTF8String:result->account_address_.c_str()]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        tonlib_api::object_ptr<tonlib_api::InitialAccountState> initialAccountState = tonlib_api::move_object_as<tonlib_api::InitialAccountState>(make_object<tonlib_api::raw_initialAccountState>(
            makeString(code),
            makeString(data)
        ));
        
        auto query = make_object<tonlib_api::getAccountAddress>(
            tonlib_api::move_object_as<tonlib_api::InitialAccountState>(initialAccountState),
            0, // revision is empty because we manually passed the initial data
            workchain
        );
        
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)getFullAccountStateWithAddress:(NSString *)accountAddress {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::raw_fullAccountState::ID) {
                auto fullAccountState = tonlib_api::move_object_as<tonlib_api::raw_fullAccountState>(object);

                TONTransactionId *lastTransactionId = nil;
                if (fullAccountState->last_transaction_id_ != nullptr) {
                    lastTransactionId = [[TONTransactionId alloc] initWithLt:fullAccountState->last_transaction_id_->lt_
                                                             transactionHash:makeData(fullAccountState->last_transaction_id_->hash_)];
                }

                bool isRWallet = false;
                int64_t unlockedBalance = fullAccountState->balance_;

                [subscriber putNext:[[TONAccountState alloc] initWithIsInitialized: fullAccountState->code_.size() > 0
                                                                         isRWallet:isRWallet
                                                                           balance:fullAccountState->balance_ unlockedBalance:unlockedBalance seqno:-1 lastTransactionId:lastTransactionId syncUtime:fullAccountState->sync_utime_]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::raw_getAccountState>(make_object<tonlib_api::accountAddress>(accountAddress.UTF8String));
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

/*- (int64_t) getCurrentSeqNo {
    return _current_seqno_;
}*/

- (SSignal *)accountLocalIDWithAccountAddress:(NSString *)accountAddress {
    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::smc_info::ID) {
                auto info = tonlib_api::move_object_as<tonlib_api::smc_info>(object);

                [subscriber putNext: [[TONLocalID alloc] initWithID:(info->id_)]];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::smc_load>(make_object<tonlib_api::accountAddress>(accountAddress.UTF8String));
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)accountLocalID:(int64_t)smartcontractID
          runGetMethodNamed:(NSString *)methodName
                  arguments:(NSArray<TONExecutionStackValue> *)arguments {
    id (^parser)(tonlib_api::object_ptr<tonlib_api::tvm_StackEntry> &) = ^id (tonlib_api::object_ptr<tonlib_api::tvm_StackEntry> &entry) {
        if (entry->get_id() == tonlib_api::tvm_stackEntryNumber::ID) {
            auto entryNumber = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryNumber>(entry);
            NSString *value = readString(entryNumber->number_->number_);
            return [[TONExecutionResultDecimal alloc] initWithValue:value];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntrySlice::ID) {
            auto entrySlice = tonlib_api::move_object_as<tonlib_api::tvm_stackEntrySlice>(entry);
            NSData *data = makeData(entrySlice->slice_->bytes_);
            return [[TONExecutionResultSlice alloc] initWithHEX:data];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryCell::ID) {
            auto entryCell = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryCell>(entry);
            NSData *data = makeData(entryCell->cell_->bytes_);
            return [[TONExecutionResultCell alloc] initWithHEX:data];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryTuple::ID) {
            auto entryTuple = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryTuple>(entry);
            NSMutableArray<TONExecutionStackValue> *enumeration = (NSMutableArray<TONExecutionStackValue> *)[[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < entryTuple->tuple_->elements_.size(); i++) {
                auto _element = tonlib_api::move_object_as<tonlib_api::tvm_StackEntry>(entryTuple->tuple_->elements_[i]);
                id _parsed = parser(_element);
                if (_element != nil) {
                    [enumeration addObject:_parsed];
                }
            }
            return [[TONExecutionResultEnumeration alloc] initWithEnumeration:enumeration];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryList::ID) {
            auto entryList = tonlib_api::move_object_as<tonlib_api::tvm_stackEntryList>(entry);
            NSMutableArray<TONExecutionStackValue> *enumeration = (NSMutableArray<TONExecutionStackValue> *)[[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < entryList->list_->elements_.size(); i++) {
                auto _element = tonlib_api::move_object_as<tonlib_api::tvm_StackEntry>(entryList->list_->elements_[i]);
                id _parsed = parser(_element);
                if (_element != nil) {
                    [enumeration addObject:_parsed];
                }
            }
            return [[TONExecutionResultEnumeration alloc] initWithEnumeration:enumeration];
        } else if (entry->get_id() == tonlib_api::tvm_stackEntryUnsupported::ID) {
            return nil;
        } else {
            return nil;
        };
    };

    return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::smc_runResult::ID) {
                auto runResult = tonlib_api::move_object_as<tonlib_api::smc_runResult>(object);
                
                NSMutableArray<TONExecutionStackValue> *stack = (NSMutableArray<TONExecutionStackValue> *)[[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < runResult->stack_.size(); i++) {
                    auto entry = tonlib_api::move_object_as<tonlib_api::tvm_StackEntry>(runResult->stack_[i]);
                    id parsed = parser(entry);
                    if (parsed != nil) {
                        [stack addObject:parsed];
                    }
                }
                
                TONExecutionResult *result = [[TONExecutionResult alloc] initWithCode:runResult->exit_code_
                                                                              stack:stack];

                [subscriber putNext: result];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];

        __block std::vector<tonlib_api::object_ptr<tonlib_api::tvm_StackEntry>> _arguments;
        [arguments enumerateObjectsUsingBlock:^(id<TONExecutionStackValue> obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TONExecutionResultCell class]]) {
                TONExecutionResultCell *cell = (TONExecutionResultCell *)obj;
                _arguments.push_back(
                    make_object<tonlib_api::tvm_stackEntryCell>(
                        make_object<tonlib_api::tvm_cell>(makeString(cell.hex))
                    )
                );
            } else if ([obj isKindOfClass:[TONExecutionResultSlice class]]) {
                TONExecutionResultSlice *cell = (TONExecutionResultSlice *)obj;
                _arguments.push_back(
                    make_object<tonlib_api::tvm_stackEntrySlice>(
                        make_object<tonlib_api::tvm_slice>(makeString(cell.hex))
                    )
                );
            } else {
                NSLog(@"Unsupported argument type: %@", [obj class]);
            }
        }];

        auto query = make_object<tonlib_api::smc_runGetMethod>(
            smartcontractID,
            make_object<tonlib_api::smc_methodIdName>(methodName.UTF8String),
            std::move(_arguments)
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)prepareQueryWithDestinationAddress:(NSString *)destinationAddress
                        initialAccountStateData:(NSData * _Nullable)initialAccountStateData
                        initialAccountStateCode:(NSData * _Nullable)initialAccountStateCode
                                           body:(NSData *)body
                                       randomId:(int64_t)randomId {
   return [self wrapSignal:[[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
       if ([self->_sendGramRandomIds containsObject:@(randomId)]) {
           [self->_sendGramRandomIds addObject:@(randomId)];
           
           return [[SBlockDisposable alloc] initWithBlock:^{
           }];
       }
        
        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        __weak TON *weakSelf = self;
        SQueue *queue = self->_queue;
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                [queue dispatch:^{
                    __strong TON *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [self->_sendGramRandomIds removeObject:@(randomId)];
                    }
                }];
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::query_info::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::query_info>(object);
                TONPreparedSendGramsQuery *preparedQuery = [[TONPreparedSendGramsQuery alloc] initWithQueryId:result->id_ validUntil:result->valid_until_ bodyHash:makeData(result->body_hash_) bocData:body];
                [subscriber putNext:preparedQuery];
                [subscriber putCompletion];
            } else {
                [subscriber putCompletion];
            }
        }];

        auto query = make_object<tonlib_api::raw_createQuery>(
            make_object<tonlib_api::accountAddress>(destinationAddress.UTF8String),
            makeString(initialAccountStateCode ?: [NSData new]),
            makeString(initialAccountStateData ?: [NSData new]),
            makeString(body)
        );
        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]]];
}

- (SSignal *)exportDecryptedKeyWithEncryptedKey:(GTTONKey *)encryptedKey
                               withUserPassword:(NSData *)userPassword {
    return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        NSData *publicKeyData = [encryptedKey.publicKey dataUsingEncoding:NSUTF8StringEncoding];
        if (publicKeyData == nil) {
            [subscriber putError:[[TONError alloc] initWithText:@"Error encoding UTF8 string in getWalletAccountAddressWithPublicKey"]];
            return [[SBlockDisposable alloc] initWithBlock:^{}];
        }

        uint64_t requestId = self->_nextRequestId;
        self->_nextRequestId += 1;
        
        self->_requestHandlers[@(requestId)] = [[TONRequestHandler alloc] initWithCompletion:^(tonlib_api::object_ptr<tonlib_api::Object> &object) {
            if (object->get_id() == tonlib_api::error::ID) {
                auto error = tonlib_api::move_object_as<tonlib_api::error>(object);
                [subscriber putError:[[TONError alloc] initWithText:[[NSString alloc] initWithUTF8String:error->message_.c_str()]]];
            } else if (object->get_id() == tonlib_api::exportedUnencryptedKey::ID) {
                auto result = tonlib_api::move_object_as<tonlib_api::exportedUnencryptedKey>(object);
                NSData *data = readSecureString(result->data_);
                [subscriber putNext: data];
                [subscriber putCompletion];
            } else {
                assert(false);
            }
        }];
        
        auto query = make_object<tonlib_api::exportUnencryptedKey>(
            make_object<tonlib_api::inputKeyRegular>(
                make_object<tonlib_api::key>(
                    makeString(publicKeyData),
                    makeSecureString(encryptedKey.encryptedSecretKey)
                ),
                makeSecureString(userPassword)
            )
        );

        self->_client->send({ requestId, std::move(query) });
        
        return [[SBlockDisposable alloc] initWithBlock:^{
        }];
    }] startOn:[SQueue mainQueue]] deliverOn:[SQueue mainQueue]];
}

@end
