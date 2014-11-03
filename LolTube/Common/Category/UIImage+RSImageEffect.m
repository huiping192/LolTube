//
// Created by 郭 輝平 on 10/11/14.
// Copyright (c) 2014 Huiping Guo. All rights reserved.
//

#import "UIImage+RSImageEffect.h"

@implementation UIImage (RSImageEffect)

- (UIImage *)blackAndWhiteImage{
    CIImage *beginImage = [[CIImage alloc] initWithCGImage:[self CGImage]];

    CIImage *output = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:1.0], @"inputColor", [[CIColor alloc] initWithColor:[UIColor whiteColor]], nil].outputImage;

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    CGImageRelease(cgiimage);

    return newImage;
}
@end