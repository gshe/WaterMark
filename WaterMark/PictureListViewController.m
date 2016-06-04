//
//  PictureListViewController.m
//  WaterMark
//
//  Created by George She on 16/5/14.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "PictureListViewController.h"
#import "ThumbnailCollectionViewItem.h"
#import "DetailImageView.h"
#import "TextWaterMarkConfigViewController.h"
#import "ImageWaterMarkConfigViewController.h"
#import "ImageWaterMarkConfig.h"
#import "TextWaterMarkConfig.h"
#import "DragableTextField.h"

#define POPOVER_APPEARANCE NSAppearanceNameVibrantLight

@interface PictureListViewController () <
    NSCollectionViewDelegate, NSCollectionViewDataSource, NSPopoverDelegate,
    WaterMarkConfigViewControllerDelegate>

@property(weak) IBOutlet NSCollectionView *thumbnailList;
@property(weak) IBOutlet DetailImageView *detailImageView;
@property(nonatomic, strong) TextWaterMarkConfigViewController *textConfigVC;
@property(nonatomic, strong) ImageWaterMarkConfigViewController *imageConfigVC;
@property(nonatomic, strong) NSPopover *popover;
@property(nonatomic, strong) WaterMarkConfig *waterMarkConfig;
@property(nonatomic, strong) NSString *currentSelect;
@property(nonatomic, strong) DragableTextField *waterMarkView;
@end

@implementation PictureListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [_thumbnailList registerClass:[ThumbnailCollectionViewItem class]
          forItemWithIdentifier:@"tumbnail"];
  [self makeUI];

  self.thumbnailList.delegate = self;
  self.thumbnailList.dataSource = self;
  NSCollectionViewFlowLayout *flowLayout =
      [[NSCollectionViewFlowLayout alloc] init];
  flowLayout.itemSize = NSMakeSize(140, 140);
  flowLayout.minimumLineSpacing = 10;
  flowLayout.minimumInteritemSpacing = 10;
  flowLayout.sectionInset = NSEdgeInsetsMake(10, 20, 10, 20);
  self.thumbnailList.collectionViewLayout = flowLayout;
  self.thumbnailList.selectable = YES;

  self.textConfigVC = [[TextWaterMarkConfigViewController alloc]
      initWithNibName:@"TextWaterMarkConfigViewController"
               bundle:nil];
  self.textConfigVC.delegate = self;
  self.imageConfigVC = [[ImageWaterMarkConfigViewController alloc]
      initWithNibName:@"ImageWaterMarkConfigViewController"
               bundle:nil];
  self.imageConfigVC.delegate = self;
  self.popover = [[NSPopover alloc] init];
  self.popover.appearance = [NSAppearance appearanceNamed:POPOVER_APPEARANCE];
  self.popover.animates = YES;
}

- (void)dealloc {
  self.textConfigVC = nil;
}

- (void)makeUI {
}

- (NSInteger)numberOfSectionsInCollectionView:
        (NSCollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return _files.count;
}

- (void)collectionView:(NSCollectionView *)collectionView
    didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  if (indexPaths.count > 0) {
    NSIndexPath *indexPath = [[indexPaths objectEnumerator] nextObject];
    ThumbnailCollectionViewItem *item = (ThumbnailCollectionViewItem *)
        [collectionView itemAtIndexPath:indexPath];
    [item setHightLight:YES];
    _currentSelect = [_files objectAtIndex:indexPath.item];
    NSImage *loadedImage =
        [[NSImage alloc] initWithContentsOfFile:_currentSelect];
    self.detailImageView.image = loadedImage;
  }
}

- (void)collectionView:(NSCollectionView *)collectionView
    didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  if (indexPaths.count > 0) {
    NSIndexPath *indexPath = [[indexPaths objectEnumerator] nextObject];
    ThumbnailCollectionViewItem *item = (ThumbnailCollectionViewItem *)
        [collectionView itemAtIndexPath:indexPath];
    [item setHightLight:NO];
  }
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
  ThumbnailCollectionViewItem *item =
      [collectionView makeItemWithIdentifier:@"ThumbnailCollectionViewItem"
                                forIndexPath:indexPath];
  NSString *filePath = [_files objectAtIndex:indexPath.item];
  NSString *fileName = [filePath lastPathComponent];
  [item.textField setStringValue:fileName];
  NSImage *mainImage = [[NSImage alloc] initWithContentsOfFile:filePath];
  item.imageView.image = mainImage;
  return item;
}

