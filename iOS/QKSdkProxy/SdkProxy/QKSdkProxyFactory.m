//
//  QKSdkProxyManager.m
//  Unity-iPhone
//
//  Created by wending on 2018/5/4.
//

#import "QKSdkProxyFactory.h"
#import "QKUnityBridgeManager.h"

const char* QKSdkProxyClassName = "QKBaseSdkProxy";

@implementation QKSdkProxyFactory

+ (QKBaseSdkProxy *)SdkProxy
{
    static __strong QKBaseSdkProxy* instance = nil;
    if(instance == NULL)
    {
        Class cls = NSClassFromString([NSString stringWithUTF8String: QKSdkProxyClassName]);
        instance = [[cls alloc] init];
        
        [QKUnityBridgeManager Instance].unityDelegate = instance;
    }
    return instance;
}

@end
