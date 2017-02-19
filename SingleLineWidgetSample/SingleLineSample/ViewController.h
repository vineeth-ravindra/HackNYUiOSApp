// Copyright MyScript. All rights reserved.

#import <UIKit/UIKit.h>

#import <ATKSingleLineWidget/SLTWSingleLineWidget.h>
#import <ATKSingleLineWidget/SLTWSingleLineWidgetDelegate.h>

@interface ViewController : UIViewController<SLTWSingleLineWidgetDelegate, UITextViewDelegate>

@property (nonatomic) IBOutlet UITextView *textView;

@property (nonatomic) IBOutlet SLTWSingleLineWidget *singleLineWidget;

@property (nonatomic) IBOutlet UIScrollView *candidateLayout;

- (IBAction)deleteButtonTap:(id)sender;
- (IBAction)spaceButtonTap:(id)sender;
- (IBAction)clearButtonTap:(id)sender;
- (IBAction)smileyButtonTap:(id)sender;
- (IBAction)candidatesView:(id)sender;

@end

