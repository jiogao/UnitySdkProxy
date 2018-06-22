//
//  QKUnityAppController.m
//  Unity-iPhone
//
//  Created by wending on 2018/4/18.
//

#import "QKUnityAppController.h"

#import "QKSdkProxyFactory.h"

IMPL_APP_CONTROLLER_SUBCLASS(QKUnityAppController)

@implementation QKUnityAppController

#if !UNITY_TVOS
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
//    return [super application:application supportedInterfaceOrientationsForWindow:window];
    return [[QKSdkProxyFactory SdkProxy] application:application supportedInterfaceOrientationsForWindow:window];
}

#endif

#if !UNITY_TVOS
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    [super application:application didReceiveLocalNotification:notification];
    [[QKSdkProxyFactory SdkProxy] application:application didReceiveLocalNotification:notification];
}

#endif

#if UNITY_USES_REMOTE_NOTIFICATIONS
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [super application:application didReceiveRemoteNotification:userInfo];
    [[QKSdkProxyFactory SdkProxy] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [super application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [[QKSdkProxyFactory SdkProxy] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

#if !UNITY_TVOS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    [super application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
    [[QKSdkProxyFactory SdkProxy] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:handler];
}

#endif

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [super application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [[QKSdkProxyFactory SdkProxy] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

#endif

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    [super application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [[QKSdkProxyFactory SdkProxy] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    [[QKSdkProxyFactory SdkProxy] application:application handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    [[QKSdkProxyFactory SdkProxy] application:application openURL:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [super application:application willFinishLaunchingWithOptions:launchOptions];
    [[QKSdkProxyFactory SdkProxy] application:application willFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    //需要初始化的api
    //清楚角标
    application.applicationIconBadgeNumber = 0;
    
    [[QKSdkProxyFactory SdkProxy] application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    [super applicationDidEnterBackground:application];
    [[QKSdkProxyFactory SdkProxy] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    [super applicationWillEnterForeground:application];
    [[QKSdkProxyFactory SdkProxy] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [super applicationDidBecomeActive:application];
    [[QKSdkProxyFactory SdkProxy] applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    [super applicationWillResignActive:application];
    [[QKSdkProxyFactory SdkProxy] applicationWillResignActive:application];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [super applicationDidReceiveMemoryWarning:application];
    [[QKSdkProxyFactory SdkProxy] applicationDidReceiveMemoryWarning:application];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    [super applicationWillTerminate:application];
    [[QKSdkProxyFactory SdkProxy] applicationWillTerminate:application];
}

@end

