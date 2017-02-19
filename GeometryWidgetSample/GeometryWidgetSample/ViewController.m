//
//  ViewController.m
//  GeometryWidgetSample
//
//  Copyright © 2016 MyScript. All rights reserved.
//

#import "MyCertificate.h"
#import "ViewController.h"

@interface ViewController () <UIAlertViewDelegate>

@property (assign, nonatomic) int64_t inputUniqueId;
@property (strong, nonatomic) NSString *existingText;
@property (assign, nonatomic) float existingValue;
@property (strong, nonatomic) UIAlertView *lengthInput;
@property (strong, nonatomic) UIAlertView *angleInput;
@property (strong, nonatomic) UIAlertView *labelInput;

@end

@implementation ViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    _isValidCertificate = YES;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Register MyScript certificate
        NSData  *certificate = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];
      
        // Create the Geometry View
        _geometryView = [[GWGeometryView alloc] init];
      
        _isValidCertificate = [_geometryView registerCertificate:certificate];
      
        if (!_isValidCertificate)
          return self;
      
        // Register as delegate to be notified of recognition, configuration, writing...
        _geometryView.delegate = self;
        
        // Configure equation recognition engine
        [self configure];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_isValidCertificate) {
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

    // Use the Geometry View as our controller view
    self.view = _geometryView;
}

#pragma mark - Geometry Widget configuration

- (void)configure
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundlePath = [mainBundle pathForResource:@"resources" ofType:@"bundle"];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"conf/"];
  
    [_geometryView addSearchDir:bundlePath];
    [_geometryView configureWithBundle:@"shape" andConfig:@"standard"];
}

#pragma mark - Geometry Widget clear

- (void)clear
{
  [_geometryView clear:YES];
}

#pragma mark - Geometry Widget Delegate - Configuration

- (void)geometryViewDidBeginConfiguration:(GWGeometryView *)geomView
{
    NSLog(@"Geometry View configuration begin");
}

- (void)geometryViewDidEndConfiguration:(GWGeometryView *)geomView
{
    NSLog(@"Geometry View configuration succeeded");
}

- (void)geometryView:(GWGeometryView *)geomView didFailConfigurationWithError:(NSError *)error
{
    NSLog(@"Geometry View configuration failed (%@)", [error localizedDescription]);
}

#pragma mark - Geometry Widget Delegate - Recognition

- (void)geometryViewDidBeginRecognition:(GWGeometryView *)geomView
{
    NSLog(@"Geometry View recognition begin");
}

- (void)geometryViewDidEndRecognition:(GWGeometryView *)geomView
{
    NSLog(@"Geometry View recognition end");
}

#pragma mark - Geometry Widget Delegate - Undo Redo

- (void)geometryViewDidChangeUndoRedoState:(GWGeometryView *)geomView
{
    NSLog(@"Undo Redo state changed");
}

#pragma mark - Geometry Widget Delegate - Writing

- (void)geometryView:(GWGeometryView *)geometryView didPenDownWithCaptureInfo:(GWCaptureInfo *)captureInfo
{
    NSLog(@"Geometry writing begin");
}

- (void)geometryView:(GWGeometryView *)geometryView didPenMoveWithCaptureInfo:(GWCaptureInfo *)captureInfo
{
    NSLog(@"Geometry writing continue");
}

- (void)geometryView:(GWGeometryView *)geometryView didPenUpWithCaptureInfo:(GWCaptureInfo *)captureInfo
{
    NSLog(@"Geometry writing end");
}

#pragma mark - Geometry Widget Delegate - Edition

- (void)geometryViewDidBeginEditingLengthValue:(GWGeometryView *)geometryView existingValue:(float)value position:(CGPoint)position uniqueId:(int64_t)uniqueId
{
  dispatch_async(dispatch_get_main_queue(), ^{
    _lengthInput = [[UIAlertView alloc] initWithTitle:@"Length input" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Apply", nil ];
    _inputUniqueId = uniqueId;
    _lengthInput.alertViewStyle = UIAlertViewStylePlainTextInput;
    _existingValue = value;
    UITextField * alertTextField = [_lengthInput textFieldAtIndex:0];
    _existingText = [NSString stringWithFormat:@"%.2f", value];
    alertTextField.text = _existingText;
    alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
    [alertTextField becomeFirstResponder];
    [_lengthInput show];
  });
}


- (void)geometryViewDidBeginEditingAngleValue:(GWGeometryView *)geometryView existingValue:(float)value position:(CGPoint)position uniqueId:(int64_t)uniqueId
{
  dispatch_async(dispatch_get_main_queue(), ^{
    _angleInput = [[UIAlertView alloc] initWithTitle:@"Angle input" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Apply", nil ];
    _inputUniqueId = uniqueId;
    _angleInput.alertViewStyle = UIAlertViewStylePlainTextInput;
    _existingValue = value;
    UITextField * alertTextField = [_angleInput textFieldAtIndex:0];
    float existingDegrees = 180.0f * value / M_PI;
    _existingText = [NSString stringWithFormat:@"%.2f", existingDegrees];
    alertTextField.text = _existingText;
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_angleInput show];
  });
}

- (void)geometryViewDidBeginEditingLabel:(GWGeometryView *)geometryView existingLabel:(NSString*)label position:(CGPoint)position uniqueId:(int64_t)uniqueId
{
  dispatch_async(dispatch_get_main_queue(), ^{
    _labelInput = [[UIAlertView alloc] initWithTitle:@"Label input" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Apply", nil ];
    _inputUniqueId = uniqueId;
    _labelInput.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [_labelInput textFieldAtIndex:0];
    alertTextField.text = label;
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    [_labelInput show];
  });
  
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != 1)
  {
    // if cancelled
    [_geometryView undo];
    return;
  }
  
  UITextField * alertTextField = [alertView textFieldAtIndex:0];
  
  if (_lengthInput == alertView)
  {
    float value = 0.f;
    if([_existingText compare:alertTextField.text] == 0)
      value = _existingValue;
    else
      value = [alertTextField.text floatValue];
    [_geometryView setValue:value uniqueId:_inputUniqueId];
  }
  else if (_angleInput == alertView)
  {
    float value;
    if ([_existingText compare:alertTextField.text] == 0)
    {
      value = _existingValue;
    }
    else
    {
      float valueDegrees = [alertTextField.text floatValue];
      value = M_PI * valueDegrees / 180.0f;
    }
    [_geometryView setValue:value uniqueId:_inputUniqueId];
  }
  else if (_labelInput == alertView)
  {
    [_geometryView setEditLabel:alertTextField.text uniqueId:_inputUniqueId];
  }
}


@end