//
//  Created by MoSPI.org on 11.16.2011
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOMLView.h"

@interface MOMLUIViewController : UIViewController

@property (nonatomic, strong) IBOutlet MOMLView* momlView;

- (void)setHandler:(id<MOMLUIObjectDelegate>)delegate;
- (void)loadApplication:(NSString *)url;
- (void)loadUrl:(NSString *)url;
- (MOMLView *)getMomlView;

@end
