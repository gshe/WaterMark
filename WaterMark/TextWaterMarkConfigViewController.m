//
//  TextWaterMarkConfigViewController.m
//  WaterMark
//
//  Created by George She on 16/5/16.
//  Copyright © 2016年 Freedom. All rights reserved.
//

#import "TextWaterMarkConfigViewController.h"
#import "TextWaterMarkConfig.h"

@interface TextWaterMarkConfigViewController () <NSTextFieldDelegate>
@property(weak) IBOutlet NSView *bottomView;
@property(weak) IBOutlet NSTextField *watermarkTitle;
@property(weak) IBOutlet NSTextField *sampleTextField;
@property(nonatomic, strong) NSFont *selectedFont;
@property(weak) IBOutlet NSColorWell *colorWell;
@end

@implementation TextWaterMarkConfigViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.bottomView.wantsLayer = YES;
  self.bottomView.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
  self.watermarkTitle.delegate = self;
}

- (void)dealloc {
}

- (void)viewWillAppear {
  if (self.existedConfig) {
    self.watermarkTitle.stringValue = self.existedConfig.title;
    self.colorWell.color = self.existedConfig.color;
  }
  [super viewWillAppear];
}

- (IBAction)onCancelButtonClicked:(id)sender {
  if ([self.delegate
          respondsToSelector:@selector(configVC:actionButtonClicked:data:)]) {
    [self.delegate configVC:self actionButtonClicked:NO data:nil];
  }
}

- (IBAction)onOkButtonClicked:(id)sender {
  NSString *title = [_watermarkTitle stringValue];
  if (title == nil || [title compare:@""] == NSOrderedSame) {
    [self showAlert:@"Title is missing"];
    return;
  }

  TextWaterMarkConfig *data;
  if (self.existedConfig) {
    data = self.existedConfig;
  } else {
    data = [[TextWaterMarkConfig alloc] init];
  }
  data.title = title;
  data.font = _selectedFont;
  data.color = self.colorWell.color;
  if ([self.delegate
          respondsToSelector:@selector(configVC:actionButtonClicked:data:)]) {
    [self.delegate configVC:self actionButtonClicked:YES data:data];
  }
}

- (void)showAlert:(NSString *)title {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert setMessageText:title];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

- (IBAction)onColorWellClicked:(id)sender {
  [self.watermarkTitle resignFirstResponder];
  [self refreshSampleText];
}

- (IBAction)onChangeFont:(id)sender {
  [self.watermarkTitle resignFirstResponder];
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  [fontManager setTarget:self];
  [fontManager orderFrontFontPanel:self];
  [self refreshSampleText];
}

- (void)changeFont:(id)sender {
  NSFont *font = [NSFont boldSystemFontOfSize:12];
  _selectedFont = [sender convertFont:font];
  [self refreshSampleText];
}

-(void)changeAttributes:(id)sender{
	
}

- (BOOL)control:(NSControl *)control
    textShouldEndEditing:(NSText *)fieldEditor {
  self.sampleTextField.stringValue = fieldEditor.string;
  [self refreshSampleText];
  return YES;
}

- (void)refreshSampleText {
  self.sampleTextField.stringValue = self.watermarkTitle.stringValue
                                         ? self.watermarkTitle.stringValue
                                         : @"Sample";
  self.sampleTextField.textColor = self.colorWell.color;
  self.sampleTextField.font = _selectedFont;
}
@end
