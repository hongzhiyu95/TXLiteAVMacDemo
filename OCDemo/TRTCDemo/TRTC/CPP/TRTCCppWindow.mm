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
#import "HoverView.h"
#import "TXCppRenderView.h"
#define kButtonTitleAttr @{ NSForegroundColorAttributeName : [NSColor grayColor] }


using namespace std;
//using namespace liteav;
static NSString * const AudioIcon[2] = {@"main_tool_audio_on", @"main_tool_audio_off"};
static NSString * const VideoIcon[2] = {@"main_tool_video_on", @"main_tool_video_off"};
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
@interface TXLiteAVDemoDeviceInfo : NSObject
@property (copy ,nonatomic) NSString* deviceID;
@property (copy ,nonatomic) NSString* deviceName;
@end

@interface TRTCCppWindow ()<NSWindowDelegate,TRTCCloudDelegate,NSTableViewDelegate,NSTableViewDataSource>



@property (nonatomic, strong) TRTCUserManager *userManager;
@property(nonatomic,strong) TXCaptureSourceWindowController *captureSourceWindowController;
@property (strong ,nonatomic) NSMutableDictionary* remoteUserViewDic;
@property (weak) IBOutlet NSButton *micDeviceButton;

@property (strong) IBOutlet NSTableView *audioSelectView;
@property (strong) IBOutlet NSTableView *videoSelectView;
@property(nonatomic,strong) NSMutableArray *micArr;
@property(nonatomic,strong) NSMutableArray *speakerArr;
@property(nonatomic,strong) NSMutableArray *cameraArr;
@property (strong)IBOutlet TXCppRenderView *localVideoView;


@end
@implementation TXLiteAVDemoDeviceInfo



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
  
        [_localVideoView setFrame:NSMakeRect(0, 0, self.window.contentView.frame.size.width, self.window.contentView.frame.size.width*9/16)];
//    [self.window.contentView addSubview:_localVideoView];
    _trtc->enterRoom(params,liteav::TRTCAppSceneLIVE);
  //  self.localVideoView = [TXRenderView renderViewWithUserId:userid isMe:YES];
    _trtc->startLocalPreview((__bridge liteav:: TXView )self.localVideoView);
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
   // [[[TRTCCloud sharedInstance]getDeviceManager]getDevicesList:TXMediaDeviceTypeAudioInput];
//    self.micArr = [self _configDeviceArrWithCppDeviceList:_trtc->getDeviceManager()->getDevicesList(liteav::TXMediaDeviceTypeMic)];
//    self.speakerArr = [self _configDeviceArrWithCppDeviceList:_trtc->getDeviceManager()->getDevicesList(liteav::TXMediaDeviceTypeSpeaker)];
    
    [self _configPopUpMenu:_audioSelectView];
    [self _configPopUpMenu:_videoSelectView];
    self.audioSelectView.frame = CGRectMake(self.audioSelectView.frame.origin.x, self.audioSelectView.frame.origin.y, self.audioSelectView.frame.size.width, (self.micArr.count+self.speakerArr.count+1)*26);
    self.videoSelectView.frame = CGRectMake(self.videoSelectView.frame.origin.x, self.videoSelectView.frame.origin.y, self.videoSelectView.frame.size.width, (self.micArr.count+1)*26);
    
}
-(NSMutableArray *)_configDeviceArrWithCppDeviceList:(liteav::ITXDeviceCollection*)cppDeciveCollection{
    NSMutableArray * deviceArray = [NSMutableArray array];
    if (cppDeciveCollection->getCount()<=0) {
        return  nil;
    }
    for(int i=0;i<cppDeciveCollection->getCount();i++){
        TXLiteAVDemoDeviceInfo *info = [[TXLiteAVDemoDeviceInfo alloc]init];
        info.deviceID = [NSString stringWithUTF8String:cppDeciveCollection->getDevicePID(i)];
        info.deviceName = [NSString stringWithUTF8String:cppDeciveCollection->getDeviceName(i)];
        [deviceArray addObject:info];
    }
    return deviceArray;
}
-(void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
    NSLog(@"[YT]---ObjC callbak--onUserVideoAvailable");
    if (userId) {
        TXCppRenderView *remoteRenderView = self.remoteUserViewDic [userId];
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
                remoteRenderView = [[TXCppRenderView alloc]initWithFrame:NSMakeRect(index*kRenderViewWidth, line*kRenderViewHeight, kRenderViewWidth, kRenderViewHeight)];
                [self.localVideoView addSubview:remoteRenderView];
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
        for (TXCppRenderView *renderView in self.remoteUserViewDic.allValues) {
            if(curIndex==5){
                curLine  = 2;
                curIndex = 0;
            }
            [renderView setFrame:NSMakeRect(curIndex*kRenderViewWidth, curLine*kRenderViewHeight, kRenderViewWidth, kRenderViewHeight)];
            curIndex ++;
            
        }
    }
   
    
}
#pragma  mark -配置弹出式列表
- (void)_configPopUpMenu:(NSTableView *)tableView  {
    [tableView setBackgroundColor:[NSColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:1.0]];
    [[tableView enclosingScrollView] setDrawsBackground:NO];
    tableView.delegate = self;
    tableView.dataSource = self;
   // tableView.hidden = YES;
    [tableView enclosingScrollView].hidden = YES;
    [tableView enclosingScrollView].borderType = NSNoBorder;
    tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
}
#pragma mark 静音

