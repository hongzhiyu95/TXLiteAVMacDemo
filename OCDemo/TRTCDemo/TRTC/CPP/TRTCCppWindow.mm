//
//  TRTCCppWindow.m
//  TRTCDemo
//
//  Created by 于洪志 on 2022/1/14.
//  Copyright © 2022 rushanting. All rights reserved.
//

#import "TRTCCppWindow.h"
#import <iostream>
#import <TXLiteAVSDK_TRTC_Mac/cpp_interface/ITRTCCloud.h>
#import <TXLiteAVSDK_TRTC_Mac/TRTCCloud.h>
#import "GenerateTestUserSig.h"
#import "TXCaptureSourceWindowController.h"
#import "TRTCUserManager.h"
#define kButtonTitleAttr @{ NSForegroundColorAttributeName : [NSColor whiteColor] }


using namespace std;
//using namespace liteav;
static NSString * const AudioIcon[2] = {@"main_tool_audio_on", @"main_tool_audio_off"};
class  MyTRTCCoudAudioFrameCallBack : public liteav::ITRTCAudioFrameCallback{
private:
    int roomId;
    TRTCCppWindow *manager;
public:
    void onCapturedRawAudioFrame(liteav::TRTCAudioFrame* frame);
    void onLocalProcessedAudioFrame(liteav::TRTCAudioFrame* frame);
    void onPlayAudioFrame(liteav::TRTCAudioFrame* frame, const char* userId);
    void onMixedPlayAudioFrame(liteav::TRTCAudioFrame* frame);
    void onRenderVideoFrame(const char* userId, liteav::TRTCVideoStreamType streamType, liteav::TRTCVideoFrame* frame);
};
class  MyVideoRenderCallBack : public liteav::ITRTCVideoRenderCallback{
private:
    int roomId;
    TRTCCppWindow *manager;
public:
    void onRenderVideoFrame(const char* userId, liteav::TRTCVideoStreamType streamType, liteav::TRTCVideoFrame* frame);
};
class  MyTRTCCoudCallBack : public liteav::ITRTCCloudCallback{
private:
    int roomId;
    TRTCCppWindow *manager;
public:
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo);
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo);
    void onEnterRoom(int result);
    void onExitRoom(int reason);
    void onSwitchRole(TXLiteAVError errCode, const char* errMsg);
    void onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg);
    void onSwitchRoom(TXLiteAVError errCode, const char* errMsg);
    void onRemoteUserEnterRoom(const char* userId);
    void onRemoteUserLeaveRoom(const char* userId, int reason);
    void onUserVideoAvailable(const char* userId, bool available);
    void onUserSubStreamAvailable(const char* userId, bool available);
    void onUserAudioAvailable(const char* userId, bool available);
    void onFirstVideoFrame(const char* userId, const   liteav::TRTCVideoStreamType streamType, const int width, const int height);
    void onNetworkQuality( liteav::TRTCQualityInfo localQuality,  liteav::TRTCQualityInfo* remoteQuality, uint32_t remoteQualityCount);
    void onStatistics(const  liteav::TRTCStatistics& statis);
    void onUserVoiceVolume( liteav::TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume);
    void onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize);
    void onMissCustomCmdMsg(const char* userId, int32_t cmdID, int32_t errCode, int32_t missed);
    void onRecvSEIMsg(const char* userId, const uint8_t* message, uint32_t messageSize);
    
};
@interface TRTCCppWindow ()<NSWindowDelegate,TRTCCloudDelegate>
@property (weak) IBOutlet NSView *videoView;
@property (nonatomic, strong) TRTCUserManager *userManager;
@property(nonatomic,strong) TXCaptureSourceWindowController *captureSourceWindowController;
@property (strong ,nonatomic) NSMutableDictionary* remoteUserViewDic;
@end


