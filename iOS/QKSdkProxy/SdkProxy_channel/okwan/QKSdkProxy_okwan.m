//
//  QKSdkProxy_okwan.m
//  Unity-iPhone
//
//  Created by wending on 2018/4/18.
//

#import "QKSdkProxy_okwan.h"
#import "TBsdkManagerCode.h"
#import "TBRoleModelCode.h"
#import "TBRequestModelCode.h"
#import "QKUnityBridgeManager.h"
#import "QKSdkProxyUtility.h"
#import "QKWebViewController.h"
#import "SdkDataManager.h"

IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_okwan)

@interface QKSdkProxy_okwan ()

@property(nonatomic, copy) QKUnityCallbackFunc loginCallback;

@end

@implementation QKSdkProxy_okwan

- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(okwan_onLogin:) name:@"login" object:nil];
    [TBsdkManagerCode manager];
    
    callback(@"true");
}

- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.loginCallback = callback;
    [TBsdkManagerCode TBstartLoginWithGid:@"204" apiKey:@"90a7559f6a4b414861cb6c7f85b18865" secretKey:@"8bc0e788fb2c69d193f04fe0be804507" version:@"1.0.0"];//[QKSdkProxyUtility GetBundleVersion]
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
    requestModelCode.TBroleName = [SdkDataManager Instance].RoleName;
    /** 订单号 */
    requestModelCode.TBorderOn = infoDic[@"OrderId"];
    /** 商品描述 */
    requestModelCode.TBbody = infoDic[@"Des"];
    /** 等级 */
    requestModelCode.TBRoleLevel = [SdkDataManager Instance].RoleLevel;
    /** 价格 */
    requestModelCode.TBamount = infoDic[@"Price"];
    /** 商品数量 */
    requestModelCode.TBgoodsNum = infoDic[@"Count"];
    /** 服务器id */
    requestModelCode.TBserverID = [SdkDataManager Instance].ServerId;
    /** 苹果内购的商品id */
    requestModelCode.TBproductID = infoDic[@"ItemId"];
    /** 详情见文档 */
    requestModelCode.TBUrl = @"http://rmb.sjcq.xgd666.com/callback/55_1_ios_okw/pay.php";
    
    
    [TBsdkManagerCode TBstartPayWithRequestModel:requestModelCode];
}

- (void)CreateRole:(NSString*)strData
{
    [super CreateRole:strData];
    [self submitRoleInfo];
}

- (void)SelectRole:(NSString*)strData
{
    [super SelectRole:strData];
    [self submitRoleInfo];
}

- (void)LevelUp:(NSString*)strData
{
    [super LevelUp:strData];
    [self submitRoleInfo];
}

- (void)TBLoginDistribution:(NSString*)strData
{
    [TBsdkManagerCode TBLoginDistributionDidSuccess:^(NSString *url) {
        if (url != nil) {
            [QKWebViewController showWeb:url];
        }
    } error:^(NSString *errorMsg) {
        
    }];
}

- (void)TBwithdrawal:(NSString*)strData
{
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    NSString* roleName = [SdkDataManager Instance].RoleName;
    NSString* serverID = [SdkDataManager Instance].ServerId;
    NSString* amount = infoDic[@"Amount"];
    NSString* extraInfo = infoDic[@"ExtraInfo"];
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
    [self getUserAgentMesasge];
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

- (void)okwan_onLogin:(NSNotification*)notif {
    NSLog(@"okwan_onLogin: %@", notif.userInfo);
    NSString* scode = notif.userInfo[@"scode"];
//    NSString* uid = notif.userInfo[@"uid"];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://chklogin.sjcq.xgd666.com/checklogin.php?channel=ios_okw&token=%@&api_key=%@", scode, @"90a7559f6a4b414861cb6c7f85b18865"];
    NSLog(@"urlStr: %@", urlStr);
    NSURL *url=[NSURL URLWithString:urlStr];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    //创建请求 Task
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"chklogin error: %@", error);
        } else {
            NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"chklogin result: %@; %@", result, response);
            if (result != nil && [result length] > 0 && ![result isEqualToString:@"fail"]) {
                NSDictionary* resultDic = [QKSdkProxyUtility Json_StringToDic:result];
                if (resultDic != nil && resultDic[@"code"] != nil && [resultDic[@"code"] integerValue] == 1) {
                    NSString* userid = [QKSdkProxyUtility stringValue:resultDic[@"uid"]];
                    NSString* sign = [QKSdkProxyUtility stringValue:resultDic[@"sign"]];
                    [SdkDataManager Instance].SdkUid = userid;
                    NSDictionary* dic = @{@"IsSuccess":@YES,
                                          @"Uid":userid,
                                          @"Token":sign};
                    NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                    self.loginCallback(retStr);
                } else {
                    NSLog(@"chklogin fail: %@", result);
                    NSDictionary* dic = @{@"IsSuccess":@NO};
                    NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                    self.loginCallback(retStr);
                }
            } else {
                NSLog(@"chklogin result error: %@", result);
                NSDictionary* dic = @{@"IsSuccess":@NO};
                NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                self.loginCallback(retStr);
            }
        }
    }];
    //发送请求
    [dataTask resume];
}

//上报角色信息
- (void)submitRoleInfo {
    TBRoleModelCode* roleModelCode = [[TBRoleModelCode alloc] init];
    roleModelCode.TBRoleName = [SdkDataManager Instance].RoleName;
    /** 角色等级 */
    roleModelCode.TBRoleLevel = [SdkDataManager Instance].RoleLevel;
    /** 服务器id */
    roleModelCode.TBSerVerID = [SdkDataManager Instance].ServerId;
    /** 服务器名字, urlencode(转码) */
    roleModelCode.TBServerName = [SdkDataManager Instance].ServerName;
    
    [TBsdkManagerCode TBUpdateRoleInfoWithRoleModel:roleModelCode didSuccess:^(BOOL isUpdateRoleSuccess) {
        
    }];
}

//设置web Agent
- (void)getUserAgentMesasge {
    static int i = 1;
    
    if (i== 1) {
        //需要在调用请求前设置
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSLog(@"old agent :%@", oldAgent);
        
        //add my info to the new agent
        NSString *newAgent = [oldAgent stringByAppendingString:@" shangjin_okwan_ios"];
        NSLog(@"new agent :%@", newAgent);
        
        //regist the new agent
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent",nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
        i++;
    }
}

@end
