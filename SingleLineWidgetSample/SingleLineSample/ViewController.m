// Copyright MyScript. All rights reserved.


#import "ViewController.h"
#import "MyCertificate.h"

#define CANDIDATE_LAYOUT_MARGIN             5
#define CANDIDATE_LAYOUT_HEIGHT             55
#define CANDIDATE_BUTTON_MARGIN             3
#define CANDIDATE_BUTTON_HEIGHT             30
#define CANDIDATE_MIN_WIDTH                 60
#define CANDIDATE_FONT_SIZE                 18
#define CANDIDATE_LABEL_COLOR               [UIColor colorWithRed:0.200f green:0.710f blue:0.898f alpha:1.0f]

@interface ViewController ()

@property (nonatomic, readwrite) IMCandidateInfo *candidateInfo;
@property (nonatomic, readwrite) CGFloat          candidatesLayoutHeight;
@property (nonatomic)            UIButton        *moreCandidates;
@property (nonatomic, assign)    BOOL             isRegistered;
@property (nonatomic, assign)    BOOL             isCorrectionMode;
@property (nonatomic, assign)    NSInteger        cursorIndex;

@end

@implementation ViewController


- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  // Widget registration
  NSData *certificate = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
  _isRegistered = [self.singleLineWidget registerCertificate:certificate];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (!_isRegistered)
  {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Invalid certificate"
                                          message:@"Please use a valid certificate."
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                 exit(-1);
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return;
  }
  
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSString *bundlePath = [mainBundle pathForResource:@"resources" ofType:@"bundle"];
  bundlePath = [bundlePath stringByAppendingPathComponent:@"conf"];
  
  [self.singleLineWidget addSearchDir:bundlePath];
  
  [self.singleLineWidget setWordCandidateListSize:5];
  [self.singleLineWidget setCharacterCandidateListSize:5];
  
  [self.singleLineWidget configureWithBundle:@"en_US" andConfig:@"cur_text"];
  
  self.singleLineWidget.delegate = self;
  
  [self.singleLineWidget setInkColor:[UIColor colorWithRed:0.200f green:0.710f blue:0.898f alpha:1.0f]];
  
  self.isCorrectionMode = NO;
  self.cursorIndex = 0;
  
  self.textView.delegate = self;
  self.candidatesLayoutHeight = CANDIDATE_BUTTON_HEIGHT;
  
  _moreCandidates = [UIButton buttonWithType:UIButtonTypeCustom];
  [_moreCandidates addTarget:self action:@selector(candidatesView:) forControlEvents:UIControlEventTouchUpInside];
  [_moreCandidates setTitle:@"🔽" forState:UIControlStateNormal];
  _moreCandidates.frame = CGRectMake((self.candidateLayout.frame.size.width - 40), 0, 30, 30);
  _moreCandidates.tag = 999;
  _moreCandidates.hidden = YES;
  [_candidateLayout addSubview:_moreCandidates];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// Candidates bar

- (void)updateCandidates {
  
  int index = self.singleLineWidget.cursorIndex;
  
  self.candidateInfo = [self.singleLineWidget wordCandidatesAtIndex:(index - 1)];
  
  if (self.candidateInfo.labels.count == 0) {
    [self.singleLineWidget clearSelection];
  } else {
    [self.singleLineWidget selectWord:(index - 1)];
  }
  
  for (UIView *view in self.candidateLayout.subviews) {
    if (view.tag != 999) {
      [view removeFromSuperview];
    }
  }
  
  _moreCandidates.hidden = YES;
  
  CGFloat w = 0;
  CGFloat h = 0;
  
  if (self.candidateInfo != nil) {
    w += CANDIDATE_LAYOUT_MARGIN;
    
    for (int i=0; i<self.candidateInfo.labels.count; i++) {
      NSString *label = self.candidateInfo.labels[i];
      UIButton *button = [self candidateButtonWithTag:i label:label];
      
      CGFloat x = w;
      CGFloat width = CANDIDATE_MIN_WIDTH;
      CGFloat y = h + ((CANDIDATE_LAYOUT_HEIGHT - CANDIDATE_BUTTON_HEIGHT) / 2);
      
      button.backgroundColor = [UIColor colorWithRed:0.941 green:0.941 blue:0.941 alpha:1];
      
      [self.candidateLayout addSubview:button];
      
      if (button.frame.size.width < CANDIDATE_MIN_WIDTH) {
        w += CANDIDATE_MIN_WIDTH + 10.0f;
      } else {
        w += button.frame.size.width + 10.0f;
        width = button.frame.size.width;
      }
      
      if (y <= self.candidateLayout.frame.size.height) {
        button.frame = CGRectMake(x, y, width, CANDIDATE_BUTTON_HEIGHT);
        button.hidden = NO;
      } else {
        button.hidden = YES;
      }
      
      if (((x + CANDIDATE_MIN_WIDTH * 2) > (self.candidateLayout.frame.size.width - 60)) && (i != self.candidateInfo.labels.count - 1)) {
        w = CANDIDATE_LAYOUT_MARGIN;
        h += CANDIDATE_LAYOUT_HEIGHT;
        _moreCandidates.hidden = NO;
      }
    }
    self.candidatesLayoutHeight = CANDIDATE_LAYOUT_HEIGHT + h;
    w += CANDIDATE_LAYOUT_MARGIN;
  }
}

