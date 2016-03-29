//
//  TCTQRCodeViewController.m
//  QRCode
//
//  Created by TCT on 16/3/28.
//  Copyright © 2016年 TCT. All rights reserved.
//

#import "TCTQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface TCTQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic ,weak) AVCaptureSession *session;
@property (nonatomic ,weak) AVCaptureVideoPreviewLayer *prewLayer;
@end

#define TCTScreenWidth self.view.bounds.size.width
#define TCTScreenHeight self.view.bounds.size.height

@implementation TCTQRCodeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置navigationBar
    [self p_setupNavigationBar];
    
    // 二维码扫描
    [self p_scanQRCode];
}

#pragma mark - private method
- (void)p_setupNavigationBar {
    self.title = @"扫一扫";
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    UIBarButtonItem *photoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(p_obtainQRCodeFromPhoto)];

    self.navigationItem.rightBarButtonItem = photoButtonItem;
}

- (void)p_scanQRCode {
    NSLog(@"扫描二维码");
    // 创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    _session = session;
    
    // 添加输入设备(数据从摄像头输入)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [session addInput:input];
    
    // 添加输出数据(元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    // 设置输出元数据的类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 添加扫描图层
    AVCaptureVideoPreviewLayer *prewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prewLayer.frame = self.view.bounds;
    prewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:prewLayer];
    _prewLayer = prewLayer;
    
#if 1
    // 添加扫描框
    UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake((TCTScreenWidth - 250) / 2, (TCTScreenHeight - 250) / 2, 250, 250)];
    boxView.backgroundColor = [UIColor clearColor];
    boxView.layer.borderColor = [UIColor greenColor].CGColor;
    boxView.layer.borderWidth = 1.0f;
    [self.view addSubview:boxView];
    
    // 设置扫描区域 CGRectMake(y的起点/屏幕的高度, x的起点/屏幕的宽度, 扫描区域的高度/ 屏幕的高度, 扫描区域的宽度/ 屏幕的宽度)
    output.rectOfInterest = CGRectMake(CGRectGetMinY(boxView.frame)/TCTScreenHeight, CGRectGetMinX(boxView.frame) / TCTScreenWidth, boxView.bounds.size.height / TCTScreenHeight, boxView.bounds.size.width / TCTScreenWidth);
    
    // 设置扫描区域顶部透明图层
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, TCTScreenWidth, CGRectGetMinY(boxView.frame)-64)];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.4;
    [self.view addSubview:topView];
    
    // 设置扫描区域底部透明图层
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(boxView.frame), TCTScreenWidth, TCTScreenHeight-CGRectGetMaxY(boxView.frame))];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.4;
    [self.view addSubview:bottomView];
    
    // 设置扫描区域左部透明图层
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(boxView.frame), CGRectGetMinX(boxView.frame), 250)];
    leftView.backgroundColor = [UIColor blackColor];
    leftView.alpha = 0.4;
    [self.view addSubview:leftView];
    
    // 设置扫描区域右部透明图层
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(boxView.frame), CGRectGetMinY(boxView.frame), TCTScreenWidth-CGRectGetMaxX(boxView.frame), 250)];
    rightView.backgroundColor = [UIColor blackColor];
    rightView.alpha = 0.4;
    [self.view addSubview:rightView];
#endif
    
    // 开始扫描
    [session startRunning];
}

/**
 *  注意此功能只在iOS8之后才开放的
 */
- (void)p_obtainQRCodeFromPhoto {
    NSLog(@"从相册获取二维码");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerView = [[UIImagePickerController alloc] init];
        imagePickerView.delegate = self;
        imagePickerView.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePickerView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:imagePickerView animated:YES completion:nil];
    } else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:obj.stringValue]];
        // 停止扫描
        [_session stopRunning];
        
        // 移除预览图层
        [_prewLayer removeFromSuperlayer];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
    }
}

#pragma mark - UIImagePickerControllerDelegate 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
       // 检测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count > 0) {
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scanResult = feature.messageString;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scanResult]];
        } else {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
}
@end