- (IBAction)onPressExport:(id)sender {
  NSString *fileName = [_currentSelect lastPathComponent];
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setNameFieldStringValue:fileName];
  [panel setMessage:@"Choose the path to save the document"];
  [panel setAllowsOtherFileTypes:YES];
  [panel setExtensionHidden:YES];
  [panel setCanCreateDirectories:YES];
  [panel beginSheetModalForWindow:self.view.window
                completionHandler:^(NSInteger result) {
                  if (result == NSFileHandlingPanelOKButton) {
                    NSString *path = [[panel URL] path];
                    NSImage *image = self.detailImageView.image;
                    NSData *tempdata;
                    NSBitmapImageRep *srcImageRep;
                    BOOL reflag = NO;
                    [image lockFocus];
                    srcImageRep = [NSBitmapImageRep
                        imageRepWithData:[image TIFFRepresentation]];
                    tempdata =
                        [srcImageRep representationUsingType:NSJPEGFileType
                                                  properties:@{}];
                    reflag = [tempdata writeToFile:path atomically:YES];
                    [image unlockFocus];
                  }
                }];
}

- (IBAction)onPressAddImage:(id)sender {
  NSButton *btn = sender;
  self.popover.contentViewController = self.imageConfigVC;
  [self.popover showRelativeToRect:btn.bounds
                            ofView:btn
                     preferredEdge:NSRectEdgeMaxX];
}

- (IBAction)onPressAddText:(id)sender {
  NSButton *btn = sender;
  self.popover.contentViewController = self.textConfigVC;
  [self.popover showRelativeToRect:btn.bounds
                            ofView:btn
                     preferredEdge:NSRectEdgeMaxX];
}

- (NSImage *)doLoadImageData {
  NSImage *loadedImage =
      [[NSImage alloc] initWithContentsOfFile:_currentSelect];
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
  if ([_waterMarkConfig isKindOfClass:[TextWaterMarkConfig class]]) {
    [self drawTextWithOriginalImageWidth:width height:height];
  } else if ([_waterMarkConfig isKindOfClass:[ImageWaterMarkConfig class]]) {
    [self drawImageWithOriginalImageWidth:width height:height];
  }

  [NSGraphicsContext restoreGraphicsState];

  NSImage *finalImage = [[NSImage alloc] init];
  [finalImage addRepresentation:finalImageRep];
  return finalImage;
}

- (void)drawTextWithOriginalImageWidth:(CGFloat)width height:(CGFloat)height {
  TextWaterMarkConfig *config = (TextWaterMarkConfig *)_waterMarkConfig;
  NSMutableDictionary *attributes = [NSMutableDictionary
      dictionaryWithObjectsAndKeys:[NSColor whiteColor],
                                   NSForegroundColorAttributeName, nil];
  if (config.font != nil) {
    [attributes setValue:config.font forKey:NSFontAttributeName];
  }

  NSAttributedString *titleAttrStr =
      [[NSAttributedString alloc] initWithString:config.title
                                      attributes:attributes];

  NSSize titleSize = [titleAttrStr size];
  NSPoint titleOrigin = NSMakePoint(floor((width - titleSize.width) / 2.0),
                                    floor((height - titleSize.height) / 2.0));
  [titleAttrStr drawAtPoint:titleOrigin];
}

- (void)drawImageWithOriginalImageWidth:(CGFloat)width height:(CGFloat)height {
  ImageWaterMarkConfig *config = (ImageWaterMarkConfig *)_waterMarkConfig;
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:config.imageUrl];
  NSImage *newImage = [self imageResize:image newSize:config.imageSize];
  NSPoint imageOrigin =
      NSMakePoint(floor((width - config.imageSize.width) / 2.0),
                  floor((height - config.imageSize.height) / 2.0));
  [newImage drawAtPoint:imageOrigin
               fromRect:CGRectZero
              operation:NSCompositeCopy
               fraction:1.0];
}

