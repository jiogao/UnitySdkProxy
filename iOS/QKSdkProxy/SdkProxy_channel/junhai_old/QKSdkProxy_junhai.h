//
//  QKSdkProxy_test.m
//  Unity-iPhone
//
//  Created by wending on 2018/5/5.
//

#import "QKSdkProxy_test.h"
#import "QKUnityBridgeManager.h"
#import "QKSdkProxyUtility.h"

IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_test)

@implementation QKSdkProxy_test


- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    callback(@"true");
}

- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    NSDictionary* dic = @{@"IsSuccess":@YES,
                          @"Uid":@"test_uid",
                          @"Token":@"test_scode"};
    NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
    callback(retStr);
}

@end
