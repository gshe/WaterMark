//
//  DragableTextField.m
//  WaterMark
//
//  Created by George She on 16/5/20.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "DragableTextField.h"

@interface DragableTextField ()
@property(nonatomic, assign) CGPoint lastDragLocation;
@end

@implementation DragableTextField

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];

  // Drawing code here.
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
  return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
  if (theEvent.clickCount >= 2) {
    if (self.doubleClickBlock) {
      self.doubleClickBlock(self);
    }
  } else {
	  [self becomeFirstResponder];
    self.lastDragLocation =
        [[self superview] convertPoint:[theEvent locationInWindow]
                              fromView:nil];
  }
}

- (void)mouseDragged:(NSEvent *)theEvent {

  NSPoint newDragLocation =
      [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
  NSPoint thisOrigin = [self frame].origin;
  thisOrigin.x += (-self.lastDragLocation.x + newDragLocation.x);
  thisOrigin.y += (-self.lastDragLocation.y + newDragLocation.y);
  if (thisOrigin.x + self.bounds.size.width >
      self.superview.bounds.size.width) {
    thisOrigin.x = self.superview.bounds.size.width - self.bounds.size.width;
  }
  if (thisOrigin.y + self.bounds.size.height >
      self.superview.bounds.size.height) {
    thisOrigin.y = self.superview.bounds.size.height - self.bounds.size.height;
  }
  if (thisOrigin.x < 0) {
    thisOrigin.x = 0;
  }
  if (thisOrigin.y < 0) {
    thisOrigin.y = 0;
  }
  [self setFrameOrigin:thisOrigin];
  self.lastDragLocation = newDragLocation;
}
-(void)keyDown:(NSEvent *)theEvent{
	
}
- (void)moveUp:(id)sender {
}

- (void)moveDown:(id)sender {
}

- (void)moveLeft:(id)sender {
}

- (void)moveRight:(id)sender {
}
@end
