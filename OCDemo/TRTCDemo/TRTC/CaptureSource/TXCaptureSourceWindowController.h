//
//  TXCaptureSourceViewController.h
//  TXLiteAVMacDemo
//
//  Created by shengcui on 2018/10/24.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN
@class TRTCCloud;
@interface TXCaptureSourceWindowController : NSWindowController

@property (weak, nonatomic) TRTCCloud *engine;
@property (copy, nonatomic) void(^onSelectSource)(id  _Nullable);
@property (copy, nonatomic) void(^onSelectSourceIndex)(int index);
@property (nonatomic, readonly) BOOL usesBigStream;
@property (nonatomic, readonly) BOOL isloopback;
- (instancetype)initWithTRTCCloud:(TRTCCloud *)engine;

@end

NS_ASSUME_NONNULL_END
