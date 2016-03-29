//
//  ViewController.m
//  QRCode
//
//  Created by TCT on 16/3/28.
//  Copyright © 2016年 TCT. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import "UIImage+Extension.h"
#import <AVFoundation/AVFoundation.h>
#import "TCTQRCodeViewController.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic ,weak) UIImageView *QRCodeView;
@property (nonatomic ,weak) UIView *functionView;
@end

#define TCTScreenWidth self.view.bounds.size.width
#define TCTScreenHeight self.view.bounds.size.height
#define TCTCenterImageWidth 80

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.0f];
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // 创建二维码的视图
    [self p_setupQRCodeContainerView];
    
    // 功能按钮
    [self p_setupFunctionButton];
}


# pragma mark - private method
- (void)p_setupQRCodeContainerView {
    UIView *containerView = [[UIView alloc] init];
    containerView.layer.cornerRadius = 10;
    containerView.layer.masksToBounds = YES;
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.frame = CGRectMake(30, 80, TCTScreenWidth - 60, 400);
    [self.view addSubview:containerView];
    
    // 二维码的显示区
    UIImageView *QRCodeView = [[UIImageView alloc] init];
    QRCodeView.frame = CGRectMake(40, 80, containerView.bounds.size.width - 80, containerView.bounds.size.width - 80);
    [containerView addSubview:QRCodeView];
    _QRCodeView = QRCodeView;
    
    // 添加长按收拾
    QRCodeView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(p_longPressScanQRCode:)];
    [QRCodeView addGestureRecognizer:longPress];
}

- (void)p_generateQRCodeWithCenterImage:(UIImage *)centerImage {
    NSLog(@"生成二维码");
    
    // 创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 设置为默认的filter
    [filter setDefaults];
    
    // filter添加数据
    NSString *dataString = @"http://www.bj-tct.com/";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"]; // 设置二维码的内容数据
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"]; // 设置纠错级别[L, M, Q, H],j纠错级别越高二维码的块数越多
    
    
    // 输出二维码
    CIImage *outputImage = [filter outputImage];
    
    // 显示二维码
    _QRCodeView.image = [UIImage imageFillBlackColorAndTransparent:[UIImage createNonInterpolatedUIImageFormCIImage:outputImage withSize:_QRCodeView.bounds.size.width] red:107 green:90 blue:165];
    
    // 设置centerImage
    if (centerImage) {
        UIImageView *centerImageView = [[UIImageView alloc] init];
        centerImageView.image = centerImage;
        centerImageView.frame = CGRectMake((_QRCodeView.frame.size.width - TCTCenterImageWidth) / 2, (_QRCodeView.frame.size.height - TCTCenterImageWidth) / 2, TCTCenterImageWidth, TCTCenterImageWidth);
        [_QRCodeView addSubview:centerImageView];
    }
}



- (void)p_setupFunctionButton {
    UIView *functionView = [[UIView alloc] init];
    functionView.backgroundColor = [UIColor whiteColor];
    functionView.layer.cornerRadius = 10;
    functionView.layer.masksToBounds = YES;
    functionView.frame = CGRectMake(30, 500,  TCTScreenWidth - 60, 55);
    [self.view addSubview:functionView];
    _functionView = functionView;
    
    UIButton *generateButton = [self buttonWithTitle:@"generate"];
    [generateButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    generateButton.frame = CGRectMake(10, 10, (functionView.bounds.size.width - 40) / 2, 35);
    [generateButton addTarget:self action:@selector(p_generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:generateButton];
    
    UIButton *scanButton = [self buttonWithTitle:@"scan"];
    [scanButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    scanButton.frame = CGRectMake(CGRectGetMaxX(generateButton.frame)+ 20, 10, (functionView.bounds.size.width - 40) / 2, 35);
    [scanButton addTarget:self action:@selector(p_scanQRCodeViewController) forControlEvents:UIControlEventTouchUpInside];
    [functionView addSubview:scanButton];
}

- (void)p_generateQRCode {
    // 注意center Image最好设置透明度，否则可能会影响扫描效果
    [self p_generateQRCodeWithCenterImage:nil];
}

- (void)p_scanQRCodeViewController {
    TCTQRCodeViewController *vc = [[TCTQRCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)p_longPressScanQRCode:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIImageView *tempImageView = (UIImageView *)gesture.view;
        if (tempImageView.image) {
            // 初始化扫描仪
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
            
            // 扫描获取的特征组
            NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:tempImageView.image.CGImage]];
            
            // 获取扫描结果
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scanResult = feature.messageString;
            
            // 对结果进行处理
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scanResult]];
        }
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 0.5;
    
    return button;
}


@end
