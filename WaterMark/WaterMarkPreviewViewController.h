//
//  WaterMarkPreviewViewController.h
//  WaterMark
//
//  Created by George She on 16/5/21.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WaterMarkPreviewViewController : NSViewController
@property(nonatomic, copy) NSString *file;
@property(nonatomic, strong) NSImage *previewImage;
@property(nonatomic, assign) NSModalSession modelSession;
@end
