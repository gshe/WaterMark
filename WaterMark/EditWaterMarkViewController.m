//
//  EditWaterMarkViewController.m
//  WaterMark
//
//  Created by George She on 16/5/20.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "EditWaterMarkViewController.h"
#import "ViewController.h"
#import "TextWaterMarkConfigViewController.h"
#import "ImageWaterMarkConfigViewController.h"
#import "TipForWaterMarkActionViewController.h"

#import "ImageWaterMarkConfig.h"
#import "TextWaterMarkConfig.h"
#import "DragableTextField.h"
#import "DragableImageView.h"
#import "NSImage+ContentMode.h"
#import "WaterMarkPreviewViewController.h"

#define POPOVER_APPEARANCE NSAppearanceNameVibrantLight
static const char *key;

@interface EditWaterMarkViewController () <
    NSPopoverDelegate, WaterMarkConfigViewControllerDelegate,
    TipForWaterMarkActionViewControllerDelegate, NSTextFieldDelegate>
@property(weak) IBOutlet NSView *topContainerView;
@property(weak) IBOutlet NSImageView *imageView;
@property(weak) IBOutlet NSView *bottomContainerView;

@property(nonatomic, strong) TextWaterMarkConfigViewController *textConfigVC;
@property(nonatomic, strong) ImageWaterMarkConfigViewController *imageConfigVC;
@property(nonatomic, strong)
    TipForWaterMarkActionViewController *tipForActionVC;
@property(nonatomic, strong) NSPopover *popover;
@property(nonatomic, strong)
    NSMutableArray<WaterMarkConfig> *waterMarkConfigArray;
@end

@implementation EditWaterMarkViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.topContainerView.wantsLayer = YES;
  self.topContainerView.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
  self.bottomContainerView.wantsLayer = YES;
  self.bottomContainerView.layer.backgroundColor =
      [NSColor darkGrayColor].CGColor;
  _waterMarkConfigArray = [@[] mutableCopy];

  if (_file) {
    _imageView.image = [[NSImage alloc] initWithContentsOfFile:_file];
  }

  self.textConfigVC = [[TextWaterMarkConfigViewController alloc]
      initWithNibName:@"TextWaterMarkConfigViewController"
               bundle:nil];
  self.textConfigVC.delegate = self;
  self.imageConfigVC = [[ImageWaterMarkConfigViewController alloc]
      initWithNibName:@"ImageWaterMarkConfigViewController"
               bundle:nil];
  self.imageConfigVC.delegate = self;
  self.tipForActionVC = [[TipForWaterMarkActionViewController alloc]
      initWithNibName:@"TipForWaterMarkActionViewController"
               bundle:nil];
  self.tipForActionVC.delegate = self;
  self.popover = [[NSPopover alloc] init];
  self.popover.appearance = [NSAppearance appearanceNamed:POPOVER_APPEARANCE];
  self.popover.animates = YES;
}

- (IBAction)onTextWatermarkClicked:(id)sender {
  NSButton *btn = sender;
  if ([sender isKindOfClass:[DragableTextField class]]) {
    TextWaterMarkConfig *config = objc_getAssociatedObject(sender, key);
    self.textConfigVC.existedConfig = config;
  } else {
    self.textConfigVC.existedConfig = nil;
  }
  self.popover.contentViewController = self.textConfigVC;
  [self.popover showRelativeToRect:btn.bounds
                            ofView:btn
                     preferredEdge:NSRectEdgeMaxY];
}

- (IBAction)onImageWatermarkClicked:(id)sender {
  NSButton *btn = sender;
  if ([sender isKindOfClass:[DragableImageView class]]) {
    ImageWaterMarkConfig *config = objc_getAssociatedObject(sender, key);
    self.imageConfigVC.existedConfig = config;
  } else {
    self.imageConfigVC.existedConfig = nil;
  }
  self.popover.contentViewController = self.imageConfigVC;
  [self.popover showRelativeToRect:btn.bounds
                            ofView:btn
                     preferredEdge:NSRectEdgeMaxX];
}

- (IBAction)onTipActionClicked:(id)sender {
  NSButton *btn = sender;
  self.tipForActionVC.originSender = sender;
  self.popover.contentViewController = self.tipForActionVC;
  [self.popover showRelativeToRect:btn.bounds
                            ofView:btn
                     preferredEdge:NSRectEdgeMinX];
}