@implementation TRTCCppWindow {
    
    MyTRTCCoudAudioFrameCallBack *_trtcCloudAudioFrameCallBack;
    MyVideoRenderCallBack *_videoRenderCallBack;
    MyTRTCCoudCallBack *_cloudDelegate;
    liteav:: ITRTCCloud *_trtc;
}


-(instancetype)initWithCoder:(NSCoder *)coder{
    return [super initWithCoder:coder];
}
-(void)loginWithRoomID:(NSString *)roomId userid:(NSString *)userid{
    _trtc = liteav::ITRTCCloud::getTRTCShareInstance();
    
    _trtcCloudAudioFrameCallBack = new MyTRTCCoudAudioFrameCallBack();
    _videoRenderCallBack = new MyVideoRenderCallBack();
    _cloudDelegate = new MyTRTCCoudCallBack();
    liteav:: TRTCParams params =  liteav::TRTCParams();
    params.role = liteav::TRTCRoleAnchor;
    params.roomId = [roomId intValue];
    
    params.sdkAppId = _SDKAppID;
    params.userId = [userid cStringUsingEncoding:NSUTF8StringEncoding];
    const char* userSig =  [[GenerateTestUserSig genTestUserSig:userid] cStringUsingEncoding:NSUTF8StringEncoding];
    params.userSig = userSig;
    _trtc->enterRoom(params,liteav::TRTCAppSceneLIVE);
    _trtc->startLocalPreview((__bridge void*)self.videoView);
    _trtc->startLocalAudio(liteav::TRTCAudioQualityMusic);
    _trtc->setAudioFrameCallback(_trtcCloudAudioFrameCallBack);
    _trtc->addCallback(_cloudDelegate);
    _trtc -> setLocalVideoRenderCallback(liteav::TRTCVideoPixelFormat_BGRA32, liteav::TRTCVideoBufferType_Buffer, _videoRenderCallBack);
    [TRTCCloud sharedInstance].delegate = self;
    self.userManager = [[TRTCUserManager alloc]initWithUserId:[NSString stringWithCString:params.userId encoding:NSUTF8StringEncoding]];
 //   _trtc -> getDeviceManager()->enableFollowingDefaultAudioDevice(<#TXMediaDeviceType type#>, <#bool enable#>)
//    RECT rect ;
//    rect.left = 0;
//    rect.right = 0;
//    rect.top = 0;
//    rect.bottom = 0;
//    TRTCScreenCaptureProperty ppt ;
//    ppt.enableCaptureMouse = true;
//    ppt.enableHighLight = true;
//    TRTCScreenCaptureSourceInfo info;
//    info.type  = TRTCScreenCaptureSourceTypeScreen;
//    info.sourceId =nullptr;
//    _trtc->selectScreenCaptureTarget(info, rect, ppt);
//    _trtc -> startScreenCapture(nullptr, TRTCVideoStreamTypeSub, nil);
//    self.captureSourceWindowController = [[TXCaptureSourceWindowController alloc] initWithTRTCCloud:nil];
}
-(void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
    NSLog(@"[YT]---ObjC callbak--onUserVideoAvailable");
    if (userId) {
        NSView *remoteRenderView = self.remoteUserViewDic [userId];
        if (available) {
            if (!remoteRenderView) {
                NSInteger index = self.remoteUserViewDic.allKeys.count;
                NSInteger line = 1;
              //  NSInteger curIndex = 0;
                if(index>5){
                    
                    index =0;
                    line = 2;
                }
                CGFloat kRenderViewWidth = self.window.contentView.frame.size.width/5;
                CGFloat kRenderViewHeight = (self.window.contentView.frame.size.width/5)/9*16;
                remoteRenderView = [[NSView alloc]initWithFrame:NSMakeRect(index*kRenderViewWidth, line*kRenderViewHeight, kRenderViewWidth, kRenderViewHeight)];
                [self.videoView addSubview:remoteRenderView];
                self.remoteUserViewDic[userId] = remoteRenderView;
                _trtc->startRemoteView([userId UTF8String],  liteav::TRTCVideoStreamTypeBig, (__bridge void *)remoteRenderView);
            }
          
        }else{
            if (remoteRenderView){
                _trtc->stopRemoteView([userId UTF8String], liteav::TRTCVideoStreamTypeBig);
                [remoteRenderView removeFromSuperview];
                self.remoteUserViewDic[userId] = nil;
                [self updateRemoteViews];
            }
        }
    }
}
-(void)updateRemoteViews{
    if (self.remoteUserViewDic.allValues.count>0) {
        NSInteger curIndex = 0;
        NSInteger curLine = 1;
        CGFloat kRenderViewWidth = self.window.contentView.frame.size.width/5;
        CGFloat kRenderViewHeight = (self.window.contentView.frame.size.width/5)/9*16;
        for (NSView *renderView in self.remoteUserViewDic.allValues) {
            if(curIndex==5){
                curLine  = 2;
                curIndex = 0;
            }
            [renderView setFrame:NSMakeRect(curIndex*kRenderViewWidth, curLine*kRenderViewHeight, kRenderViewWidth, kRenderViewHeight)];
            curIndex ++;
            
        }
    }
   
    
}
#pragma mark 静音

