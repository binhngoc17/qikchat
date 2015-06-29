//
//  Literals.h
//  QikAChat
//
//  Created by Ram Bhawan Chauhan on 28/06/15.
//  Copyright (c) 2015 RAMC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#include <assert.h>
#define DASSERT(e)                     assert(e)
#else
#define DASSERT(e)
#endif

@interface Literals : NSObject

#define KDATABASE_CURRENT_VERSION @"1.0.0" // change if released

extern NSString *const kXMPPmyJID;
extern NSString *const kXMPPmyPassword;

#define kChatTimestampFormat		@"yyyyMMddHHmmssSSS"
#define kMessageTimestampFormat		@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

#define kOTRChatStatePausedTimeout 5
#define kOTRChatStateInactiveTimeout 120

#define TAG_BODY @"body"
#define TAG_MESSAGE @"message"
#define TAG_TYPE @"type"
#define KTAG_PROPERTIES @"properties"
#define KTAG_PROPERTY  @"property"
#define KTAG_NAME       @"name"
#define KTAG_VALUE      @"value"
#define KTAG_EXTENSION  @"extension"
#define KTAG_HRESURL    @"hresURL"
#define TAG_LAT @"lat"
#define TAG_LNG @"lng"
#define KTAG_LRESURL    @"lresURL"
#define KTAG_MESSAGETYPE @"messageType"
#define KTAG_SIZE        @"size"
#define KTAG_STRING      @"string"
#define KTAG_LONG        @"long"

@end

