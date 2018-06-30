//
//  IOSNetWork.m
//  Unity-iPhone
//
//  Created by weitiancheng on 16/7/18.
//
//

#import "IOSNetWork.h"
#import "QKSdkProxyUtility.h"
#import "QKBaseSdkProxy.h"
#import "QKSdkProxyConstant.h"

@interface IOSNetWork()

@property(nonatomic, copy) QKUnityCallbackFunc callback;

@end

@implementation IOSNetWork

+(IOSNetWork *)Instance
{
    static __strong IOSNetWork* _Instance = nil;
    if(_Instance == NULL)
    {
        _Instance = [IOSNetWork alloc];
    }
    return _Instance;
}

//网络状态改变 返回
-(void)reachabilityChanged:(NSNotification *)note
{
//    Reachability* curReach = [note object];
    Reachability* curReach = hostReach;
//    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    if (curReach != nil && [curReach isKindOfClass: [Reachability class]]) {
        NetworkStatus status = [curReach currentReachabilityStatus];
        NSDictionary* dic;
        switch (status)
        {
            case NotReachable:
                NSLog(@"没有网络连接");
                dic = @{@"data":@{@"network":@"0"},@"resultCode":@301};
                break;
            case ReachableViaWWAN:
                NSLog(@"使用移动网络");
                dic = @{@"data":@{@"network":@"1"},@"resultCode":@301};
                break;
            case ReachableViaWiFi:
                NSLog(@"使用本地网络");
                dic = @{@"data":@{@"network":@"2"},@"resultCode":@301};
                break;
        }
        
        if (self.callback != nil) {
            self.callback([QKSdkProxyUtility Json_DicToString:dic]);
        }
    }
}

//添加推送监听
-(void)startNotifier:(QKUnityCallbackFunc)callback
{
    self.callback = callback;
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: sevencoolkReachabilityChangedNotification
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
}
@end