- (NSImage *)imageResize:(NSImage *)anImage newSize:(NSSize)newSize {
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

- (NSImage *)addBadgeToImage:(NSImage *)baseImage count:(unsigned)count;
{
  NSString *countStr = [NSString stringWithFormat:@"%d", count];
  NSDictionary *attributes = [NSDictionary
      dictionaryWithObjectsAndKeys:[NSColor whiteColor],
                                   NSForegroundColorAttributeName, nil];
  NSAttributedString *countAttrStr =
      [[NSAttributedString alloc] initWithString:countStr
                                      attributes:attributes];

  NSImage *badgeImage = [NSImage imageNamed:@"share_twitter"];

  const float totalWidth =
      ceil(baseImage.size.width + badgeImage.size.width / 2.0);
  const float totalHeight =
      ceil(baseImage.size.height + badgeImage.size.height / 2.0);

  NSBitmapImageRep *finalImageRep = [[NSBitmapImageRep alloc]
      initWithBitmapDataPlanes:NULL
                    pixelsWide:totalWidth
                    pixelsHigh:totalHeight
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
  NSRectFillUsingOperation(NSMakeRect(0, 0, totalWidth, totalHeight),
                           NSCompositeClear);
  NSPoint badgeOrigin =
      NSMakePoint(floor(baseImage.size.width - badgeImage.size.width / 2.0),
                  floor(baseImage.size.height - badgeImage.size.height / 2.0));

  [baseImage drawAtPoint:NSZeroPoint
                fromRect:NSZeroRect
               operation:NSCompositeCopy
                fraction:1.0];
  [badgeImage drawAtPoint:badgeOrigin
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1.0];

  NSAttributedString *title =
      [[NSAttributedString alloc] initWithString:@"我是垂直居中的"
                                      attributes:attributes];
  [title drawAtPoint:CGPointMake(100, 100)];

  NSSize countSize = [countAttrStr size];
  NSPoint countOrigin = NSMakePoint(
      floor(badgeOrigin.x + ((badgeImage.size.width - countSize.width) / 2.0)),
      floor(badgeOrigin.y +
            ((badgeImage.size.height - countSize.height) / 2.0)));
  [countAttrStr drawAtPoint:countOrigin];

  [NSGraphicsContext restoreGraphicsState];

  NSImage *finalImage = [[NSImage alloc] init];
  [finalImage addRepresentation:finalImageRep];
  return finalImage;
}

+ (void)saveImage:(NSImage *)image atPath:(NSString *)path {

  CGImageRef cgRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
  NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
  [newRep setSize:[image size]]; // if you want the same resolution
  NSData *pngData =
      [newRep representationUsingType:NSPNGFileType properties:@{}];
  [pngData writeToFile:path atomically:YES];
}

- (void)addWaterMarkViewIntoImageView {
  [_waterMarkView removeFromSuperview];
  if (![_waterMarkConfig isKindOfClass:[TextWaterMarkConfig class]]) {
    return;
  }

  TextWaterMarkConfig *config = (TextWaterMarkConfig *)_waterMarkConfig;
  _waterMarkView = [[DragableTextField alloc] init];
  _waterMarkView.font = config.font;
  _waterMarkView.stringValue = config.title;
	[_waterMarkView setDrawsBackground:NO];
	[_waterMarkView setEditable:NO];
	[_waterMarkView setSelectable:NO];
	[_waterMarkView setBezeled:NO];
  [_waterMarkView sizeToFit];
  _waterMarkView.frame = CGRectMake(
      (_detailImageView.bounds.size.width - _waterMarkView.bounds.size.width) /
          2,
      (_detailImageView.bounds.size.height -
       _waterMarkView.bounds.size.height) /
          2,
      _waterMarkView.bounds.size.width, _waterMarkView.bounds.size.height);
  [_detailImageView addSubview:_waterMarkView];
}

#pragma TextWaterMarkConfigViewControllerDelegate
- (void)actionButtonClicked:(BOOL)isActiveButtonClick
                       data:(WaterMarkConfig *)cofigData {
  if (isActiveButtonClick) {
    _waterMarkConfig = cofigData;
    // self.detailImageView.image = [self doLoadImageData];
    [self addWaterMarkViewIntoImageView];
  }

  [self.popover performClose:self];
}

@end
