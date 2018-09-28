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

//// adhoc 企业包
//#define OKWan_Gid @"247"
//#define OKWan_apiKey @"6fd2cf0da9a59a3ca37a1e9a09270f37"
//#define OKWan_secretKey @"d9795f07265f938c53187f62297c993b"

//// appstore
//#define OKWan_Gid @"221"
//#define OKWan_apiKey @"fc52cee945d6b99a92ceb1cf853696f6"
//#define OKWan_secretKey @"962cd36ac0cf3c462fc774f2d28d60a4"


IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_okwan)

@interface QKSdkProxy_okwan ()

@property(nonatomic, copy) NSString* okwan_gid;
@property(nonatomic, copy) NSString* okwan_apiKey;
@property(nonatomic, copy) NSString* okwan_secretKey;

@property(nonatomic, copy) QKUnityCallbackFunc loginCallback;
@property (nonatomic ,assign) UIInterfaceOrientationMask orientationMaskValue;

@end

@implementation QKSdkProxy_okwan

- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    [self read_okwan_info];
    
    self.orientationMaskValue = UIInterfaceOrientationMaskAll;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(okwan_didReceiveScreenChanged:) name:@"TBOrientationChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(okwan_onLogin:) name:@"login" object:nil];
    [TBsdkManagerCode manager];
    
    callback(@"true");
}

- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.loginCallback = callback;
    
    [TBsdkManagerCode TBstartLoginWithGid:self.okwan_gid apiKey:self.okwan_apiKey secretKey:self.okwan_secretKey version:@"1.0.0" attach:@""];
}

- (void)Logout:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    [TBsdkManagerCode TBLoginOutDidSuccess:^(BOOL isSuccess) {
        callback(@"true");
    }];
}

- (void)Pay:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
//    public class PayInfo
//    {
//        public string OrderId;     //订单号
//        
//        //1 消耗型计费点,如金币，元宝等
//        //2:非消耗型计费点,一次购买永远拥有的，如vip等功能
//        //3:订阅型计费点，如使用周期一个星期，到期后还需要续费的
//        public string paymentType;
//        
//        public string ProductId;   //商品id
//        public string Title;       //商品名称
//        public string Price;       //充值金额，单位分
//        public string Des;         //商品描述
//        public string Count;       //商品数量
//        public string Vcname;      //虚拟货币名称
//        public string AddVCount;       //添加的虚拟货币数量
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
    NSInteger amount = [infoDic[@"Price"] integerValue];
    NSString* amountStr = [NSString stringWithFormat:@"%lu", amount / 100];
    requestModelCode.TBamount = amountStr;
    /** 商品数量 */
    requestModelCode.TBgoodsNum = infoDic[@"Count"];
    /** 服务器id */
    requestModelCode.TBserverID = [SdkDataManager Instance].ServerId;
    /** 苹果内购的商品id */
    requestModelCode.TBproductID = infoDic[@"ProductId"];
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
//        if (url != nil) {
//            [QKWebViewController showWeb:url];
//        }
    } error:^(NSString *errorMsg) {
        
    }];
}

- (void)TBwithdrawal:(NSString*)strData
{
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    NSString* roleName = [SdkDataManager Instance].RoleName;
    NSString* serverID = [SdkDataManager Instance].ServerId;
    NSInteger amount = [infoDic[@"Amount"] integerValue];
    NSString* amountStr = [NSString stringWithFormat:@"%lu", amount / 100];
    NSString* extraInfo = infoDic[@"ExtraInfo"];
    [TBsdkManagerCode TBwithdrawalWithRoleName:roleName serverID:serverID amount:amountStr attach:extraInfo completion:^(BOOL isSuccess, NSString *url, NSString *errorMsg) {
//        if (url != nil) {
//            [QKWebViewController showWeb:url];
//        }
    }];
}

- (void)TBLaladui:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    NSURL* url = [NSURL URLWithString:@"laladui://goToCashPage/legendsOfBounty"];
//    NSURL* url = [NSURL URLWithString:strData];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        callback(@"true");
    } else {
//        NSURL* weburl = [NSURL URLWithString:@"https://www.raradui.com/shangjin_index.php"];
//        [[UIApplication sharedApplication] openURL:weburl];
        callback(@"false");
    }
}

//--------------- for AppController ---------------
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
//    return [super application:application supportedInterfaceOrientationsForWindow:window];
    return self.orientationMaskValue;
//    return UIInterfaceOrientationMaskAll;
//    return (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
//    | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
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
    
    NSString *urlStr = [NSString stringWithFormat:@"http://chklogin.sjcq.xgd666.com/checklogin.php?channel=ios_okw&token=%@&api_key=%@", scode, self.okwan_apiKey];
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
- (void)okwan_didReceiveScreenChanged:(NSNotification*)notif {
    NSInteger changeValue = [notif.object integerValue];
    self.orientationMaskValue = changeValue;
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

- (void)read_okwan_info {
    NSString *fileName = @"okwan_info.plist";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (filePath == nil) {
        NSLog(@"找不到文件：%@", fileName);
        return;
    }
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:filePath];
    self.okwan_gid=[dict valueForKey:@"okwan_gid"];
    self.okwan_apiKey=[dict valueForKey:@"okwan_apiKey"];
    self.okwan_secretKey=[dict valueForKey:@"okwan_secretKey"];
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

//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
