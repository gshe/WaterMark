//
//  DragDropView.h
//  WaterMark
//
//  Created by George She on 16/5/14.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef void (^ReceivedDragFiles)(NSArray *);

@interface DragDropView : NSView
@property(nonatomic, copy) ReceivedDragFiles dragBlock;
@end
