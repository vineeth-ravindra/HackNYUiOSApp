//
//  ViewController.h
//  MathWidgetTest
//
//  Copyright © 2016 MyScript. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ATKMathWidget/MAWMathWidget.h>

@interface ViewController : UIViewController <MAWMathViewDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) MAWMathView *mathView;
@property (assign, nonatomic) BOOL isValidCertificate;
@property (weak,nonatomic) NSString * postData;

- (void)clear;

@end
