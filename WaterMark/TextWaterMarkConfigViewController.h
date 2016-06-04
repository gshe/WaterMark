//
//  TextWaterMarkConfigViewController.h
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextWaterMarkConfig.h"

@interface TextWaterMarkConfigViewController : NSViewController
@property(nonatomic, strong) TextWaterMarkConfig *existedConfig;
@property(nonatomic, weak) id<WaterMarkConfigViewControllerDelegate> delegate;
@end
