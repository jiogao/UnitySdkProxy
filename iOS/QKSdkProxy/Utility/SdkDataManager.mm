//
//  SDKDataManager.m
//  Unity-iPhone
//
//  Created by weitiancheng on 2017/9/24.
//
//

#import <Foundation/Foundation.h>
#import "SdkDataManager.h"

//保证变量不为空
#define NO_NULL_STRING(VALUE_NAME, DEFAULT_VALUE) \
- (void)set##VALUE_NAME:(NSString *)VALUE_NAME { \
    if (VALUE_NAME == nil) { \
        NSLog(@"warning: VALUE_NAME is nil"); \
        VALUE_NAME = DEFAULT_VALUE; \
    } \
    _##VALUE_NAME = VALUE_NAME; \
}

@implementation SdkDataManager

+(SdkDataManager*)Instance
{
    static __strong SdkDataManager* _Instance = nil;
    if(_Instance == NULL)
    {
        _Instance = [SdkDataManager alloc];
    }
    return _Instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.SdkUid = @"";
        
        self.RoleId = @"";
        self.RoleName = @"";
        self.RoleLevel = @"";
        self.RoleCreateTime = @"";
        self.RoleVipLevel = @"";
        self.RoleGold = @"";
        
        self.ServerId = @"";
        self.ServerName = @"";
    }
    return self;
}

NO_NULL_STRING(SdkUid, @"")
NO_NULL_STRING(RoleId, @"")
NO_NULL_STRING(RoleName, @"")
NO_NULL_STRING(RoleLevel, @"")
NO_NULL_STRING(RoleCreateTime, @"")
NO_NULL_STRING(RoleVipLevel, @"")
NO_NULL_STRING(RoleGold, @"")
NO_NULL_STRING(ServerId, @"")
NO_NULL_STRING(ServerName, @"")

@end
