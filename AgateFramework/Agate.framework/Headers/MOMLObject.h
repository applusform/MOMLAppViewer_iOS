//
//  Created by MoSPI.org on 5.22.2012
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//
#include <UIKit/UIKit.h>

@class MOMLContext;
@class MOMLObjectInternal;

@interface MOMLObject : NSObject
{
@protected
    MOMLObjectInternal *internal;
}

- (id)initWith:(MOMLContext *)context object:(NSObject *)object;
- (MOMLObjectInternal *)createInternal:(MOMLContext *)context object:(NSObject *)obj;
- (void *)getObject:(NSString *)objectType index:(int)index;
- (NSString *)getAttribute:(NSString*)name;
- (void)setAttribute:(NSString*)name value:(NSString*)value;

// deprecated
- (void)setProperty:(NSString *)name value:(NSString *)value __attribute__((deprecated));
- (void)setPropertyFloat:(NSString *)name value:(double)value __attribute__((deprecated));
- (NSString *)getProperty:(NSString *)name __attribute__((deprecated));
- (double)getPropertyFloat:(NSString *)name __attribute__((deprecated));
- (NSString *)functionCallWithName:(NSString *)name parameters:(NSArray *)parameters __attribute__((deprecated));

@end
