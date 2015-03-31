//
//  Created by MoSPI.org on 5.22.2012
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//

#ifndef MOML_IMOMLUIComponent_h
#define MOML_IMOMLUIComponent_h

#import <UIKit/UIKit.h>
#import "MOMLObject.h"
//#import "MOMLObjectApiInfo.h"
@class MOMLObjectApiInfo;

@protocol IMOMLComponent <NSObject>
@required
- (NSString*)callFunction:(NSString *)name args:(NSArray *)args;
- (void)initBase:(id<IMOMLComponent>)base userObject:(NSObject *)userObj object:(MOMLObject *)object;
- (MOMLObjectApiInfo *)getObjectApiInfo;
- (id<IMOMLComponent>)getBase;

@optional
//- (void) init:(MOMLObject *)object;
@end


@protocol IMOMLUIComponent <IMOMLComponent>
@required
- (UIView *)createView;
- (void)onInitialUpdate;
- (void)layout:(CGRect)rect;
- (NSString *)onEvent:(NSString *)eventName args:(NSArray *)args;
//- (void) initBase:(id<IMOMLUIComponent>)base uiObject:(MOMLUIObject *)uiObject;
@end




#endif
