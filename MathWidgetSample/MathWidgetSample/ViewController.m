//
//  ViewController.m
//  MathWidgetSample
//
//  Copyright © 2016 MyScript. All rights reserved.
//

#import "MyCertificate.h"
#import "ViewController.h"

@implementation ViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.postData = [NSString stringWithFormat:@""];
    
    if (self)
    {
        // Register MyScript certificate
        NSData  *certificate = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
        
        
        // Create the Math View
        _mathView = [[MAWMathView alloc] init];
        _isValidCertificate = [_mathView registerCertificate:certificate];
        
        if(!_isValidCertificate)
            return self;
        
        // Register as delegate to be notified of recognition, configuration, writing...
        _mathView.delegate = self;
        
        // Configure equation recognition engine
        [self configure];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!_isValidCertificate) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Invalid certificate"
                                              message:@"Please use a valid certificate."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"Ok"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)loadView
{
    self.navigationController.navigationBar.translucent = NO;

    // Use the Math View as our controller view
    self.view = _mathView;
}

-(void) send {
    NSLog(@"Need to do some work");
    NSLog(@"%lu", (unsigned long)[self.postData length]);
    if ([self.postData length] >0) {
        NSData *postData = [self.postData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://demo.com/ap.in"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if(conn) {
            NSLog(@"Connection Successful");
            [conn start];
        } else {
            NSLog(@"Connection could not be made");
        }
    }
    self.postData = @"";
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSLog(@"Post Complete");
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection refused by server");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection Complete");
}


- (void)clear
{
  [_mathView clear:YES];
    self.postData = @"";
}

#pragma mark - Math Widget configuration

- (void)configure
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundlePath = [mainBundle pathForResource:@"resources" ofType:@"bundle"];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"conf/"];
  
    [_mathView addSearchDir:bundlePath];
    [_mathView configureWithBundle:@"math" andConfig:@"standard"];
}

#pragma mark - Math Widget Delegate - Configuration

- (void)mathViewDidBeginConfiguration:(MAWMathView *)mathView
{
    NSLog(@"Math View configuration begin");
}

- (void)mathViewDidEndConfiguration:(MAWMathView *)mathView
{
    NSLog(@"Math View configuration succeeded");
}

- (void)mathView:(MAWMathView *)mathView didFailConfigurationWithError:(NSError *)error
{
    NSLog(@"Math View configuration failed (%@)", [error localizedDescription]);
}

#pragma mark - Math Widget Delegate - Recognition

- (void)mathViewDidBeginRecognition:(MAWMathView *)mathView
{
    NSLog(@"Math View recognition begin");
}

- (void)mathViewDidEndRecognition:(MAWMathView *)mathView
{
    NSLog(@"Math View recognition end");
    self.postData  = mathView.resultAsMathML;
    NSLog(@"%@", self.postData);
}


#pragma mark - Math Widget Delegate - Solving

- (void)mathView:(MAWMathView *)mathView didChangeUsingAngleUnit:(BOOL)used
{
    if (used)
    {
        NSLog(@"Angle unit is used");
    }
    else
    {
        NSLog(@"Angle unit is not used");
    }
}

#pragma mark - Math Widget Delegate - Gesture

- (void)mathView:(MAWMathView *)mathView didPerformEraseGesture:(BOOL)partial
{
    NSString *gestureState = partial ? @"partial" : @"complete";
    
    NSLog(@"Erase gesture handled by current equation (%@)", gestureState);
}

#pragma mark - Math Widget Delegate - Undo Redo

- (void)mathViewDidChangeUndoRedoState:(MAWMathView *)mathView
{
    NSLog(@"Undo Redo state changed");
}

#pragma mark - Math Widget Delegate - Writing

- (void)mathView:(MAWMathView *)mathView didPenDownWithCaptureInfo:(MAWCaptureInfo *)captureInfo
{
    NSLog(@"Math writing begin");
}

- (void)mathView:(MAWMathView *)mathView didPenMoveWithCaptureInfo:(MAWCaptureInfo *)captureInfo
{
    NSLog(@"Math writing continue");
}

- (void)mathView:(MAWMathView *)mathView didPenUpWithCaptureInfo:(MAWCaptureInfo *)captureInfo
{
    NSLog(@"Math writing end");

}

#pragma - Math Widget Delegate - Recognition Timeout

- (void)mathViewDidReachRecognitionTimeout:(MAWMathView *)mathView
{
    NSLog(@"Recognition timeout reached");
}

@end