- (IBAction)muteLocalAudioClicked:(NSButton*)button {
    button.image = [NSImage imageNamed:AudioIcon[button.state]];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:@[@"静音", @"解除静音"][button.state]
                                                             attributes:kButtonTitleAttr];
    _trtc->muteLocalAudio(button.state);
    
}
#pragma mark 屏幕分享点击
- (IBAction)startScreenCapture:(id)sender {
    __weak TRTCCppWindow *wself = self;
    self.captureSourceWindowController = [[TXCaptureSourceWindowController alloc] initWithTRTCCloud:nil];
    liteav::SIZE tbSize;
    tbSize.width = 180;
    tbSize.height = 180;
    liteav::SIZE icSize;
    icSize.width = 180;
    icSize.height = 180;
    liteav:: ITRTCScreenCaptureSourceList *sourceList = _trtc->getScreenCaptureSources(tbSize, icSize);
    for (int index = 0; index < sourceList->getCount() ;index ++) {
        liteav::TRTCScreenCaptureSourceInfo source = sourceList->getSourceInfo(index);
        cout<<"---YT--"<<source.sourceId<<endl;
    }
    self.captureSourceWindowController.onSelectSourceIndex = ^(int index) {
        __strong TRTCCppWindow *self = wself;
        if (!self) return;
        _trtc->stopScreenCapture();
   
        liteav::TRTCScreenCaptureSourceInfo source;
        source = sourceList->getSourceInfo(index);
        cout<<"---YT--"<<source.sourceId<<endl;
        liteav::TRTCScreenCaptureProperty ppt ;
        ppt.enableCaptureMouse = true;
        ppt.enableHighLight = true;
        liteav::RECT rect ;
        rect.left = 0;
        rect.right = 0;
        rect.top = 0;
        rect.bottom = 0;
        if (source.sourceId!=NULL && source.type != TRTCScreenCaptureSourceTypeUnknown) {
            if (source.type == TRTCScreenCaptureSourceTypeWindow) {
                self->_trtc->selectScreenCaptureTarget(source, rect, ppt);
            } else if (source.type == TRTCScreenCaptureSourceTypeScreen) {
                self->_trtc->selectScreenCaptureTarget(source, rect, ppt);
            }
            if (self.captureSourceWindowController.usesBigStream) {
                self->_trtc->startScreenCapture(nullptr, liteav::TRTCVideoStreamTypeBig, nullptr);
            } else {
                self->_trtc->startScreenCapture(nullptr, liteav::TRTCVideoStreamTypeSub, nullptr);
            }
        }
        [self.window endSheet:self.captureSourceWindowController.window];
        [self.captureSourceWindowController.window close];
    };
    NSRect frame = self.window.frame;
    NSWindow *window = self.captureSourceWindowController.window;
    [window setFrame:frame display:YES animate:NO];
    [self.window beginSheet:window completionHandler:nil];
    [self.window addChildWindow:window ordered:NSWindowAbove];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    _remoteUserViewDic = [NSMutableDictionary dictionary];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void)windowWillClose:(NSNotification *)notification{
    _trtc->stopLocalAudio();
    _trtc->exitRoom();
    _trtc->destroyTRTCShareInstance();
    delete  _trtcCloudAudioFrameCallBack;
}
#pragma mark -trtcCallBack回调处理
void MyTRTCCoudCallBack::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) {
 
}

