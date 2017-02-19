//  Copyright © 2016 MyScript. All rights reserved.

#import "ViewController.h"

#import <ATKDiagramWidget/DIWDiagramWidget.h>

#import "MyCertificate.h"

@interface ViewController () <DIWDiagramViewDelegate>

@property (strong, nonatomic) IBOutlet DIWDiagramView *diagramView;

@property (assign, nonatomic) BOOL isValidCertificate;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configure];
}

#pragma mark - Diagram Widget configuration

- (void)configure
{
    // Register MyScript certificate
    NSData  *certificate = [NSData dataWithBytes:myCertificate.bytes length:myCertificate.length];

    _isValidCertificate = [_diagramView registerCertificate:certificate];

    if (_isValidCertificate)
    {
        _diagramView.delegate = self;
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *bundlePath = [mainBundle pathForResource:@"resources" ofType:@"bundle"];
        bundlePath = [bundlePath stringByAppendingPathComponent:@"conf/"];
        
        [_diagramView addSearchDir:bundlePath];
        [_diagramView configureWithBundle:@"en_US" config:@"cur_text" extendedConf:@""];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_isValidCertificate)
    {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)undo:(id)sender
{
    [_diagramView undo];
}

- (IBAction)redo:(id)sender
{
    [_diagramView redo];
}

- (IBAction)clear:(id)sender
{
    [_diagramView clear];
}

- (IBAction)convert:(id)sender
{
    [_diagramView beautify];
}

#pragma mark - Diagram Widget Delegate - Undo Redo

- (void)diagramViewDidChangeUndoRedoState:(DIWDiagramView *)diagramView
{
    NSLog(@"Diagram undo/redo state");
}

- (void)diagramView:(DIWDiagramView *)diagramView didFailWithError:(NSError *)error
{
    NSLog(@"Diagram error (%@)", [error localizedDescription]);
}

#pragma mark - Diagram Widget Delegate - Recognition

- (void)diagramViewDidSessionStart:(DIWDiagramView *)diagramView
{
    NSLog(@"Diagram session begin");
}

- (void)diagramViewDidSessionEnd:(DIWDiagramView *)diagramView
{
    NSLog(@"Diagram session end");
}

#pragma mark - Diagram Widget Delegate - Writing

- (void)diagramView:(DIWDiagramView *)diagramView didPenDownWithCaptureInfo:(DIWCaptureInfo *)captureInfo
{
    NSLog(@"Diagram writing begin");
}

- (void)diagramView:(DIWDiagramView *)diagramView didPenMoveWithCaptureInfo:(DIWCaptureInfo *)captureInfo
{
    NSLog(@"Diagram writing continue");
}

- (void)diagramView:(DIWDiagramView *)diagramView didPenUpWithCaptureInfo:(DIWCaptureInfo *)captureInfo
{
    NSLog(@"Diagram writing end");
}

@end
