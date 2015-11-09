//
//  AppDelegate.m
//  MOMLAppViewer
//
//  Created by MOSPI on 13. 2. 21..
//  Copyright (c) 2013 mospi.org. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface UIAlertView(EnumView)

+ (void)startInstanceMonitor;
+ (void)stopInstanceMonitor;
+ (void)dismissAll;
@end

@implementation UIAlertView(EnumView)
static BOOL _isInstanceMonitorStarted = NO;

+ (NSMutableArray *)instances
{
    static NSMutableArray *array = nil;
    if (array == nil)
        array = [NSMutableArray array];
    
    return array;
}


- (void)_newInit
{
    [[UIAlertView instances] addObject:[NSValue valueWithNonretainedObject:self]];
    [self _oldInit];
}

- (void)_oldInit
{
    // dummy method for replacing IMP.
}

- (void)_newDealloc
{
    [[UIAlertView instances] removeObject:[NSValue valueWithNonretainedObject:self]];
    [self _oldDealloc];
    
}
- (void)_oldDealloc
{
    // dummy method for replacing IMP.
}

static void replaceMethod(Class c, SEL old, SEL new)
{
    Method newMethod = class_getInstanceMethod(c, new);
    class_replaceMethod(c, old, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
}

+ (void)startInstanceMonitor
{
    if (!_isInstanceMonitorStarted) {
        _isInstanceMonitorStarted = YES;
        replaceMethod(UIAlertView.class, @selector(_oldInit), @selector(init));
        replaceMethod(UIAlertView.class, @selector(init), @selector(_newInit));
        
        replaceMethod(UIAlertView.class, @selector(_oldDealloc), NSSelectorFromString(@"dealloc"));
        replaceMethod(UIAlertView.class, NSSelectorFromString(@"dealloc"), @selector(_newDealloc));
    }
}

+ (void)stopInstanceMonitor
{
    if (_isInstanceMonitorStarted) {
        _isInstanceMonitorStarted = NO;
        replaceMethod(UIAlertView.class, @selector(init), @selector(_oldInit));
        replaceMethod(UIAlertView.class, NSSelectorFromString(@"dealloc"), @selector(_oldDealloc));
    }
}

+ (void)dismissAll
{
    for (NSValue *value in [UIAlertView instances]) {
        UIAlertView *view = [value nonretainedObjectValue];
        
        if ([view isVisible]) {
            [view dismissWithClickedButtonIndex:view.cancelButtonIndex animated:NO];
        }
    }
}
@end

@interface AppDelegate()
{
    BOOL _isBackground;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) &&
        ![[UIApplication sharedApplication] isStatusBarHidden])
    {
        self.window.rootViewController.view.frame = UIScreen.mainScreen.applicationFrame;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification *n) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.window.rootViewController.view.frame = UIScreen.mainScreen.applicationFrame;
                self.window.rootViewController.presentedViewController.view.frame = UIScreen.mainScreen.applicationFrame;
            }];
        }];
        
    }
    
    [UIAlertView startInstanceMonitor];
    
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

- (void)uriSchemeConfirmUrl:(NSString *)urlResourceSpecifier
{
    [UIAlertView dismissAll];
    _urlResourceSpecifier = urlResourceSpecifier;
    
    
    [_viewController uriSchemeConfirmUrl:_urlResourceSpecifier];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (_isBackground) {
        while ([_viewController presentedViewController]) {
            UIViewController *lastPresentedViewController = [_viewController presentedViewController];
            while ([lastPresentedViewController presentedViewController])
                lastPresentedViewController = [lastPresentedViewController presentedViewController];
            [lastPresentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }
    
    [self performSelector:@selector(uriSchemeConfirmUrl:) withObject:url.resourceSpecifier afterDelay:0];


    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    _isBackground = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _isBackground = NO;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