void MyTRTCCoudCallBack::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) {
  
}

void MyTRTCCoudCallBack::onEnterRoom(int result) {
  
}

void MyTRTCCoudCallBack::onExitRoom(int reason) {
   
}

void MyTRTCCoudCallBack::onSwitchRole(TXLiteAVError errCode, const char* errMsg) {
   
}

void MyTRTCCoudCallBack::onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) {
 
}

void MyTRTCCoudCallBack::onSwitchRoom(TXLiteAVError errCode, const char* errMsg) {
  
}

void MyTRTCCoudCallBack::onRemoteUserEnterRoom(const char* userId) {
 
}

void MyTRTCCoudCallBack::onRemoteUserLeaveRoom(const char* userId, int reason) {
   
}

void MyTRTCCoudCallBack::onUserVideoAvailable(const char* userId, bool available) {
    NSLog(@"[YT]---cpp callbak--onUserVideoAvailable");
   
}

void MyTRTCCoudCallBack::onUserSubStreamAvailable(const char* userId, bool available) {
    
}

void MyTRTCCoudCallBack::onUserAudioAvailable(const char* userId, bool available) {
   
}

void MyTRTCCoudCallBack::onFirstVideoFrame(const char* userId, const  liteav::TRTCVideoStreamType streamType, const int width, const int height) {
  
}

void MyTRTCCoudCallBack::onNetworkQuality( liteav::TRTCQualityInfo localQuality,  liteav::TRTCQualityInfo* remoteQuality, uint32_t remoteQualityCount) {
    
 
}

void MyTRTCCoudCallBack::onStatistics(const  liteav::TRTCStatistics& statics) {
 
}

void MyTRTCCoudCallBack::onUserVoiceVolume( liteav::TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume) {

}

void MyTRTCCoudCallBack::onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize) {

}

void MyTRTCCoudCallBack::onMissCustomCmdMsg(const char* userId, int32_t cmdID, int32_t errCode, int32_t missed) {
 
}

void MyTRTCCoudCallBack::onRecvSEIMsg(const char* userId, const uint8_t* message, uint32_t messageSize) {
    NSData *msgData = [[NSData alloc] initWithBytes:message length:messageSize];
 
}


@end
void MyTRTCCoudAudioFrameCallBack::onLocalProcessedAudioFrame(liteav::TRTCAudioFrame *frame){
    cout<<"onLocalProcessedAudioFrame---"<<endl;
}
void MyTRTCCoudAudioFrameCallBack::onCapturedRawAudioFrame(liteav::TRTCAudioFrame* frame){
    
}
void MyTRTCCoudAudioFrameCallBack::onPlayAudioFrame(liteav::TRTCAudioFrame* frame, const char* userId){
    
}
void MyTRTCCoudAudioFrameCallBack::onMixedPlayAudioFrame(liteav::TRTCAudioFrame* frame){
    
}
void MyVideoRenderCallBack::onRenderVideoFrame(const char *userId, liteav::TRTCVideoStreamType streamType, liteav::TRTCVideoFrame *frame){
    if (streamType == TRTCVideoStreamTypeSub) {
        cout<<"onRenderVideoFrame---"<<endl;
    }
}


//MyTRTCCoudCallBack::MyTRTCCoudCallBack(int roomid, TRTCCppWindow *manage){
//    roomid = roomid;
//    manage = manage;
//}

