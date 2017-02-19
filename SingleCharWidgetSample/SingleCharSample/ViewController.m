// Copyright MyScript. All rights reserved.


#import "ViewController.h"
#import "MyCertificate.h"

#define CANDIDATE_LAYOUT_MARGIN             5
#define CANDIDATE_LAYOUT_HEIGHT             50
#define CANDIDATE_BUTTON_MARGIN             3
#define CANDIDATE_BUTTON_HEIGHT             30
#define CANDIDATE_MIN_WIDTH                 60
#define CANDIDATE_FONT_SIZE                 18
#define CANDIDATE_LABEL_COLOR               [UIColor colorWithRed:0.200f green:0.710f blue:0.898f alpha:1.0f]
#define CANDIDATE_COMPLETION_COLOR          [UIColor colorWithRed:0.000f green:0.000f blue:0.000f alpha:1.0f]

@interface ViewController () <SCWSingleCharWidgetDelegate>

@property (nonatomic, readwrite) IMCandidateInfo *candidateInfo;
@property (nonatomic, readwrite) CGFloat          candidatesLayoutHeight;
@property (nonatomic, assign)    BOOL             isRegistered;

@end

@implementation ViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Widget registration
  NSData *certificate = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
  _isRegistered = [self.singleCharWidget registerCertificate:certificate];
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
  
  [self.singleCharWidget setInkColor:[UIColor colorWithRed:0.200f green:0.710f blue:0.898f alpha:1.0f]];
  [self.singleCharWidget setInkWidth:7.0f];
  [self.singleCharWidget setWordCandidateListSize:5];
  
  [self.singleCharWidget addSearchDir:bundlePath];
  [self.singleCharWidget configureWithBundle:@"en_US" andConfig:@"si_text"];
  
  self.singleCharWidget.delegate = self;
  self.candidatesLayoutHeight = CANDIDATE_BUTTON_HEIGHT;
  
  [self.textView setEditable:NO];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// SingleCharWidget Delegate

- (void)singleCharWidget:(SCWSingleCharWidget *)sender didChangeText:(NSString*)text intermediate:(BOOL)intermediate {
  [self.textView setText:text];
  [self updateCandidates];
}

- (BOOL)singleCharWidget:(SCWSingleCharWidget *)sender didDetectSingleTapAtPoint:(CGPoint)point {
  // we don't handle the gesture
  return NO;
}

- (BOOL)singleCharWidget:(SCWSingleCharWidget *)sender didDetectLongPressAtPoint:(CGPoint)point {
  // we don't handle the gesture
  return NO;
}

- (void)singleCharWidget:(SCWSingleCharWidget *)sender didDetectBackspaceAtIndex:(NSUInteger)index withCount:(NSUInteger)count {
  // simulate a tap on the delete button
  [self deleteButtonTap:nil];
}

- (void)singleCharWidget:(SCWSingleCharWidget *)sender didDetectReturnAtIndex:(NSUInteger)index {
  [self.singleCharWidget replaceCharactersInRange:NSMakeRange(index, 0) withText:@"\n"];
}

- (void)singleCharWidget:(SCWSingleCharWidget *)sender didConfigureWithSuccess:(BOOL)success {
  NSLog(@"singleCharWidgetDidConfigureWithSuccess:%@", success ? @"YES" : @"NO");
}

- (void)singleCharWidgetPenDown:(SCWSingleCharWidget *)sender didCaptureInfo:(IMCaptureInfo *)captureInfo {

}

- (void)singleCharWidgetPenUp:(SCWSingleCharWidget *)sender didCaptureInfo:(IMCaptureInfo *)captureInfo {

}

- (void)singleCharWidgetPenMove:(SCWSingleCharWidget  *)sender didCaptureInfo:(IMCaptureInfo *)captureInfo {

}

- (void)singleCharWidgetPenAbort:(SCWSingleCharWidget  *)sender {

}

// Candidates bar

- (void)updateCandidates {
  
  NSUInteger index = self.singleCharWidget.insertIndex;
  
  self.candidateInfo = [self.singleCharWidget wordCandidatesAtIndex:(index - 1)];
    
  for (UIView *view in self.candidateLayout.subviews) {
    if (view.tag != 999) {
      [view removeFromSuperview];
    }
  }
  
  CGFloat w = 0;
  CGFloat h = 0;
  
  if (self.candidateInfo != nil) {
    w += CANDIDATE_LAYOUT_MARGIN;
    
    for (int i=0; i<self.candidateInfo.labels.count; i++) {
      NSString *label = self.candidateInfo.labels[i];
      NSString *completion = self.candidateInfo.completions[i];
      UIButton *button = [self candidateButtonWithTag:i label:label completion:completion];
      
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
      
      if ((x + CANDIDATE_MIN_WIDTH + (CANDIDATE_BUTTON_MARGIN * 2)) >= (self.candidateLayout.frame.size.width - 60)) {
        w = CANDIDATE_LAYOUT_MARGIN;
        h += CANDIDATE_LAYOUT_HEIGHT;
      }
    }
    self.candidatesLayoutHeight = CANDIDATE_LAYOUT_HEIGHT + h;
    w += CANDIDATE_LAYOUT_MARGIN;
  }
}

- (UIButton *)candidateButtonWithTag:(NSInteger)tag label:(NSString *)label completion:(NSString *)completion {
  
  NSString *titleString = [label stringByAppendingString:completion];
  
  NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:titleString];
  [title addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:CANDIDATE_FONT_SIZE] range:NSMakeRange(0, label.length)];
  [title addAttribute:NSForegroundColorAttributeName value:CANDIDATE_LABEL_COLOR range:NSMakeRange(0, label.length)];
  [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:CANDIDATE_FONT_SIZE] range:NSMakeRange(label.length, completion.length)];
  [title addAttribute:NSForegroundColorAttributeName value:CANDIDATE_COMPLETION_COLOR range:NSMakeRange(label.length, completion.length)];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.tag = tag;
  button.bounds = CGRectMake(0, 0, title.size.width + CANDIDATE_BUTTON_MARGIN * 2, CANDIDATE_BUTTON_HEIGHT);
  [button setAttributedTitle:title forState:UIControlStateNormal];
  [button addTarget:self action:@selector(candidateButtonTap:) forControlEvents:UIControlEventTouchUpInside];
  
  return button;
}

- (void)candidateButtonTap:(UIView *)sender {
  NSString *label = self.candidateInfo.labels[sender.tag];
  NSString *completion = self.candidateInfo.completions[sender.tag];
  
  [self.singleCharWidget replaceCharactersInRange:self.candidateInfo.range withText:[label stringByAppendingString:completion]];
}

// Buttons
- (IBAction)deleteButtonTap:(id)sender {
  
  NSString *text = self.singleCharWidget.text;
  NSUInteger index = self.singleCharWidget.insertIndex;
  
  if (text.length == 0) {
    NSLog(@"Widget text is empty, canceling delete");
    return;
  }
  if (index == 0) {
    NSLog(@"Widget insert index at start of text, canceling delete");
    return;
  }
  
  NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:(index - 1)];
  [self.singleCharWidget replaceCharactersInRange:range withText:@""];
}

- (IBAction)spaceButtonTap:(id)sender {
  
  [self.singleCharWidget insertString:@" "];
}

- (IBAction)clearButtonTap:(id)sender {
  
  [self.singleCharWidget clear];
}

- (IBAction)smileyButtonTap:(id)sender {
  
  [self.singleCharWidget insertString:@":-)"];
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
}

@end