- (IBAction)onPreviewClicked:(id)sender {
  NSStoryboard *storyboard =
      [NSStoryboard storyboardWithName:@"Main" bundle:nil];
  NSWindowController *previewWindowController =
      [storyboard instantiateControllerWithIdentifier:@"previewWindow"];
  WaterMarkPreviewViewController *previewVC =
      (WaterMarkPreviewViewController *)
          previewWindowController.contentViewController;
  previewVC.file = self.file;
  previewVC.previewImage = [self generateWaterMarkImage];
	previewVC.modelSession = [NSApp beginModalSessionForWindow:previewWindowController.window];
}

- (IBAction)onExportClicked:(id)sender {
  NSString *fileName = [self.file lastPathComponent];
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setNameFieldStringValue:fileName];
  [panel setMessage:NSLocalizedString(@"Choose the path to save the document",
                                      @"")];
  [panel setAllowsOtherFileTypes:YES];
  [panel setExtensionHidden:YES];
  [panel setCanCreateDirectories:YES];
  [panel beginSheetModalForWindow:self.view.window
                completionHandler:^(NSInteger result) {
                  if (result == NSFileHandlingPanelOKButton) {
                    NSString *savePath = [[panel URL] path];
                    @autoreleasepool {
                      [self exportToFile:savePath];
                    }
                  }
                }];
}

- (IBAction)onBackClicked:(id)sender {
  NSStoryboard *story =
      [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

  ViewController *vc =
      [story instantiateControllerWithIdentifier:@"selectfile"];
  self.view.window.contentViewController = vc;
}

- (void)addWatermark:(WaterMarkConfig *)configData {
  [_waterMarkConfigArray addObject:configData];
  if ([configData isKindOfClass:[TextWaterMarkConfig class]]) {
    TextWaterMarkConfig *textConfig = (TextWaterMarkConfig *)configData;
    [self createTextWaterMark:textConfig];
  } else if ([configData isKindOfClass:[ImageWaterMarkConfig class]]) {
    ImageWaterMarkConfig *imageConfig = (ImageWaterMarkConfig *)configData;
    [self createImageWaterMark:imageConfig];
  }
}

- (void)editWatermark:(WaterMarkConfig *)configData {
  [_waterMarkConfigArray addObject:configData];
  NSView *view = [self findViewByConfigData:configData];
  if ([configData isKindOfClass:[TextWaterMarkConfig class]]) {
    DragableTextField *textFieldView = (DragableTextField *)view;
    TextWaterMarkConfig *textConfig = (TextWaterMarkConfig *)configData;
    [self editTextWaterMark:textFieldView withConfig:textConfig];
  } else if ([configData isKindOfClass:[ImageWaterMarkConfig class]]) {
    DragableImageView *imageView = (DragableImageView *)view;
    ImageWaterMarkConfig *imageConfig = (ImageWaterMarkConfig *)configData;
    [self editImageWaterMark:imageView withConfig:imageConfig];
  }
}

- (NSView *)findViewByConfigData:(WaterMarkConfig *)configData {
  NSView *retView = nil;
  for (NSView *v in self.imageView.subviews) {
    WaterMarkConfig *associatedConfig = nil;
    if ([v isKindOfClass:[DragableTextField class]] ||
        [v isKindOfClass:[DragableImageView class]]) {
      associatedConfig = objc_getAssociatedObject(v, key);
    }
    if (associatedConfig == configData) {
      retView = v;
      break;
    }
  }
  return retView;
}

- (NSTextField *)createTextWaterMark:(TextWaterMarkConfig *)config {
  if (![config isKindOfClass:[TextWaterMarkConfig class]]) {
    return nil;
  }

  DragableTextField *waterMarkView = [[DragableTextField alloc] init];
  waterMarkView.font = config.font;
  waterMarkView.stringValue = config.title;
  waterMarkView.textColor = config.color;
  waterMarkView.drawsBackground = NO;
  waterMarkView.editable = NO;
  waterMarkView.selectable = NO;
  waterMarkView.bezeled = NO;
  [waterMarkView sizeToFit];
  waterMarkView.frame = CGRectMake(
      (self.imageView.bounds.size.width - waterMarkView.bounds.size.width) / 2,
      (self.imageView.bounds.size.height - waterMarkView.bounds.size.height) /
          2,
      waterMarkView.bounds.size.width, waterMarkView.bounds.size.height);

  objc_setAssociatedObject(waterMarkView, key, config, OBJC_ASSOCIATION_RETAIN);
  [self.imageView addSubview:waterMarkView];
  waterMarkView.doubleClickBlock = ^(NSTextField *textField) {
    [self onTipActionClicked:textField];
  };
  return waterMarkView;
}

- (void)editTextWaterMark:(DragableTextField *)view
               withConfig:(TextWaterMarkConfig *)textConfig {
  [view sizeToFit];
  view.font = textConfig.font;
  view.stringValue = textConfig.title;
  view.textColor = textConfig.color;
  [view sizeToFit];
  [view setNeedsDisplay];
}

- (void)editImageWaterMark:(DragableImageView *)view
                withConfig:(ImageWaterMarkConfig *)imageConfig {
  NSImage *image =
      [[NSImage alloc] initWithContentsOfFile:imageConfig.imageUrl];
  NSImage *newImage = nil;
  if (imageConfig.isKeepAspectRation) {
    newImage =
        [self resizeImageKeepAspectRatio:image size:imageConfig.imageSize];
  } else {
    newImage = [self resizeImage:image newSize:imageConfig.imageSize];
  }
  view.image = newImage;
  [view setNeedsDisplay];
}

- (NSImageView *)createImageWaterMark:(ImageWaterMarkConfig *)config {
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:config.imageUrl];
  NSImage *newImage = nil;
  if (config.isKeepAspectRation) {
    newImage = [self resizeImageKeepAspectRatio:image size:config.imageSize];
  } else {
    newImage = [self resizeImage:image newSize:config.imageSize];
  }
  DragableImageView *imageView = [[DragableImageView alloc]
      initWithFrame:
          CGRectMake(
              (self.imageView.bounds.size.width - config.imageSize.width) / 2,
              (self.imageView.bounds.size.height - config.imageSize.height) / 2,
              config.imageSize.width, config.imageSize.height)];
  imageView.image = newImage;
  objc_setAssociatedObject(imageView, key, config, OBJC_ASSOCIATION_RETAIN);
  [self.imageView addSubview:imageView];
  imageView.doubleClickBlock = ^(NSImageView *imageView) {
    [self onTipActionClicked:imageView];
  };

  return imageView;
}

