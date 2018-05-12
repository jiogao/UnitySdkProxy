//
//  QKSdkProxy_OKWan.m
//  Unity-iPhone
//
//  Created by wending on 2018/4/18.
//

#import "QKSdkProxy_OKWan.h"
#import "TBsdkManagerCode.h"
#import "TBRoleModelCode.h"
#import "TBRequestModelCode.h"
#import "SDKDataManager.h"
#import "QKUnityBridgeManager.h"
#import "QKSdkProxyUtility.h"
#import "QKWebViewController.h"

IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_OKWan)

@interface QKSdkProxy_OKWan ()

@property(nonatomic, copy) QKUnityCallbackFunc loginCallback;

@end

@implementation QKSdkProxy_OKWan

- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OKWan_onLogin:) name:@"login" object:nil];
    [TBsdkManagerCode manager];
    
    callback(@"true");
}

- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.loginCallback = callback;
    [TBsdkManagerCode TBstartLoginWithGid:@"204" apiKey:@"90a7559f6a4b414861cb6c7f85b18865" secretKey:@"8bc0e788fb2c69d193f04fe0be804507" version:[QKSdkProxyUtility GetBundleVersion]];
}

- (void)Logout:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    [TBsdkManagerCode TBLoginOutDidSuccess:^(BOOL isSuccess) {
        callback(@"true");
    }];
}

- (void)Pay:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
//    public struct PayInfo
//    {
//        public string OrderId;     //订单号
//        public string ItemId;      //计费点id
//        public string Title;       //商品名称
//        public string Des;         //商品描述
//        public string Price;       //充值金额，单位分
//        public string Count;       //商品数量
//        public string Vcname;      //虚拟货币名称
//        public string Addvc;       //添加的虚拟货币数量
//        public string ExtraInfo;   //透传参数
//    }
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    
    TBRequestModelCode* requestModelCode = [[TBRequestModelCode alloc] init];
    /** 游戏名 */
    requestModelCode.TBgameName = @"赏金传奇";
    /** 游戏方如有需要传入的参数请传入这个 */
    requestModelCode.TBattach = infoDic[@"ExtraInfo"];
    /** 角色名 */
    requestModelCode.TBroleName = @"";
    /** 订单号 */
    requestModelCode.TBorderOn = infoDic[@"OrderId"];
    /** 商品描述 */
    requestModelCode.TBbody = infoDic[@"Des"];
    /** 等级 */
    requestModelCode.TBRoleLevel = @"";
    /** 价格 */
    requestModelCode.TBamount = infoDic[@"Price"];
    /** 商品数量 */
    requestModelCode.TBgoodsNum = infoDic[@"Count"];
    /** 服务器id */
    requestModelCode.TBserverID = @"";
    /** 苹果内购的商品id */
    requestModelCode.TBproductID = infoDic[@"ItemId"];
    /** 详情见文档 */
    requestModelCode.TBUrl = @"http://rmb.sjcq.xgd666.com/callback/55_1_ios_okw/pay.php";
    
    
    [TBsdkManagerCode TBstartPayWithRequestModel:requestModelCode];
}

- (void)TBLoginDistributionDidSuccess:(NSString*)strData
{
    [TBsdkManagerCode TBLoginDistributionDidSuccess:^(NSString *url) {
        if (url != nil) {
            [QKWebViewController showWeb:url];
        }
    } error:^(NSString *errorMsg) {
        
    }];
}

- (void)TBwithdrawalWithRoleName:(NSString*)strData
{
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    NSString* roleName = @"";
    NSString* serverID = @"";
    NSString* amount = infoDic[@"amount"];
    NSString* extraInfo = infoDic[@"extraInfo"];
    [TBsdkManagerCode TBwithdrawalWithRoleName:roleName serverID:serverID amount:amount attach:extraInfo completion:^(BOOL isSuccess, NSString *url, NSString *errorMsg) {
        if (url != nil) {
            [QKWebViewController showWeb:url];
        }
    }];
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
    return [TBsdkManagerCode application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
//    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    return [TBsdkManagerCode application:application openURL:url options:options];
//    return YES;
}

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [TBsdkManagerCode  TBReVerifyToService];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    [TBsdkManagerCode TBWillEnterForeground:application];
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

- (void)OKWan_onLogin:(NSNotification*)notif {
    NSLog(@"OKWan_onLogin: %@", notif.userInfo);
    NSString* scode = notif.userInfo[@"scode"];
    NSString* uid = notif.userInfo[@"uid"];
    
//    [QKWebViewController showWeb:@"https://www.baidu.com"];
    
    NSDictionary* dic = @{@"scode":scode, @"uid":uid};
    NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
    self.loginCallback(retStr);
    
//    [[SDKDataManager Instance] setSDKUserId:uid];
//    [[SDKUnityApi Instance] onLoginSuccess:nil];
}

@end
