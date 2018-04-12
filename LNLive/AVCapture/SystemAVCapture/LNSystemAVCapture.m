//
//  LNSystemAVCapture.m
//  LNLive
//
//  Created by 张立宁 on 2018/4/11.
//  Copyright © 2018年 ZLN. All rights reserved.
//

#import "LNSystemAVCapture.h"
#import <AVFoundation/AVFoundation.h>

@interface LNSystemAVCapture()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureDeviceInput *inputCamera;        // 当前正在使用的照相机
@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;        // 前置照相机
@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;         // 后置照相机

@property (nonatomic, strong) AVCaptureDeviceInput *recorder;           // 录音机

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;    // 视频输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;    // 音频输出

@end

@implementation LNSystemAVCapture

- (instancetype)init {
    if (self = [super init]) {
        [self onInit];
    }
    return self;
}

- (void)onInit {
    [self initCaptureDevice];
    [self initOutput];
    [self initCaptureSession];
}


/**
 初始化设备
 */
- (void)initCaptureDevice {
    self.inputCamera = self.frontCamera;
    [self recorder];
}

- (void)initOutput {
    
    dispatch_queue_t captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [self.videoOutput setSampleBufferDelegate:self queue:captureQueue];
    [self.videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoOutput setVideoSettings:@{
                                         (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                                         }];
    
    [self.audioOutput setSampleBufferDelegate:self queue:captureQueue];
}

- (void)initCaptureSession {
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession canAddInput:self.inputCamera]) {
        [self.captureSession addInput:self.inputCamera];
    }
    
    if ([self.captureSession canAddInput:self.recorder]) {
        [self.captureSession addInput:self.recorder];
    }
    
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    
    if ([self.captureSession canAddOutput:self.audioOutput]) {
        [self.captureSession addOutput:self.audioOutput];
    }
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}

#pragma mark - getter
- (AVCaptureDeviceInput *)frontCamera {
    if (!_frontCamera) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionFront) {
                _frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                break;
            }
        }
        if (!_frontCamera) {
            _frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
        }
    }
    return _frontCamera;
}

- (AVCaptureDeviceInput *)backCamera {
    if (!_backCamera) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if (device.position == AVCaptureDevicePositionFront) {
                _backCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                break;
            }
        }
        if (!_backCamera) {
            _backCamera = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
        }
    }
    return _backCamera;
}

- (AVCaptureDeviceInput *)recorder {
    if (!_recorder) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _recorder = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _recorder;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    }
    return _videoOutput;
}

- (AVCaptureAudioDataOutput *)audioOutput {
    if (!_audioOutput) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    }
    return _audioOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [AVCaptureSession new];
    }
    return _captureSession;
}

@end
