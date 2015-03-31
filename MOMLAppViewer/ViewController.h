//
//  ViewController.h
//  MOMLAppViewer
//
//  Created by MOSPI on 13. 2. 21..
//  Copyright (c) 2013 mospi.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSMutableArray *_urls;
    NSInteger _deleteIndex;
    NSString *_confirmUrl;
    __weak IBOutlet UINavigationBar *_navigationBar;
    __weak IBOutlet UILabel *_bottomLabel;
}
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITableView *urlsTableView;
@property (weak, nonatomic) IBOutlet UISwitch *closeAppSwitch;
- (IBAction)onOpenClick:(id)sender;
- (IBAction)onCloseAppSwitchChanged:(id)sender;
- (void)openUrl:(NSString *)url;
- (void)uriSchemeConfirmUrl:(NSString *)url;
- (void)hideAppViewController;
@end
