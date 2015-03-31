//
//  Created by MoSPI.org on 5.22.2012
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//
#import "MOMLObject.h"
//#import "MOMLUIObjectDelegate.h"
@class MOMLUIBaseWindow;
@class MOMLUIObject;
@protocol MOMLUIObjectDelegate <NSObject>
@optional
- (MOMLUIObject *)momlUIObject:(MOMLUIObject *)momlUIObject onCreateChild:(NSString *)elementName idName:(NSString *)idName;
- (NSString *)momlUIObject:(MOMLUIObject *)momlUIObject onEvent:(NSString *)eventName args:(NSArray *)args;
@end


@class MOMLUIObjectInternal;
@interface MOMLUIObject : MOMLObject
{
    MOMLUIObjectInternal *uiInternal;
}
@property (nonatomic, readonly) NSString *elementName;
@property (nonatomic, readonly) NSString *idName;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, weak) id<MOMLUIObjectDelegate> delegate;

- (id)initWith:(MOMLUIBaseWindow *)uiObject;
- (MOMLUIObject*)findWindow:(NSString*)name;
- (void)processEvent:(NSString*)name;
- (void)setDelegate:(id<MOMLUIObjectDelegate> )delegate;
- (id<MOMLUIObjectDelegate>) delegate;
- (NSString *)runScript:(NSString *)script;
- (NSString *)runCommand:(NSString *)command targetId:(NSString *)targetId __attribute__((deprecated));

@end


