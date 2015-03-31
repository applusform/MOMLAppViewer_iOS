//
//  AppViewController.m
//  MOMLAppViewer
//
//  Created by MOSPI on 13. 2. 21..
//  Copyright (c) 2013 mospi.org. All rights reserved.
//

#import "AppViewController.h"

@interface AppViewController ()

@end

@implementation AppViewController
@synthesize url = _url;
@synthesize openType = _openType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// return / appended url if it is able to connect.
- (NSString *)absUrlFromUrl:(NSString *)url
{
    NSString *lowerCaseUrl = [url lowercaseString];
    
    if ([lowerCaseUrl hasSuffix:@".xml"] || [lowerCaseUrl hasSuffix:@".html"] || [lowerCaseUrl hasSuffix:@".htm"])
        return url;
    
    if ([url hasSuffix:@"/"])
        return url;
    
    NSString *fullUrl = [url stringByAppendingString:@"/"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (response.statusCode ==200)
        return fullUrl;
    
    return url;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *absUrl = [self absUrlFromUrl:_url];
    if ([_openType isEqualToString:OpenType_APPLICATION]) {
        [self loadApplication:absUrl];
    } else if ([_openType isEqualToString:OpenType_MOMLUI]) {
        [self loadUrl:absUrl];
    } else if ([_openType isEqualToString:OpenType_HTML]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [self.momlView.root runScript:[NSString stringWithFormat:@"saveVariable.url='%@'", absUrl]];
        [self loadUrl:@"embed:/webView2.xml"];
    }
    
    UIView *edgeSwipeView = [[UIView alloc] init];
    
    CGFloat height = self.view.frame.size.height;
    edgeSwipeView.frame = CGRectMake(0, height - 100, 15, 100);
    edgeSwipeView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:edgeSwipeView];
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [edgeSwipeView addGestureRecognizer:recognizer];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.01]]; // for swipe on transparent view
    
    static BOOL isFirstTime = YES;
    
    if (isFirstTime) {
        isFirstTime = NO;
        [self performSelector:@selector(showGuideView) withObject:nil afterDelay:2];
    }
    
}

- (void)hideModalViewAnimated:(BOOL)ani
{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:ani];
    [[self getMomlView] removeFromSuperview];
    
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    [self hideModalViewAnimated:YES];
}

- (void)showGuideView
{

    CGFloat height = self.view.frame.size.height;
    UIImageView *guideView = [[UIImageView  alloc] init];
    
    [guideView setImage:[UIImage imageNamed:@"guide.png"]];
    
    guideView.frame = CGRectMake(0, height - 200, 300, 200);
    guideView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:guideView];
    
    [guideView setAlpha:0];
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.6];
    [guideView setAlpha:1];
    [UIView commitAnimations];

    [self performSelector:@selector(hideGuideView:) withObject:guideView afterDelay:5];

}

- (void)hideGuideView:(UIView *)view
{
    [UIView beginAnimations:NULL context:nil];
    [UIView setAnimationDuration:0.6];
    [view setAlpha:0];
    [UIView commitAnimations];
    
    [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)layoutStatusBar
{
    if ((floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) &&
        ![[UIApplication sharedApplication] isStatusBarHidden])
    {
        self.view.frame = UIScreen.mainScreen.applicationFrame;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIApplication sharedApplication] setStatusBarStyle:[self preferredStatusBarStyle]];
            self.view.frame = UIScreen.mainScreen.applicationFrame;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutStatusBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutStatusBar];
}

- (void)beginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated
{
    [super beginAppearanceTransition:isAppearing animated:animated];
    [self layoutStatusBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
