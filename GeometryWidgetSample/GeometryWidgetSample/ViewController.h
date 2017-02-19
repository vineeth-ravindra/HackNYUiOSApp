//
//  ViewController.h
//  GeometryWidgetSample
//
//  Copyright © 2016 MyScript. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ATKGeometryWidget/GWGeometryWidget.h>

@interface ViewController : UIViewController <GWGeometryViewDelegate>

@property (strong, nonatomic) GWGeometryView *geometryView;
@property (assign, nonatomic) BOOL isValidCertificate;

@end