- (UIButton *)candidateButtonWithTag:(NSInteger)tag label:(NSString *)label {
  
  NSString *titleString = label;
  
  NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:titleString];
  [title addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:CANDIDATE_FONT_SIZE] range:NSMakeRange(0, label.length)];
  [title addAttribute:NSForegroundColorAttributeName value:CANDIDATE_LABEL_COLOR range:NSMakeRange(0, label.length)];
  [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:CANDIDATE_FONT_SIZE] range:NSMakeRange(0, label.length)];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.tag = tag;
  button.bounds = CGRectMake(0, 0, title.size.width + CANDIDATE_BUTTON_MARGIN * 2, CANDIDATE_BUTTON_HEIGHT);
  [button setAttributedTitle:title forState:UIControlStateNormal];
  [button addTarget:self action:@selector(candidateButtonTap:) forControlEvents:UIControlEventTouchUpInside];
  
  return button;
}

- (void)candidateButtonTap:(UIView *)sender {
  NSString *label = self.candidateInfo.labels[sender.tag];
  
  [self.singleLineWidget replaceCharactersInRange:self.candidateInfo.range withText:label];
}

// Buttons
- (IBAction)deleteButtonTap:(id)sender {
  NSString *text = self.singleLineWidget.text;
  NSUInteger index = self.singleLineWidget.cursorIndex;
  
  if (text.length == 0) {
    NSLog(@"Widget text is empty, canceling delete");
    return;
  }
  if (index == 0) {
    NSLog(@"Widget insert index at start of text, canceling delete");
    return;
  }
  if (index > text.length) {
    return;
  }
  self.cursorIndex = (int)index - 1;
  NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:(self.cursorIndex)];
  BOOL isReplace = [self.singleLineWidget replaceCharactersInRange:range withText:@""];
  if (isReplace) {
    [self.singleLineWidget setCursorIndex:(int)(self.cursorIndex)];
    self.isCorrectionMode = YES;
  }
}

- (IBAction)spaceButtonTap:(id)sender {
  self.cursorIndex = self.singleLineWidget.cursorIndex;
  BOOL isReplace = [self.singleLineWidget replaceCharactersInRange:NSMakeRange(self.cursorIndex, 0) withText:@" "];
  if (isReplace) {
    self.cursorIndex++;
    [self.singleLineWidget setCursorIndex:(int)(self.cursorIndex)];
    self.isCorrectionMode = YES;
  }
}

- (IBAction)clearButtonTap:(id)sender {
  _moreCandidates.hidden = YES;
  [self.singleLineWidget clear];
  [self.textView setText:@""];
  self.cursorIndex = 0;
  self.isCorrectionMode = NO;
}

- (IBAction)smileyButtonTap:(id)sender {
  
  [self.singleLineWidget replaceCharactersInRange:NSMakeRange(self.singleLineWidget.cursorIndex, 0) withText:@":-)"];
}

- (IBAction)candidatesView:(id)sender {
  CGFloat height = CANDIDATE_LAYOUT_HEIGHT;
  if (self.candidatesLayoutHeight > height) {
    height = self.candidatesLayoutHeight;
  }
  if (self.candidateLayout.frame.size.height == height) {
    height = CANDIDATE_LAYOUT_HEIGHT;
  }
  self.candidateLayout.frame = CGRectMake(self.candidateLayout.frame.origin.x, self.candidateLayout.frame.origin.y, self.candidateLayout.frame.size.width, height);
  [self updateCandidates];
  _moreCandidates.hidden = NO;
}

