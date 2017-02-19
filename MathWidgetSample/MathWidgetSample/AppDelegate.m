//
//  AppDelegate.m
//  MathWidgetSample
//
//  Copyright © 2016 MyScript. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window makeKeyAndVisible];
    
    // View controller encapsulating the Math View
    ViewController *viewController = [[ViewController alloc] init];

    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    // Add a clear button
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:viewController
                                                                   action:@selector(clear)];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:viewController
                                                                   action:@selector(send)];
    
    viewController.navigationItem.leftBarButtonItem = clearButton;
    viewController.navigationItem.rightBarButtonItem = sendButton;
    viewController.navigationItem.title              = @"Origin View";
    
    self.window.rootViewController = navigationController;
    
    return YES;
}

@end
