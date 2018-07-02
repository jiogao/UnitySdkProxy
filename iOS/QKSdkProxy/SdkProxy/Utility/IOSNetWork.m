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
    Reachability* curReach = [note object];
    if (curReach != hostReach && curReach != nil) {
        return;
    }
//    Reachability* curReach = hostReach;
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    // 转化为unity中的网络状态枚举
//    //Describes network reachability options.
//    public enum NetworkReachability
//    {
//        //     Network is not reachable.
//        NotReachable = 0,
//        //     Network is reachable via carrier data network.
//        ReachableViaCarrierDataNetwork = 1,
//        //     Network is reachable via WiFi or cable.
//        ReachableViaLocalAreaNetwork = 2
//    }
    int statutCode = 0;
    switch (status)
    {
        case NotReachable:
            NSLog(@"没有网络连接");
            statutCode = 0;
            break;
        case ReachableViaWWAN:
            NSLog(@"使用移动网络");
            statutCode = 1;
            break;
        case ReachableViaWiFi:
            NSLog(@"使用本地网络");
            statutCode = 2;
            break;
    }
    
    if (self.callback != nil) {
        self.callback([[NSNumber numberWithInt:statutCode] stringValue]);
    }
}

//添加推送监听
-(void)startNotifier:(QKUnityCallbackFunc)callback
{
    self.callback = callback;
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kNetworkReachabilityChangedNotification_7cool
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
}
@end
