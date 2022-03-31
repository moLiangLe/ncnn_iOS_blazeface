//
//  ViewController.m
//  ncnn_iOS_blazeface
//
//  Created by zhou on 2022/3/31.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) UIImageView *ncnnView;

@property (nonatomic, strong) UIImageView *videoView;

@property (nonatomic, strong) AVCaptureSession *captureSession;

//输入设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;

//输入流
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;

//照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;

//视频帧流
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    
    // Do any additional setup after loading the view.
}

- (void)configView {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.ncnnView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 80, width/4, height/4)];
    [self.view addSubview:self.ncnnView];
    
    self.videoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:self.videoView];
}

- (void)configVideo {
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    UIImage* image = [self imageFromSampleBuffer:sampleBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ncnnView.image = image;
        self.videoView.image = image;
    });
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 如果不加这个后面 context 可能会创建失败
    if (width <= 0 || height <= 0) {
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        return nil;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGImageByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    if (newContext) {
        CGImageRef newImage = CGBitmapContextCreateImage(newContext);
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
        // 需要的图片帧数据
        UIImage *image = [UIImage imageWithCGImage:newImage scale:1 orientation:UIImageOrientationUp];
        CGImageRelease(newImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        return image;
    } else {
        CGColorSpaceRelease(colorSpace);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        return nil;
    }

    return nil;
}


@end
