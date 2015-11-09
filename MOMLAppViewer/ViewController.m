//
//  ViewController.m
//  MOMLAppViewer
//
//  Created by MOSPI on 13. 2. 21..
//  Copyright (c) 2013 mospi.org. All rights reserved.
//

#import "ViewController.h"
#import "AppViewController.h"

#define kAlertView_DeleteUrl 1001
#define kAlertView_NewUrlConfirm 1002

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _deleteIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // bottom label
    {
        NSString *buildDate = [NSString stringWithFormat:@"%s", __DATE__]; // "Jun 24 2014" format
        NSDateFormatter *definedDateFormat = [[NSDateFormatter alloc] init];
        [definedDateFormat setDateFormat:@"MMM dd yyyy"];
        [definedDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
        NSDate *date = [definedDateFormat dateFromString:buildDate];
        
        NSDateFormatter *outputDateFormat = [[NSDateFormatter alloc] init];
        [outputDateFormat setDateFormat:@"yyyyMMdd"]; // "20140624" format
        NSString *outputDate = [outputDateFormat stringFromDate:date];
        
        if (outputDate == nil)
            outputDate = @"";
        
        [_bottomLabel setText:[NSString stringWithFormat:@"based on Citrine Developer build 1.1.8_%@ by mospi.org", outputDate]];
    }

    // title
    {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *title = [NSString stringWithFormat:@"MOML App Viewer %@", version];
        [[_navigationBar topItem] setTitle:title];
    }
    [self loadUrl];
    [_urlsTableView reloadData];
    [_urlTextField setText:[_urls objectAtIndex:0]];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    
    [_urlsTableView addGestureRecognizer:lpgr];
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

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_deleteIndex == -1) {
        CGPoint p = [gestureRecognizer locationInView:_urlsTableView];
        
        NSIndexPath *indexPath = [_urlsTableView indexPathForRowAtPoint:p];
        if (indexPath != nil) {
            _deleteIndex = indexPath.row;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete url" message:[_urls objectAtIndex:_deleteIndex] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alertView.tag = kAlertView_DeleteUrl;
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    if (tag == kAlertView_DeleteUrl) {
        if (_deleteIndex >= 0) {
            if (buttonIndex == 1) {
                [_urls removeObjectAtIndex:_deleteIndex];
                [self saveUrl];
                [_urlsTableView reloadData];
            }
        }
        _deleteIndex = -1;
    }
    
    if (tag == kAlertView_NewUrlConfirm) {
        if (buttonIndex == 1) {
            [self openUrl:_confirmUrl];
        }
        _confirmUrl = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)fullUrl:(NSString *)url
{
    if (!([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"embed:/"] || [url hasPrefix:@"storage:/"])) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    return url;
}

- (NSString *)estimateOpenType:(NSString *)text
{
    if (text != nil) {
        NSString* upperCaseText = [text uppercaseString];
        NSUInteger indexAppTag = [upperCaseText rangeOfString:@"<APPLICATIONINFO"].location;
        NSUInteger indexMomlUiTag = [upperCaseText rangeOfString:@"<UILAYOUT"].location;
        NSUInteger indexHTMLTag = [upperCaseText rangeOfString:@"<HTML"].location;
        
        if (indexAppTag != NSNotFound)
            return OpenType_APPLICATION;
        if (indexMomlUiTag != NSNotFound)
            return OpenType_MOMLUI;
        if (indexHTMLTag != NSNotFound)
            return OpenType_HTML;
    }
    
    return OpenType_UNKNOWN;
}


- (IBAction)onOpenClick:(id)sender {
    NSString *url = _urlTextField.text;
    [self openUrl:url];
}

- (void)openUrl:(NSString *)url
{
    NSString *fullUrl = [self fullUrl:url];
    NSString *finalUrl = fullUrl;
    NSString *openType = OpenType_UNKNOWN;
    
    if ([fullUrl hasPrefix:@"http://"] || [fullUrl hasPrefix:@"https://"]) {
        
        if (![fullUrl hasSuffix:@".xml"]) {
            NSString *applicationUrl;
            if ([finalUrl hasSuffix:@"/"])
                applicationUrl = [fullUrl stringByAppendingString:@"applicationInfo.xml"];
            else
                applicationUrl = [fullUrl stringByAppendingString:@"/applicationInfo.xml"];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:applicationUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (data) {
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (text == nil)
                    text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                openType = [self estimateOpenType:text];
                
                if ([openType isEqualToString:OpenType_APPLICATION])
                    finalUrl = [response.URL absoluteString];
            }
        }
        
        if (![openType isEqualToString:OpenType_APPLICATION]) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:finalUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (data) {
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (text == nil)
                    text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                openType = [self estimateOpenType:text];
            }
            if (response.statusCode !=200)
                openType = OpenType_ERROR;
            
            if (![openType isEqualToString:OpenType_ERROR] && ![openType isEqualToString:OpenType_UNKNOWN]){
                finalUrl = [response.URL absoluteString];
            }
            
            if ([openType isEqualToString:OpenType_ERROR]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find resource" message:[NSString stringWithFormat:@"HTTP error : %ld\r\n%@", (long)response.statusCode, fullUrl] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
    } else if ([fullUrl hasPrefix:@"embed:/"]) {
        NSString *bundlePath = [fullUrl substringFromIndex:7];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:bundlePath ofType:nil];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find resource" message:@"File not found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSString *text = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:nil error:nil];
        openType = [self estimateOpenType:text];
    } else if ([fullUrl hasPrefix:@"storage:/"]) {
        NSString *storagePath = [fullUrl substringFromIndex:9];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [paths objectAtIndex:0];
        NSString *filePath = [documentDir stringByAppendingPathComponent:storagePath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find resource" message:@"File not found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }

        NSString *text = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:nil error:nil];
        openType = [self estimateOpenType:text];
    }
    
    if ([openType isEqualToString:OpenType_UNKNOWN]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unknown resource type" message:@"can't detect file type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self addUrl:url];
    [_urlsTableView reloadData];
    
    
    [self presentAppViewController:openType url:finalUrl];
    //_appViewController = viewerController;
}

- (void)presentAppViewController:(NSString *)openType url:(NSString*)url
{
    AppViewController *viewerController = [[AppViewController alloc] init];
    viewerController.url = [self fullUrl:url];
    viewerController.openType = openType;
    
    UIViewController *modalParent = self;
    
    while (modalParent.presentedViewController)
        modalParent = modalParent.presentedViewController;
        
//    
//    if (_appViewControllers.count > 0)
//        modalParent = _appViewControllers.lastObject;
    
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        [modalParent presentViewController:viewerController animated:NO completion:nil];
    else
        [modalParent presentViewController:viewerController animated:NO completion:nil];
}

- (void)uriSchemeConfirmUrl:(NSString *)url
{
    if ([self isExistUrl:url]) {
        [self openUrl:url];
    } else {
        _confirmUrl = url;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New URL confirm" message:[NSString stringWithFormat:@"Do you trust:\n%@\n\nIf you don't trust this site, select [No] to exit", url] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = kAlertView_NewUrlConfirm;
        [alert show];
       
    }
}

- (void)viewDidUnload {
    [self setUrlsTableView:nil];
    [super viewDidUnload];
}

- (void)loadUrl
{
    _urls = [[NSMutableArray alloc] init];
    
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"urlCount"];
    
    if (count == 0) {
        [_urls addObject:@"mospi.org/momlApps/MOMLAPI"];
        [_urls addObject:@"mospi.org/momlApps/CitrineApiDemo"];
        [_urls addObject:@"mospi.org/momlApps/AgateApiDemo"];
        [_urls addObject:@"mospi.org/momlApps/AgateNews"];
        //[_urls addObject:@"mospi.org/momlApps/ExTheme"];
        [_urls addObject:@"mospi.org/momlApps/ReadMe"];
        return;
    }
    
    int i;
    
    for (i = 0; i < count; ++i) {
        NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"url_%d", i]];
        if (url != nil && [url length] > 0)
            [_urls addObject:url];
    }
}

- (void)saveUrl
{
    NSUInteger count = [_urls count];
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"urlCount"];
    int i;
    
    for (i = 0; i < count; ++i)
        [[NSUserDefaults standardUserDefaults] setValue:[_urls objectAtIndex:i] forKey:[NSString stringWithFormat:@"url_%d", i]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addUrl:(NSString *)url
{
    if (url == nil || [url isEqualToString:[_urls objectAtIndex:0]])
        return;
    
    if ([_urls containsObject:url])
        [_urls removeObject:url];
    
    [_urls insertObject:url atIndex:0];
    [self saveUrl];
}

- (BOOL)isExistUrl:(NSString *)url
{
    return [_urls containsObject:url];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_urls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    cell.textLabel.text = [_urls objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = [_urls objectAtIndex:indexPath.row];
    
    [_urlTextField setText:url];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationPortrait == interfaceOrientation;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



@end
