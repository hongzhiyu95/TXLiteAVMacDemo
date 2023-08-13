//
//  TRTCUserManagerCpp.h
//  TRTCDemo
//
//  Created by einhorn on 2023/8/13.
//  Copyright © 2023 rushanting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCUserManagerCpp : NSObject
+(void)setRemoteUser:(const char *)userid;
@end

NS_ASSUME_NONNULL_END
