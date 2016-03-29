//
//  UIImage+Extension.h
//  QRCode
//
//  Created by TCT on 16/3/28.
//  Copyright © 2016年 TCT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  根据指定的CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  指定的大小
 *
 *  @return 生成的UIImage
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;

/**
 *  二维码的染色
 */
+ (UIImage *)imageFillBlackColorAndTransparent:(UIImage *)image red:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;
@end
