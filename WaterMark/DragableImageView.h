//
//  DragableImageView.h
//  WaterMark
//
//  Created by George She on 16/5/20.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^DragableImageViewDoubleClicked)(NSImageView *imageView);

@interface DragableImageView : NSImageView
@property(nonatomic, copy) DragableImageViewDoubleClicked doubleClickBlock;
@end
