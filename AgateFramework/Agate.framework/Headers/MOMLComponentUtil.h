//
//  Created by MoSPI.org on 7.24.2012
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//

#import "MOMLUIObject.h"

@interface MOMLComponentUtil : NSObject {
    
}

+(NSString *) ReplaceScriptString:(MOMLUIObject *) uiObject str :(NSString *) str;
+(NSInvocation *) findComponentMethod:(NSObject *) object functionName:(NSString *) function parameterCount:(NSUInteger)count;
+(NSString *) invokeMethod:(NSInvocation *) invocation parameters:(NSArray *)parameters;
@end
