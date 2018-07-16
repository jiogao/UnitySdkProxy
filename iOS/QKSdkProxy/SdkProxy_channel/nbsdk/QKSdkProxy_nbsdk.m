//
//  QKSdkProxy_nbsdk.m
//  Unity-iPhone
//
//  Created by wending on 2018/7/7.
//

#import "QKSdkProxy_nbsdk.h"
#import <NBSDK/NBSDK.h>
#import "SdkDataManager.h"
#import "QKSdkProxyUtility.h"

IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_nbsdk)

@interface QKSdkProxy_nbsdk ()  <NBSDKDelegate>

@property (nonatomic, assign) BOOL isGameInitSuccess;

@property (nonatomic, copy) QKUnityCallbackFunc initCallback;
@property (nonatomic, copy) QKUnityCallbackFunc loginCallback;
@end

@implementation QKSdkProxy_nbsdk

- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.initCallback = callback;
    [[NBSDK getInstance] initSDK];
}


//--------------- for AppController ---------------
//- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
//{
////    return (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
////    | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
//    return [[NBSDK getInstance] application:application supportedInterfaceOrientationsForWindow:window];
//}

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
    return [[NBSDK getInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    return [[NBSDK getInstance] application:application handleOpenURL:url];
    //    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    return [[NBSDK getInstance] application:application openURL:url options:options];
    //    return YES;
}

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [NBSDK getInstance].delegate = self;
    
    return [[NBSDK getInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    //    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    [[NBSDK getInstance] applicationWillEnterForeground:application];
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

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler
{
    return [[NBSDK getInstance] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

#pragma mark - NBSDKDelegate
-(void)initSuccess:(NSString *)pfid
{
    NSLog(@"nbsdk intisuccess....");
    if([pfid isEqual:@"999"])
    {
        //提审服
    }
    else{
        //正式服
    }
    self.initCallback(@"true");
}

-(void)initFailed
{
    NSLog(@"NBSDK初始化失败");
    self.initCallback(@"false");
}

- (void)Login:(NSString *)strData callback:(QKUnityCallbackFunc)callback
{
    NSLog(@"NBSDK登录");
    [[NBSDK getInstance] login];
    self.loginCallback = callback;
}

-(void)loginSuccess:(NSString *)pfUid pfToken:(NSString *)pfToken
{
    NSLog(@"NBSDK loginSuccess uid=%@, token=%@", pfUid, pfToken);
    
    [SdkDataManager Instance].SdkUid = pfUid;
    [SdkDataManager Instance].loginToken = pfToken;
    NSDictionary* dic = @{
                          @"IsSuccess":@YES,
                          @"Uid":[SdkDataManager Instance].SdkUid,
                          @"Token":[SdkDataManager Instance].loginToken,
                          @"game_id":@"",
                          @"channel_id":@"",
                          @"game_channel_id":@""};
    NSString * str = [QKSdkProxyUtility Json_DicToString:dic];
    self.loginCallback(str);
}

-(void)loginFailed
{
    NSLog(@"NBSDK loginFailed");
}

- (void)Logout:(NSString *)strData callback:(QKUnityCallbackFunc)callback
{
    NSLog(@"nbsdk logout........");
    [[NBSDK getInstance] logout];
}

-(void)logoutSuccess:(NSString *)pfUid pfToken:(NSString *)pfToken
{
    NSLog(@"nbsdk logoutsuccess....");
    NSLog(@"NBSDK logoutSuccess uid=%@, token=%@", pfUid, pfToken);
}

-(void)logoutFailed:(NSString *)pfUid pfToken:(NSString *)pfToken
{
    NSLog(@"nbsdk logoutfailed....");
    NSLog(@"NBSDK logoutFailed uid=%@, token=%@", pfUid, pfToken);
}

- (void)SelectServer:(NSString *)strData
{
    NSLog(@"nbsdk selectserver...");
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                           [SdkDataManager Instance].ServerId, @"serverId", // ID
                           [SdkDataManager Instance].ServerName, @"serverName", //
                           [SdkDataManager Instance].RoleId, @"roleId", // ID
                           [SdkDataManager Instance].RoleName, @"roleName", //
                           [SdkDataManager Instance].RoleLevel, @"roleLevel", //
                           [SdkDataManager Instance].RoleCreateTime, @"roleCreateTime", //
                           [SdkDataManager Instance].CpuId, @"cpUid",nil];// 游戏方id;
    [[NBSDK getInstance] submitServerAndRole:NBServerRoleSubmitTypes_SELECT_SERVER info:info];
}

-(void)CreateRole:(NSString *)strData
{
    NSLog(@"nbsdk createrole.....");
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [SdkDataManager Instance].ServerId, @"serverId", // ID
                          [SdkDataManager Instance].ServerName, @"serverName", //
                          [SdkDataManager Instance].RoleId, @"roleId", // ID
                          [SdkDataManager Instance].RoleName, @"roleName", //
                          [SdkDataManager Instance].RoleLevel, @"roleLevel", //
                          [SdkDataManager Instance].RoleCreateTime, @"roleCreateTime", //
                          [SdkDataManager Instance].CpuId, @"cpUid",nil];// 游戏方id;
      [[NBSDK getInstance] submitServerAndRole:NBServerRoleSubmitTypes_CREATE_ROLE info:info];
}

-(void)SelectRole:(NSString *)strData
{
    NSLog(@"nbsdk SelectRole.....");
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [SdkDataManager Instance].ServerId, @"serverId", // ID
                          [SdkDataManager Instance].ServerName, @"serverName", //
                          [SdkDataManager Instance].RoleId, @"roleId", // ID
                          [SdkDataManager Instance].RoleName, @"roleName", //
                          [SdkDataManager Instance].RoleLevel, @"roleLevel", //
                          [SdkDataManager Instance].RoleCreateTime, @"roleCreateTime", //
                          [SdkDataManager Instance].CpuId, @"cpUid",nil];// 游戏方id;
    [[NBSDK getInstance] submitServerAndRole:NBServerRoleSubmitTypes_SELECT_ROLE info:info];
}

-(void)EnterGame:(NSString *)strData
{
    NSLog(@"nbsdk EnterGame.....");
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [SdkDataManager Instance].ServerId, @"serverId", // ID
                          [SdkDataManager Instance].ServerName, @"serverName", //
                          [SdkDataManager Instance].RoleId, @"roleId", // ID
                          [SdkDataManager Instance].RoleName, @"roleName", //
                          [SdkDataManager Instance].RoleLevel, @"roleLevel", //
                          [SdkDataManager Instance].RoleCreateTime, @"roleCreateTime", //
                          [SdkDataManager Instance].CpuId, @"cpUid",nil];// 游戏方id;
    [[NBSDK getInstance] submitServerAndRole:NBServerRoleSubmitTypes_ENTER_GAME info:info];
}

-(void)LevelUp:(NSString *)strData
{
    NSLog(@"nbsdk LevelUp.....");
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          [SdkDataManager Instance].ServerId, @"serverId", // ID
                          [SdkDataManager Instance].ServerName, @"serverName", //
                          [SdkDataManager Instance].RoleId, @"roleId", // ID
                          [SdkDataManager Instance].RoleName, @"roleName", //
                          [SdkDataManager Instance].RoleLevel, @"roleLevel", //
                          [SdkDataManager Instance].RoleCreateTime, @"roleCreateTime", //
                          [SdkDataManager Instance].CpuId, @"cpUid",nil];
    [[NBSDK getInstance] submitServerAndRole:NBServerRoleSubmitTypes_ROLE_LEVELUP info:info];
}