- (IBAction)muteLocalAudioClicked:(NSButton*)button {
    button.image = [NSImage imageNamed:AudioIcon[button.state]];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:@[@"静音", @"解除静音"][button.state]
                                                             attributes:kButtonTitleAttr];
    _trtc->muteLocalAudio(button.state);
    
}
- (void)mouseDown:(NSEvent *)event {
    [self.videoSelectView enclosingScrollView].hidden = YES;
    [self.audioSelectView enclosingScrollView].hidden = YES;
}
- (IBAction)onClickCameraSource:(id)sender {
    [self.videoSelectView enclosingScrollView].hidden = ![self.videoSelectView enclosingScrollView].hidden;
    if ([self.videoSelectView enclosingScrollView].hidden == NO) {
        [self.audioSelectView enclosingScrollView].hidden = YES;
    }
    [self.cameraArr removeAllObjects];
    self.cameraArr = [self _configDeviceArrWithCppDeviceList:_trtc->getDeviceManager()->getDevicesList(liteav::TXMediaDeviceTypeCamera)];
    [self.cameraArr insertObject:@"选择摄像头" atIndex:0];
    [self.videoSelectView reloadData];
}
- (IBAction)micDeviceButtonClicked:(NSButton *)button {
    [self.audioSelectView enclosingScrollView].hidden = ![self.audioSelectView enclosingScrollView].hidden;
    if ([self.audioSelectView enclosingScrollView].hidden == NO) {
        [self.videoSelectView enclosingScrollView].hidden = YES;
    }
    [self.micArr removeAllObjects];
    [self.speakerArr removeAllObjects];
//    self.micArr = [NSMutableArray arrayWithArray:[self.trtcEngine getMicDevicesList]];
//    self.speakerArr = [NSMutableArray arrayWithArray:[self.trtcEngine getSpeakerDevicesList]];
    self.micArr = [self _configDeviceArrWithCppDeviceList:_trtc->getDeviceManager()->getDevicesList(liteav::TXMediaDeviceTypeMic)];
    self.speakerArr = [self _configDeviceArrWithCppDeviceList:_trtc->getDeviceManager()->getDevicesList(liteav::TXMediaDeviceTypeSpeaker)];
    [self.micArr insertObject:@"选择麦克风" atIndex:0];
    [self.speakerArr insertObject:@"选择扬声器" atIndex:0];
    [self.audioSelectView reloadData];
}
- (IBAction)onClickVideoMute:(NSButton *)button {
    button.image = [NSImage imageNamed:VideoIcon[button.state]];
    button.attributedTitle = [[NSAttributedString alloc] initWithString:@[@"停止视频", @"开启视频"][button.state]
                                                             attributes:kButtonTitleAttr];
    _trtc->muteLocalVideo(liteav::TRTCVideoStreamTypeBig,  button.state != NSControlStateValueOn);
}
- (IBAction)onClickCameraSourceTableItem:(id)sender {
    NSTableView *tableView = sender;
    NSInteger row = [tableView selectedRow];
    if (row < 0) return;
    NSMutableArray *cameraArr = [NSMutableArray arrayWithArray:self.cameraArr];
    [cameraArr addObject:@"视频设置"];
    id object = [cameraArr objectAtIndex:row];
    if ([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]])  {
        TXLiteAVDemoDeviceInfo *source = (TXLiteAVDemoDeviceInfo *)object;
        if ([self.cameraArr containsObject:object] ) {
            _trtc->getDeviceManager()->setCurrentDevice(liteav::TXMediaDeviceTypeMic, [source.deviceID UTF8String]);
        }
    }
    [self.audioSelectView enclosingScrollView].hidden = YES;
    [self.videoSelectView enclosingScrollView].hidden = YES;
}
- (IBAction)onClickAudioSourceTableItem:(id)sender{
    NSTableView *tableView = sender;
    NSInteger row = [tableView selectedRow];
    NSMutableArray *audioArr = [NSMutableArray arrayWithArray:self.micArr];
    [audioArr addObjectsFromArray:self.speakerArr];
    [audioArr addObject:@"音频设置"];
    id object = [audioArr objectAtIndex:row];
    if ([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]) {
        //选择默认设备
        TXLiteAVDemoDeviceInfo *source = (TXLiteAVDemoDeviceInfo *)object;
        if ([self.micArr containsObject:object] ) {
            _trtc->getDeviceManager()->setCurrentDevice(liteav::TXMediaDeviceTypeMic, [source.deviceID UTF8String]);
        }
        else if ([self.speakerArr containsObject:object]){
            _trtc->getDeviceManager()->setCurrentDevice(liteav::TXMediaDeviceTypeSpeaker, [source.deviceID UTF8String]);
        }
    }
//    else if ([object isKindOfClass:[NSString class]] && [object isEqualToString:@"音频设置"]){
//        if (self.onAudioSettingsButton) {
//            self.onAudioSettingsButton();
//        }
//    }
    [self.audioSelectView enclosingScrollView].hidden = YES;
    [self.videoSelectView enclosingScrollView].hidden = YES;
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
        if (self.captureSourceWindowController.isloopback) {
            _trtc->startSystemAudioLoopback();
        }
        else{
            _trtc->stopSystemAudioLoopback();
        }
        if (source.sourceId!=nullptr  && source.type != TRTCScreenCaptureSourceTypeUnknown) {
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
// 判断是否是当前使用的扬声器
-(BOOL)isSelectSpeakerDevice:(NSString *)deviceId{
   // return [[TRTC getCurrentMicDevice].deviceId isEqualToString:deviceId];
    liteav::ITXDeviceInfo *info =_trtc->getDeviceManager()->getCurrentDevice(liteav::TXMediaDeviceTypeSpeaker);
    return [deviceId isEqualToString:[NSString stringWithUTF8String:info->getDevicePID()]];
  
}
// 判断是否是当前使用的麦克
-(BOOL)isSelectedMicDevice:(NSString *)deviceId{
   // return [[TRTC getCurrentMicDevice].deviceId isEqualToString:deviceId];
    liteav::ITXDeviceInfo *info =_trtc->getDeviceManager()->getCurrentDevice(liteav::TXMediaDeviceTypeMic);
    return [deviceId isEqualToString:[NSString stringWithUTF8String:info->getDevicePID()]];
   // return false;
}

// 判断是否是当前使用的摄像头
-(BOOL)isSelectedCameraDevice:(NSString *)deviceId{
  //  return [deviceId isEqualToString: [self.trtcEngine getCurrentCameraDevice].deviceId];
    liteav::ITXDeviceInfo *info =_trtc->getDeviceManager()->getCurrentDevice(liteav::TXMediaDeviceTypeCamera);
    return [deviceId isEqualToString:[NSString stringWithUTF8String:info->getDevicePID()]];
    return false;
}

#pragma mark -设备列表
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.audioSelectView) {
        return self.micArr.count + self.speakerArr.count + 1;
    } else {
        return self.cameraArr.count + 1;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 26;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (tableView == self.audioSelectView) {
        NSTableCellView *view;
        if (row < self.micArr.count) {
            id object =  self.micArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                view = [tableView  makeViewWithIdentifier:@"SelectMicRow" owner:self];
                view.textField.stringValue = object;
                view.textField.textColor = [NSColor whiteColor];
            }
            else if([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]){
                view = [tableView makeViewWithIdentifier:@"MicDeviceRow" owner:self];
                view.textField.stringValue = ((TXLiteAVDemoDeviceInfo *)object).deviceName;
                view.imageView.hidden = ![self isSelectedMicDevice:((TXLiteAVDemoDeviceInfo *)object).deviceID];
                view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
                [view setHover];
            }
            if (row == self.micArr.count - 1) {
                NSView *bottomLine = [[NSView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
                bottomLine.wantsLayer = YES;
                bottomLine.layer.backgroundColor = [NSColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0].CGColor;
                [view addSubview:bottomLine];
            }
        }
        else if(row < self.micArr.count + self.speakerArr.count){
            id object = self.speakerArr[row - self.micArr.count];
            if ([object isKindOfClass:[NSString class]]) {
                view = [tableView  makeViewWithIdentifier:@"SelectSpeakerRow" owner:self];
                view.textField.stringValue = object;
                view.textField.textColor = [NSColor whiteColor];
            }
            else if([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]){
                view = [tableView makeViewWithIdentifier:@"SpeakerDeviceRow" owner:self];
                view.textField.stringValue = ((TXLiteAVDemoDeviceInfo *)object).deviceName;
                view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];;
                view.imageView.hidden = ![self isSelectSpeakerDevice:((TXLiteAVDemoDeviceInfo *)object).deviceID];
                [view setHover];
            }
            if ((row - self.micArr.count) == self.speakerArr.count - 1) {
                NSView *bottomLine = [[NSView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
                bottomLine.wantsLayer = YES;
                bottomLine.layer.backgroundColor = [NSColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0].CGColor;
                [view addSubview:bottomLine];
            }
        }
        else{
            view = [tableView makeViewWithIdentifier:@"AudioSettingRow" owner:self];
            view.textField.stringValue = @"音频设置";
            view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];;
            [view setHover];
        }
        return view;
    } else {
        NSTableCellView *view;
        if (row < self.cameraArr.count) {
            id object =  self.cameraArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                view = [tableView  makeViewWithIdentifier:@"SelectVideoRow" owner:self];
                view.textField.stringValue = object;
                view.textField.textColor = [NSColor whiteColor];
            }
            else if([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]){
                view = [tableView makeViewWithIdentifier:@"VideoDeviceRow" owner:self];
                view.textField.stringValue = ((TXLiteAVDemoDeviceInfo *)object).deviceName;
                view.imageView.hidden = ![self isSelectedCameraDevice:((TXLiteAVDemoDeviceInfo *)object).deviceID];
                view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
                [view setHover];
            }
            if (row == self.cameraArr.count - 1) {
                NSView *bottomLine = [[NSView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
                bottomLine.wantsLayer = YES;
                bottomLine.layer.backgroundColor = [NSColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1.0].CGColor;
                [view addSubview:bottomLine];
            }
        }
        else{
            view = [tableView makeViewWithIdentifier:@"VideoSettingRow" owner:self];
            view.textField.stringValue = @"视频设置";
            view.textField.textColor = [NSColor colorWithRed:0.64 green:0.64 blue:0.64 alpha:1.0];
            [view setHover];
        }
        return view;
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (tableView == self.audioSelectView) {
        if (row < self.micArr.count) {
            id object =  self.micArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                return NO;
            }
            else if([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]){
                return YES;
            }
        }
        else if(row < self.micArr.count + self.speakerArr.count){
            id object = self.speakerArr[row - self.micArr.count];
            if ([object isKindOfClass:[NSString class]]) {
                return NO;
            }
            else if([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]){
                return YES;
            }
        }
        return YES;
    }
    else{
        if (row < self.cameraArr.count) {
            id object =  self.micArr[row];
            if ([object isKindOfClass:[NSString class]]) {
                return NO;
            }
            else if([object isKindOfClass:[TXLiteAVDemoDeviceInfo class]]){
                return YES;
            }
        }
        return YES;
    }
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

