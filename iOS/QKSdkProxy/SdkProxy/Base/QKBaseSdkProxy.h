//
//  QKBaseSdkProxy.h
//  Unity-iPhone
//
//  Created by wending on 2018/4/18.
//

#import <Foundation/Foundation.h>
#import "QKSdkProxyConstant.h"
#import "QKUnityBridgeManager.h"

@interface QKBaseSdkProxy : NSObject

//--------------- sdk action ---------------
- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)Logout:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)Pay:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)ExitGame:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)GetDeviceInfo:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)GetDeviceStatus:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)GetNetWorkChanged:(NSString*)strData callback:(QKUnityCallbackFunc)callback;
- (void)ShowFloat:(NSString*)strData;
- (void)HideFloat:(NSString*)strData;
- (void)SelectServer:(NSString*)strData;
- (void)CreateRole:(NSString*)strData;
- (void)SelectRole:(NSString*)strData;
- (void)EnterGame:(NSString*)strData;
- (void)LevelUp:(NSString*)strData;
- (void)RoleChat:(NSString*)strData;
- (void)UpdateUserGoods:(NSString*)strData;
- (void)OpenUrl:(NSString*)strData;
- (void)OpenBrowser:(NSString*)strData;

//--------------- AppController 生命周期 ---------------
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window;
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler;
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url;
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options;
- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions;
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions;
- (void)applicationDidEnterBackground:(UIApplication*)application;
- (void)applicationWillEnterForeground:(UIApplication*)application;
- (void)applicationDidBecomeActive:(UIApplication*)application;
- (void)applicationWillResignActive:(UIApplication*)application;
- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application;
- (void)applicationWillTerminate:(UIApplication*)application;

@end
