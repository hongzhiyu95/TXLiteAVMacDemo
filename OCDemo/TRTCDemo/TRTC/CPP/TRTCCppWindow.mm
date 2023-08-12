//
//  TRTCCppWindow.m
//  TRTCDemo
//
//  Created by 于洪志 on 2022/1/14.
//  Copyright © 2022 rushanting. All rights reserved.
//

#import "TRTCCppWindow.h"
#include <iostream>
#include <TXLiteAVSDK_TRTC_Mac/cpp_interface/ITRTCCloud.h>
//#include "TRTCCloudDef.h"
#include "GenerateTestUserSig.h"
//#import "TXCaptureSourceWindowController.h"

using namespace liteav;
using namespace std;
//using namespace liteav;
class  MyTRTCCoudCallBack : public ITRTCAudioFrameCallback{
private:
    int roomId;
    TRTCCppWindow *manager;
public:
    void onCapturedRawAudioFrame(TRTCAudioFrame* frame);
    void onLocalProcessedAudioFrame(TRTCAudioFrame* frame);
    void onPlayAudioFrame(TRTCAudioFrame* frame, const char* userId);
    void onMixedPlayAudioFrame(TRTCAudioFrame* frame);
    void onRenderVideoFrame(const char* userId, TRTCVideoStreamType streamType, TRTCVideoFrame* frame);
};
class  MyVideoRenderCallBack : public ITRTCVideoRenderCallback{
private:
    int roomId;
    TRTCCppWindow *manager;
public:
    void onRenderVideoFrame(const char* userId, TRTCVideoStreamType streamType, TRTCVideoFrame* frame);
};
@interface TRTCCppWindow ()
@property (weak) IBOutlet NSView *videoView;
//@property(nonatomic,strong) TXCaptureSourceWindowController *captureSourceWindowController;
@end

@implementation TRTCCppWindow {
    ITRTCCloud *_trtc;
    MyTRTCCoudCallBack *_trtcCloudCallBack;
    MyVideoRenderCallBack *_videoRenderCallBack;
}


-(instancetype)initWithCoder:(NSCoder *)coder{
    return [super initWithCoder:coder];
}
-(void)loginWithRoomID:(NSString *)roomId userid:(NSString *)userid{
    _trtc = ITRTCCloud::getTRTCShareInstance();
    _trtcCloudCallBack = new MyTRTCCoudCallBack();
    _videoRenderCallBack = new MyVideoRenderCallBack();
    TRTCParams params =  liteav::TRTCParams();
    params.role = TRTCRoleAnchor;
    params.roomId = [roomId intValue];
    
    params.sdkAppId = _SDKAppID;
    params.userId = [userid cStringUsingEncoding:NSUTF8StringEncoding];
    const char* userSig =  [[GenerateTestUserSig genTestUserSig:userid] cStringUsingEncoding:NSUTF8StringEncoding];
    params.userSig = userSig;
    _trtc->enterRoom(params,TRTCAppSceneLIVE);
    _trtc->startLocalPreview((__bridge void*)self.videoView);
    _trtc->startLocalAudio(TRTCAudioQualityMusic);
    _trtc->setAudioFrameCallback(_trtcCloudCallBack);

    _trtc -> setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, _videoRenderCallBack);
 //   _trtc -> getDeviceManager()->enableFollowingDefaultAudioDevice(<#TXMediaDeviceType type#>, <#bool enable#>)
    RECT rect ;
    rect.left = 0;
    rect.right = 0;
    rect.top = 0;
    rect.bottom = 0;
    TRTCScreenCaptureProperty ppt ;
    ppt.enableCaptureMouse = true;
    ppt.enableHighLight = true;
    TRTCScreenCaptureSourceInfo info;
    info.type  =TRTCScreenCaptureSourceTypeScreen;
    _trtc->selectScreenCaptureTarget(info, rect, ppt);
    _trtc -> startScreenCapture(nullptr, TRTCVideoStreamTypeSub, nil);
//    self.captureSourceWindowController = [[TXCaptureSourceWindowController alloc] initWithTRTCCloud:nil];
}

//- (IBAction)startScreenCapture:(id)sender {
//    __weak TRTCCppWindow *wself = self;
//    self.captureSourceWindowController.onSelectSource = ^(TRTCScreenCaptureSourceInfo * _Nonnull source) {
//
//    };
//}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void)close{

    _trtc->destroyTRTCShareInstance();
    delete  _trtcCloudCallBack;
    
}

@end
void MyTRTCCoudCallBack::onLocalProcessedAudioFrame(TRTCAudioFrame *frame){
    cout<<"onLocalProcessedAudioFrame---"<<endl;
}
void MyTRTCCoudCallBack::onCapturedRawAudioFrame(TRTCAudioFrame* frame){
    
}
void MyTRTCCoudCallBack::onPlayAudioFrame(TRTCAudioFrame* frame, const char* userId){
    
}
void MyTRTCCoudCallBack::onMixedPlayAudioFrame(TRTCAudioFrame* frame){
    
}
void MyVideoRenderCallBack::onRenderVideoFrame(const char *userId, TRTCVideoStreamType streamType, TRTCVideoFrame *frame){
    if (streamType == TRTCVideoStreamTypeSub) {
        cout<<"onRenderVideoFrame---"<<endl;
    }
}
//MyTRTCCoudCallBack::MyTRTCCoudCallBack(int roomid, TRTCCppWindow *manage){
//    roomid = roomid;
//    manage = manage;
//}