// SingleLineWidget Delegate

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didChangeText:(NSString*)text intermediate:(BOOL)intermediate {
  [self.singleLineWidget setCursorIndex:(int)text.length];
  [self.textView setText:text];
  self.candidatesLayoutHeight = CANDIDATE_LAYOUT_HEIGHT;
  [self candidatesView:self];
  if (!self.isCorrectionMode) {
    [self.singleLineWidget setCursorIndex:(int)self.textView.text.length];
  } else {
    [self.singleLineWidget setCursorIndex:(int)self.cursorIndex];
  }
  self.isCorrectionMode = NO;
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectSingleTapAtIndex:(int)index {
  self.cursorIndex = index;
  [self.singleLineWidget setCursorIndex:(int)self.cursorIndex];
  [self.singleLineWidget scrollToCursor];
  [self updateCandidates];
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectLongPressAtIndex:(int)index {
  self.cursorIndex = index;
  [self.singleLineWidget setCursorIndex:(int)self.cursorIndex];
  [self.singleLineWidget scrollToCursor];
  [self updateCandidates];
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectOverwriteStart:(int)start end:(int)end {
  self.cursorIndex = end;
  [self.singleLineWidget setCursorIndex:(int)self.cursorIndex];
  self.isCorrectionMode = YES;
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectReturnGestureAtIndex:(int)index {
  [self.singleLineWidget replaceCharactersInRange:NSMakeRange(index, 0) withText:@"\n"];
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectEraseGestureStart:(int)start end:(int)end {
  self.cursorIndex = start;
  [self.singleLineWidget setCursorIndex:(int)self.cursorIndex];
  self.isCorrectionMode = YES;
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectSelectGestureStart:(int)start end:(int)end {
  
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectUnderlineGestureStart:(int)start end:(int)end {
  
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectJoinGestureStart:(int)start end:(int)end {
  self.cursorIndex = start;
  [self.singleLineWidget replaceCharactersInRange:NSMakeRange(start, (end - start)) withText:nil];
  [self.singleLineWidget setCursorIndex:(int)self.cursorIndex];
  self.isCorrectionMode = YES;
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didDetectInsertGestureAtIndex:(int)index {
  [self.singleLineWidget replaceCharactersInRange:NSMakeRange(index, 0) withText:@" "];
  self.cursorIndex = index + 1;
  [self.singleLineWidget setCursorIndex:(int)(self.cursorIndex)];
  self.isCorrectionMode = YES;
}

- (void)singleLineWidgetPenDown:(SLTWSingleLineWidget *)sender didCaptureInfo:(IMCaptureInfo *)captureInfo {
  
}

- (void)singleLineWidgetPenUp:(SLTWSingleLineWidget *)sender didCaptureInfo:(IMCaptureInfo *)captureInfo {
  
}

- (void)singleLineWidgetPenMove:(SLTWSingleLineWidget  *)sender didCaptureInfo:(IMCaptureInfo *)captureInfo {
  
}

- (void)singleLineWidgetPenAbort:(SLTWSingleLineWidget  *)sender {
  
}

- (void)singleLineWidget:(SLTWSingleLineWidget *)sender didConfigureWithSuccess:(BOOL)success {
  NSLog(@"singleLineWidgetDidConfigureWithSuccess:%@", success ? @"YES" : @"NO");
}

- (void)singleLineWidgetUserScrollBegin:(SLTWSingleLineWidget*)sender {
  
}

- (void)singleLineWidgetUserScrollEnd:(SLTWSingleLineWidget*)sender {
  
}

- (void)singleLineWidgetUserScroll:(SLTWSingleLineWidget*)sender {
  [self.singleLineWidget moveCursorToVisibleIndex];
  self.cursorIndex = self.singleLineWidget.cursorIndex - 1;
  [self.singleLineWidget selectWord:(self.cursorIndex)];
}

// UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
  
}


- (void)textViewDidChangeSelection:(UITextView *)textView {
  NSInteger index = self.textView.selectedRange.location + self.textView.selectedRange.length;
  if (([self.singleLineWidget cursorIndex] == index) || (self.isCorrectionMode)) {
    // do nothing
  } else {
    [self.singleLineWidget setCursorIndex:(int)index];
    if (index == self.singleLineWidget.text.length) {
      [self.singleLineWidget scrollTo:(int)index];
    } else {
      [self.singleLineWidget centerTo:(int)index];
    }
  }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  return YES;
}

@end
