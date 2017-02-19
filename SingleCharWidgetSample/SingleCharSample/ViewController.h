// Copyright MyScript. All rights reserved.


#import <UIKit/UIKit.h>

#import <ATKSingleCharWidget/SCWSingleCharWidget.h>
#import <ATKSingleCharWidget/SCWSingleCharWidgetDelegate.h>

@interface ViewController : UIViewController <SCWSingleCharWidgetDelegate>

@property (nonatomic) IBOutlet UITextView *textView;

@property (nonatomic) IBOutlet SCWSingleCharWidget *singleCharWidget;

@property (nonatomic) IBOutlet UIView *candidateLayout;

- (IBAction)deleteButtonTap:(id)sender;
- (IBAction)spaceButtonTap:(id)sender;
- (IBAction)clearButtonTap:(id)sender;
- (IBAction)smileyButtonTap:(id)sender;
- (IBAction)candidatesView:(id)sender;

@end

