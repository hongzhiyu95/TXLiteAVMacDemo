//
//  TRTCCppWindow.h
//  TRTCDemo
//
//  Created by 于洪志 on 2022/1/14.
//  Copyright © 2022 rushanting. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCCppWindow : NSWindowController
-(void)loginWithRoomID:(NSString *)roomId userid:(NSString *)userid;
@end

NS_ASSUME_NONNULL_END
