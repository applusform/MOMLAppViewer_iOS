//
//  AppViewController.h
//  MOMLAppViewer
//
//  Created by MOSPI on 13. 2. 21..
//  Copyright (c) 2013 mospi.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Agate/MOMLUIViewController.h>

#define OpenType_APPLICATION    @"application"
#define OpenType_MOMLUI         @"momlui"
#define OpenType_HTML           @"html"
#define OpenType_UNKNOWN        @"unknown"
#define OpenType_ERROR          @"error"

@interface AppViewController : MOMLUIViewController
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *openType;
- (void)hideModalViewAnimated:(BOOL)ani;
@end
