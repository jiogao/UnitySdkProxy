//
//  QKBaseSdkProxy.m
//  Unity-iPhone
//
//  Created by wending on 2018/4/18.
//

#import "QKBaseSdkProxy.h"

#import "QKUnityBridgeManager.h"
#import "QKSdkProxyUtility.h"
#import "IOSNetWork.h"
#import "SdkDataManager.h"

@implementation QKBaseSdkProxy

- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
}

- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
}

- (void)Logout:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
}

- (void)Pay:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
}

- (void)ExitGame:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    callback(@"false");
}

- (void)GetDeviceInfo:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    NSDictionary* info = @{
                           @"BundleVersion":[QKSdkProxyUtility GetBundleVersion],
                           @"Version":[QKSdkProxyUtility GetVersion],
                           @"DeviceId":[QKSdkProxyUtility GetDeviceId],
                           };
    NSString* infoJson = [QKSdkProxyUtility Json_DicToString:info];
    callback(infoJson);
}

- (void)GetDeviceStatus:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    NSDictionary* info = @{
                           @"Power":[NSNumber numberWithFloat:[QKSdkProxyUtility GetPrower]],
                           };
    NSString* infoJson = [QKSdkProxyUtility Json_DicToString:info];
    callback(infoJson);
}

- (void)GetNetWorkChanged:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    [[IOSNetWork Instance] startNotifier:callback];
}

- (void)ShowFloat:(NSString*)strData
{
}

- (void)HideFloat:(NSString*)strData
{
}

- (void)SelectServer:(NSString*)strData
{
    [self saveServerInfo:strData];
}

- (void)CreateRole:(NSString*)strData
{
    [self saveRoleInfo:strData isCreateRole:YES];
}

- (void)SelectRole:(NSString*)strData
{
    [self saveRoleInfo:strData isCreateRole:YES];
}

- (void)EnterGame:(NSString*)strData
{
}

- (void)LevelUp:(NSString*)strData
{
    [self saveRoleInfo:strData isCreateRole:NO];
}

- (void)UpdateUserGoods:(NSString*)strData
{
    [self saveGoodsInfo:strData];
}

- (void)OpenUrl:(NSString*)strData
{
    if (strData == nil || [strData length] <= 0) {
        return;
    }
    NSURL* url = [NSURL URLWithString:strData];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)OpenBrowser:(NSString*)strData
{
    if (strData == nil || [strData length] <= 0) {
        return;
    }
    NSURL* url = [NSURL URLWithString:strData];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)SetPasteboard:(NSString*)strData
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = strData;
}

- (void)GetPasteboard:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    callback(pasteboard.string);
}

//

- (void)saveServerInfo:(NSString*)strData
{
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    [SdkDataManager Instance].ServerId = infoDic[@"ServerId"];
    [SdkDataManager Instance].ServerName = infoDic[@"ServerName"];
}

- (void)saveRoleInfo:(NSString*)strData isCreateRole:(BOOL)isCreate
{
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    [SdkDataManager Instance].RoleId = infoDic[@"RoleId"];
    [SdkDataManager Instance].RoleName = infoDic[@"RoleName"];
    [SdkDataManager Instance].RoleLevel = infoDic[@"RoleLevel"];
    if (isCreate){
        NSLog(@"CreateRoleTime is %@",infoDic[@"RoleCreateTime"]);
        [SdkDataManager Instance].RoleCreateTime = infoDic[@"RoleCreateTime"];
    }

    [SdkDataManager Instance].RoleVipLevel = infoDic[@"RoleVipLevel"];
    [SdkDataManager Instance].RoleGold = infoDic[@"RoleGold"];
    [SdkDataManager Instance].CpuId = infoDic[@"CpUid"];
    [SdkDataManager Instance].RoleUpdateTime = infoDic[@"RoleUpdateTime"];
}

- (void)saveGoodsInfo:(NSString*)strData
{
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    [SdkDataManager Instance].ConsumCoin = infoDic[@"ConsumCoin"];
    [SdkDataManager Instance].RemainCoin = infoDic[@"RemainCoin"];
    [SdkDataManager Instance]. ConsumeBind= infoDic[@"ConsumeBind"];
    [SdkDataManager Instance].RemainBind = infoDic[@"RemainBind"];
    [SdkDataManager Instance].ItemName = infoDic[@"ItemName"];
    [SdkDataManager Instance].ItemCount = infoDic[@"ItemCount"];
    [SdkDataManager Instance].ItemDes = infoDic[@"ItemDes"];
}
//--------------- for AppController ---------------
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
//    return (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
//    | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
    
    // No rootViewController is set because we are switching from one view controller to another, all orientations should be enabled
    if ([window rootViewController] == nil)
        return UIInterfaceOrientationMaskAll;
    
    // Before it was UIInterfaceOrientationAll because some presentation controllers insisted on being portrait only
    // (e.g. GameCenter) so we did that do avoid crashes.
    // As this was fixed in iOS 6.1 we can use exact same set of constraints as root view controller.
    return [[window rootViewController] supportedInterfaceOrientations];
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    return YES;
}

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
}

- (void)applicationWillResignActive:(UIApplication*)application
{
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
}

- (void)applicationWillTerminate:(UIApplication*)application
{
}


//
- (void)didReceiveMemoryWarning
{
}

@end