- (NSImage *)resizeImage:(NSImage *)anImage newSize:(NSSize)newSize {
  NSImage *sourceImage = anImage;

  // Report an error if the source isn't a valid image
  if (![sourceImage isValid]) {
    NSLog(@"Invalid Image");
  } else {
    NSImage *smallImage = [[NSImage alloc] initWithSize:newSize];
    [smallImage lockFocus];
    [sourceImage setSize:newSize];
    [[NSGraphicsContext currentContext]
        setImageInterpolation:NSImageInterpolationHigh];
    [sourceImage drawAtPoint:NSZeroPoint
                    fromRect:CGRectMake(0, 0, newSize.width, newSize.height)
                   operation:NSCompositeCopy
                    fraction:1.0];
    [smallImage unlockFocus];
    return smallImage;
  }
  return nil;
}

- (NSImage *)resizeImageKeepAspectRatio:(NSImage *)sourceImage
                                   size:(NSSize)newSize {
  NSImage *smallImage = [[NSImage alloc] initWithSize:newSize];
  [smallImage lockFocus];
  NSRect targetFrame = NSMakeRect(0, 0, newSize.width, newSize.height);
  [[NSGraphicsContext currentContext]
      setImageInterpolation:NSImageInterpolationHigh];
  [sourceImage drawInRect:targetFrame
              contentMode:UIViewContentModeScaleAspectFit];
  [smallImage unlockFocus];
  return smallImage;
}

- (void)deleteWaterMark:(NSView *)view {
  if ([view isKindOfClass:[DragableTextField class]] ||
      [view isKindOfClass:[DragableImageView class]]) {
    WaterMarkConfig *config = objc_getAssociatedObject(view, key);
    [self.waterMarkConfigArray removeObject:config];
    [view removeFromSuperview];
  }
}

- (BOOL)exportToFile:(NSString *)savePath {
  NSImage *finalImage = [self generateWaterMarkImage];
  NSBitmapImageRep *imgRep =
      (NSBitmapImageRep *)[[finalImage representations] objectAtIndex:0];

  NSData *tempdata =
      [imgRep representationUsingType:NSJPEGFileType properties:@{}];
  [tempdata writeToFile:savePath atomically:YES];
  return YES;
}

