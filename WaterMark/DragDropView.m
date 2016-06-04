//
//  DragDropView.m
//  WaterMark
//
//  Created by George She on 16/5/14.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "DragDropView.h"

@interface DragDropView ()
@property(nonatomic, assign) BOOL highlight;
@end

@implementation DragDropView

- (void)awakeFromNib {
  [super awakeFromNib];
  [self
      registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];

  NSShadow *dropShadow = [[NSShadow alloc] init];
  [dropShadow setShadowColor:[NSColor redColor]];
  [dropShadow setShadowOffset:NSMakeSize(0, -10.0)];
  [dropShadow setShadowBlurRadius:10.0];

  [self setWantsLayer:YES];
  [self setShadow:dropShadow];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    [self registerForDraggedTypes:[NSArray
                                      arrayWithObject:NSFilenamesPboardType]];
  }

  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
  if (_highlight) {
    [[NSColor grayColor] set];
    [NSBezierPath setDefaultLineWidth:5];
    [NSBezierPath strokeRect:[self bounds]];
  }
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  _highlight = YES;
  [self setNeedsDisplay:YES];
  return NSDragOperationGeneric;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
  _highlight = NO;
  [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
  _highlight = NO;
  [self setNeedsDisplay:YES];
  return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSArray *draggedFilenames =
      [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
  for (NSString *filePath in draggedFilenames) {
    if ([self isValidFile:filePath]) {
      return YES;
    } else {
      return NO;
    }
  }
  return NO;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
  NSArray *draggedFilenames =
      [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
  NSArray *validFiles = [self getValidFiles:draggedFilenames];
  if (self.dragBlock) {
    self.dragBlock(validFiles);
  }
}

- (BOOL)isValidFile:(NSString *)filePath {
  if ([[filePath pathExtension] isEqual:@"png"] ||
      [[filePath pathExtension] isEqual:@"jpg"] ||
      [[filePath pathExtension] isEqual:@"jpeg"] ||
      [[filePath pathExtension] isEqual:@"tiff"]) {
    return YES;
  }
  return NO;
}

- (NSArray *)getValidFiles:(NSArray *)draggedFiles {
  NSMutableArray *vaildFiles = [NSMutableArray new];
  for (NSString *filePath in draggedFiles) {
    if ([self isValidFile:filePath]) {
      [vaildFiles addObject:filePath];
    }
  }
  return vaildFiles;
}

@end
