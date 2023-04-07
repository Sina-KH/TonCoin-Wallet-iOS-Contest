#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#else
#import <Foundation/Foundation.h>
#endif

//! Project version number for SSignalKit.
FOUNDATION_EXPORT double SSignalKitVersionNumber;

//! Project version string for SSignalKit.
FOUNDATION_EXPORT const unsigned char SSignalKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SSignalKit/PublicHeader.h>

#import "SAtomic.h"
#import "SBag.h"
#import "SSignal.h"
#import "SSubscriber.h"
#import "SDisposable.h"
#import "SDisposableSet.h"
#import "SBlockDisposable.h"
#import "SMetaDisposable.h"
#import "SSignal+Single.h"
#import "SSignal+Mapping.h"
#import "SSignal+Multicast.h"
#import "SSignal+Meta.h"
#import "SSignal+Accumulate.h"
#import "SSignal+Dispatch.h"
#import "SSignal+Catch.h"
#import "SSignal+SideEffects.h"
#import "SSignal+Combine.h"
#import "SSignal+Timing.h"
#import "SSignal+Take.h"
#import "SSignal+Pipe.h"
#import "SMulticastSignalManager.h"
#import "STimer.h"
#import "SVariable.h"
