//
//  SDKDataManager.m
//  Unity-iPhone
//
//  Created by weitiancheng on 2017/9/24.
//
//

#import <Foundation/Foundation.h>
#import "SdkDataManager.h"

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

@end
