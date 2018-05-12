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
                                 @"bundleVersion":[QKSdkProxyUtility GetBundleVersion],
                                 @"version":[QKSdkProxyUtility GetVersion],
                                 @"idfa":[QKSdkProxyUtility GetIDFA],
                                 @"idfv":[QKSdkProxyUtility GetIDFV],
                                 };
    NSString* infoJson = [QKSdkProxyUtility Json_DicToString:info];
    callback(infoJson);
}

- (void)GetDeviceStatus:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    NSDictionary* info = @{
                           @"power":[QKSdkProxyUtility GetPrower],
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
}

- (void)CreateRole:(NSString*)strData
{
}

- (void)SelectRole:(NSString*)strData
{
}

- (void)EnterGame:(NSString*)strData
{
}

- (void)LevelUp:(NSString*)strData
{
}

- (void)UpdateUserGoods:(NSString*)strData
{
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

//--------------- for AppController ---------------
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
    | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
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