-(void)Pay:(NSString *)strData callback:(QKUnityCallbackFunc)callback
{
     NSLog(@"nbsdk Pay.....");
    NSDictionary* dic = [QKSdkProxyUtility Json_StringToDic:strData];
    NBPayInfo *payInfo = [[NBPayInfo alloc] init];
    [payInfo setCpOrderId:dic[@"OrderId"]]; //
    [payInfo setGoodsId:dic[@"ProductId"]]; //
    [payInfo setGoodsDesc:dic[@"Des"]];
    int price = [dic[@"Price"] intValue];
     [payInfo setOrderAmount:price]; //
    [payInfo setUnitName:dic[@"Vcname"]]; //
    int count = [dic[@"Count"] intValue];
     [payInfo setGoodsNum:count]; //
    int num = [dic[@"AddVCount"] intValue];
     [payInfo setCoinNum:num]; //
    [payInfo setCpExtra:dic[@"ExtraInfo"]]; //
     [[NBSDK getInstance] pay:payInfo]; //
}

-(void)paySuccess:(NSString *)cpOrderId
{
    NSLog(@"paySuccess....");
    NSLog(@"NBSDK paySuccess cpOrderId=%@", cpOrderId);
}

-(void)payFailed:(NSString *)cpOrderId
{
     NSLog(@"payFailed...");
    NSLog(@"NBSDK payFailed cpOrderId=%@", cpOrderId);
}

@end
