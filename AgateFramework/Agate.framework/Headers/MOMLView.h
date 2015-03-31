//
//  Created by MoSPI.org on 4.11.2011
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MOMLUIObject.h"

@class MOMLViewInternal;
@class MOMLUIContainer;

IB_DESIGNABLE
@interface MOMLView : UIView
{
@private
    MOMLViewInternal *internal;
}

- (void)loadApplication:(NSString *)url;
- (void)loadURL:(NSString *)url;
- (void)setTopWindow:(UIWindow *)topWindow;
- (void)orientationChanged:(UIInterfaceOrientation)interfaceOrientation;
- (MOMLUIContainer *) getRootContainer;
- (BOOL)registerUIComponent:(NSString *)className name:(NSString *)name base:(NSString *)base userObject:(NSObject *)userObj;
- (BOOL)unregisterUIComponent:(NSString *)className;
- (BOOL)registerObjectComponent:(NSString *)className name:(NSString *)name base:(NSString *)base userObject:(NSObject *)userObj;
- (BOOL)unregisterObjectComponent:(NSString *)className;
- (void)addUIObjectHandler:(NSString *)uiId handler:(id<MOMLUIObjectDelegate>)handler;

@property (nonatomic, readonly) MOMLUIObject *root;
@property (nonatomic, readonly) NSUInteger supportedInterfaceOrientations;
@property (nonatomic) IBInspectable NSString* applicationInfo;
@property (nonatomic) IBInspectable NSString* startUrl;

// deprecated
- (BOOL)registerUIComponent:(NSString *)className name:(NSString *)name userObject:(NSObject *)userObj base:(NSString *)base __attribute__((deprecated));
- (BOOL)registerObjectComponent:(NSString *)className name:(NSString *)name userObject:(NSObject *)userObj base:(NSString *)base __attribute__((deprecated));
- (void)addUIObjectHandler:(id<MOMLUIObjectDelegate>)handler forUiId:(NSString *)uiId __attribute__((deprecated));

@end