- (NSImage *)generateWaterMarkImage {
  NSImage *loadedImage = self.imageView.image;
  CGFloat width = loadedImage.size.width;
  CGFloat height = loadedImage.size.height;
  NSBitmapImageRep *finalImageRep = [[NSBitmapImageRep alloc]
      initWithBitmapDataPlanes:NULL
                    pixelsWide:width
                    pixelsHigh:height
                 bitsPerSample:8
               samplesPerPixel:4
                      hasAlpha:YES
                      isPlanar:NO
                colorSpaceName:NSCalibratedRGBColorSpace
                   bytesPerRow:0
                  bitsPerPixel:0];
  NSGraphicsContext *ctx =
      [NSGraphicsContext graphicsContextWithBitmapImageRep:finalImageRep];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:ctx];
  NSRectFillUsingOperation(NSMakeRect(0, 0, width, height), NSCompositeClear);

  [loadedImage drawAtPoint:NSZeroPoint
                  fromRect:NSZeroRect
                 operation:NSCompositeCopy
                  fraction:1.0];
  for (WaterMarkConfig *config in self.waterMarkConfigArray) {
    NSView *view = [self findViewByConfigData:config];
    if ([config isKindOfClass:[TextWaterMarkConfig class]]) {
      TextWaterMarkConfig *c = (TextWaterMarkConfig *)config;
      [self drawTextWithImageView:self.imageView config:c andView:view];
    } else if ([config isKindOfClass:[ImageWaterMarkConfig class]]) {
      ImageWaterMarkConfig *c = (ImageWaterMarkConfig *)config;
      [self drawImageWithImageView:self.imageView config:c andView:view];
    }
  }

  [NSGraphicsContext restoreGraphicsState];
  NSImage *finalImage = [[NSImage alloc] init];
  [finalImage addRepresentation:finalImageRep];
  return finalImage;
}

- (void)drawTextWithImageView:(NSImageView *)imageView
                       config:(TextWaterMarkConfig *)config
                      andView:(NSView *)view {
  NSPoint point = view.frame.origin;
  NSSize imageSize = imageView.bounds.size;
  NSSize imageRealSize = imageView.image.size;
  CGFloat x = imageRealSize.width * point.x / imageSize.width;
  CGFloat y = imageRealSize.height * point.y / imageSize.height;
  NSMutableDictionary *attributes = [NSMutableDictionary
      dictionaryWithObjectsAndKeys:config.color, NSForegroundColorAttributeName,
                                   nil];
  if (config.font != nil) {
    [attributes setValue:config.font forKey:NSFontAttributeName];
  }

  NSAttributedString *titleAttrStr =
      [[NSAttributedString alloc] initWithString:config.title
                                      attributes:attributes];
  NSPoint titleOrigin = NSMakePoint(floor(x), floor(y));
  [titleAttrStr drawAtPoint:titleOrigin];
}

- (void)drawImageWithImageView:(NSImageView *)imageView
                        config:(ImageWaterMarkConfig *)config
                       andView:(NSView *)view {
  NSPoint point = view.frame.origin;
  NSSize imageSize = imageView.bounds.size;
  NSSize imageRealSize = imageView.image.size;
  CGFloat x = imageRealSize.width * point.x / imageSize.width;
  CGFloat y = imageRealSize.height * point.y / imageSize.height;

  NSImage *image = [[NSImage alloc] initWithContentsOfFile:config.imageUrl];
  NSImage *newImage =
      [self resizeImageKeepAspectRatio:image size:config.imageSize];
  NSPoint imageOrigin = NSMakePoint(floor(x), floor(y));

  [newImage drawAtPoint:imageOrigin
               fromRect:CGRectZero
              operation:NSCompositeCopy
               fraction:1.0];
}

#pragma TextWaterMarkConfigViewControllerDelegate
- (void)configVC:(NSViewController *)vc
    actionButtonClicked:(BOOL)isActiveButtonClick
                   data:(WaterMarkConfig *)cofigData {
  if (isActiveButtonClick) {
    if ([vc isKindOfClass:[TextWaterMarkConfigViewController class]]) {
      TextWaterMarkConfigViewController *configVC =
          (TextWaterMarkConfigViewController *)vc;
      if (configVC.existedConfig) {
        [self editWatermark:cofigData];
      } else {
        [self addWatermark:cofigData];
      }
    }
    if ([vc isKindOfClass:[ImageWaterMarkConfigViewController class]]) {
      ImageWaterMarkConfigViewController *configVC =
          (ImageWaterMarkConfigViewController *)vc;
      if (configVC.existedConfig) {
        [self editWatermark:cofigData];
      } else {
        [self addWatermark:cofigData];
      }
    }
  }

  [self.popover performClose:self];
}

#pragma TipForWaterMarkActionViewControllerDelegate
- (void)actionVC:(TipForWaterMarkActionViewController *)vc
        selected:(TipAction)action {
  [self.popover performClose:self];
  switch (action) {
  case TipAction_Edit:
    if ([vc.originSender isKindOfClass:[NSImageView class]]) {
      [self onImageWatermarkClicked:vc.originSender];
    } else {
      if ([vc.originSender isKindOfClass:[NSTextField class]]) {
        [self onTextWatermarkClicked:vc.originSender];
      }
    }
    break;
  case TipAction_Delete:
    [self deleteWaterMark:vc.originSender];
    break;
  case TipAction_Cancel:
    break;
  default:
    break;
  }
}
@end
