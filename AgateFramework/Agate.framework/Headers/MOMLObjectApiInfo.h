//
//  Created by MoSPI.org on 2.8.2013
//
//  Permission is granted to copy, distribute, modify under the terms of Citrine License.
//
//  Copyright (C) MoSPI.org. All rights reserved.
//

@class MOMLObjectApi;
@class MOMLObjectApiVersion;

@interface MOMLObjectApiInfo : NSObject
+ (MOMLObjectApiInfo *)createObjectApiInfoWithName:(NSString *)name modifiedVersion:(NSString *)modifiedVersion addedVersion:(NSString *)addedVersion deletedVersion:(NSString *)deletedVersion parent:(MOMLObjectApiInfo *)parent;
- (void)registerMethodName:(NSString *)name internalName:(NSString *)internalName useCallContext:(BOOL)useCallContext parameterCount:(int)parameterCount modifiedVersion:(NSString *)modifiedVersion addedVersion:(NSString *)addedVersion deletedVersion:(NSString *)deletedVersion;
- (void)registerMethodName:(NSString *)name internalName:(NSString *)internalName parameterCount:(int)parameterCount modifiedVersion:(NSString *)modifiedVersion addedVersion:(NSString *)addedVersion deletedVersion:(NSString *)deletedVersion;
- (void)registerPropertyName:(NSString *)name internalName:(NSString *)internalName modifiedVersion:(NSString *)modifiedVersion addedVersion:(NSString *)addedVersion deletedVersion:(NSString *)deletedVersion;
- (void)unregisterParentMethodName:(NSString *)name parameterCount:(int)parameterCount;
- (void)unregisterParentPropertyName:(NSString *)name;
- (void)enumerateObjectApisUsingBlock:(void (^)(MOMLObjectApi *objApi, NSUInteger idx, BOOL *stop))block;

#define OBJECT_MAP

#define BEGIN_OBJECTAPI_MAP(objName, mVersion, aVersion, dVersion) \
+ (MOMLObjectApiInfo *)getObjectApiInfo \
{ \
    static MOMLObjectApiInfo *objApiInfo = nil; \
    if (objApiInfo == nil) \
    { \
        objApiInfo = [MOMLObjectApiInfo createObjectApiInfoWithName:@#objName modifiedVersion:@#mVersion addedVersion:@#aVersion deletedVersion:@#dVersion parent:[super getObjectApiInfo]];


#define END_OBJECTAPI_MAP() \
    } \
return objApiInfo; \
} \

#define REGISTER_METHOD(external, paramCount, mVersion, aVersion, dVersion) \
        [objApiInfo registerMethodName:@#external internalName:@#external parameterCount:paramCount modifiedVersion:@#mVersion addedVersion:@#aVersion deletedVersion:@#dVersion];

#define REGISTER_METHODEX(external, paramCount, internal, mVersion, aVersion, dVersion) \
    [objApiInfo registerMethodName:@#external internalName:@#internal parameterCount:paramCount modifiedVersion:@#mVersion addedVersion:@#aVersion deletedVersion:@#dVersion];

// paramCount : parameter count except for callContext parameter
#define REGISTER_CALLCONTEXTMETHOD(external, paramCount, internal, mVersion, aVersion, dVersion) \
    [objApiInfo registerMethodName:@#external internalName:@#internal useCallContext:YES parameterCount:paramCount modifiedVersion:@#mVersion addedVersion:@#aVersion deletedVersion:@#dVersion];

#define REGISTER_PROPERTY(external, mVersion, aVersion, dVersion) \
    [objApiInfo registerPropertyName:@#external internalName:@#external modifiedVersion:@#mVersion addedVersion:@#aVersion deletedVersion:@#dVersion];
    
#define REGISTER_PROPERTYEX(external, internal, mVersion, aVersion, dVersion) \
    [objApiInfo registerPropertyName:@#external internalName:@#internal modifiedVersion:@#mVersion addedVersion:@#aVersion deletedVersion:@#dVersion];

#define UNREGISTER_PARENTMETHOD(external, paramCount) \
    [objApiInfo unregisterParentMethodName:@#external parameterCount:paramCount];

#define UNREGISTER_PARENTPROPERTY(external) \
    [objApiInfo unregisterParentPropertyName:@#external];

@end
