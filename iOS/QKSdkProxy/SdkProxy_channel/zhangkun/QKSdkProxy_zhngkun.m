//
//  QKSdkProxy_zhngkun.m
//  Unity-iPhone
//
//  Created by wending on 2018/9/26.
//

#import "QKSdkProxy_zhngkun.h"
#import <ZoneUnion/ZoneApp.h>
#import "AFNetworking.h"
#import "SdkDataManager.h"
#import "QKSdkProxyUtility.h"
#import <CommonCrypto/CommonDigest.h>



IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_zhngkun)

@interface QKSdkProxy_zhngkun ()

@property (nonatomic, copy) QKUnityCallbackFunc initCallback;
@property(nonatomic,copy) QKUnityCallbackFunc LoginInitCallback;
@property(nonatomic,copy)QKUnityCallbackFunc LoginOutInitCallback;
@property(nonatomic,copy)QKUnityCallbackFunc PayInitCallBack;
@property(nonatomic,copy)QKUnityCallbackFunc PayCancelInitCallBack;
@end
@implementation QKSdkProxy_zhngkun
- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.initCallback = callback;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitSuccess:) name:JHonInitSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitFailed:) name:JHonInitFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLoginSuccess:) name:JHonLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onLoginFailed:) name:JHonLoginFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitLogoutSuccess:) name:JHonLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitLogoutFailed:) name:JHonLogoutFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitPaySuccess:) name:JHonPopSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitPayFailed:) name:JHonPopFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitPayCancelFailed:) name:JHonPopCancel object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitChangeUserFailed:) name:JHonChangeUser object:nil];
    [[ZoneApp sharedZoneApp] initWithAppId:@"6699" withAppKey:@"2f02388c-09ba-4e38-b491-993fa3e58c98" Ad_id:@"697783"];
    
}
/*
 extern NSString * const JHonInitSuccess;
 extern NSString * const JHonInitFailed;
 extern NSString * const JHonLoginSuccess;  //SDK登录成功的回调(通知),接入方通过通知拿到authorize_code 再做鉴权
 extern NSString * const JHonLoginFailed;
 extern NSString * const JHonLogoutSuccess;
 extern NSString * const JHonLogoutFailed;
 extern NSString * const JHonPopSuccess;
 extern NSString * const JHonPopFailed;
 extern NSString * const JHonPopCancel;
 extern NSString * const JHonChangeUser;  //换号
 */
- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.LoginInitCallback = callback;
    [[ZoneApp sharedZoneApp]startLogin];
}


-(BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[ZoneApp sharedZoneApp] applicationDidBecomeActive:application];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [[ZoneApp sharedZoneApp] applicationWillTerminate:application];
}
-(NSString *)lastSignWithParams:(NSDictionary *)params Appkey:(NSString *)appkey {
    //   1. 参数 排序
    NSArray *sign_array = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *signStr = [self buildQueryString:params sortArray:sign_array needUrlEncode:YES];
    //   2. 拼接 appkey
    NSString *signkey = [NSString stringWithFormat:@"%@%@",signStr, appkey];
    //   3. md5 加密
    NSString *sign = [self md5:signkey];
    return sign;
}

- (NSString *)buildQueryString:(id)dict sortArray:(NSArray *)sortArray needUrlEncode:(BOOL)isEncode {
    if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSDictionary class]]) {
        NSMutableString *tempMsg = [NSMutableString string];
        for (id str in sortArray){
            NSString *urlEncodedStr = nil;
            urlEncodedStr = [dict objectForKey:str];
            [tempMsg appendString:[NSString stringWithFormat:@"%@=%@&", str, urlEncodedStr]];
        }
        NSString *queryMsg = [tempMsg substringToIndex:tempMsg.length - 1];
        return queryMsg;
    }else{
        [NSException raise:@"SDK Error" format:@"不可用数据类型 %@", [dict class]];
        return nil;
    }
}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[32];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

/*  SDK登录成功 接入方获得通知
 *   1.接入方拿到 authorize_code, 做鉴权登录
 *   2.登录二次验证 传给SDK 用户信息:  SDKLoginUser
 */
- (void)onLoginSuccess:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)notification.object;
    NSString *authorize_code = [userInfo objectForKey:HGW_AUTHORIZE_CODE];
    NSLog(@"SDK传过来:%@", authorize_code);
    // 拿到 authorize_code 鉴权
    [self authenticationWithAuthorize_code:authorize_code];
}

-(void)onLoginFailed:(id)sender{
    NSDictionary* dic=@{@"IsSuccess":@NO};
    NSLog(@"登录失败 onLoginFailed");
    NSString* retStr=[QKSdkProxyUtility Json_DicToString:dic];
    self.LoginInitCallback(retStr);
}

-(void)authenticationWithAuthorize_code:(NSString *)authorize_code {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"6699" forKey:@"app_id"];
    [params setObject:authorize_code forKey:@"authorize_code"];
    [params setObject:@"base" forKey:@"scope"];
    [params setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    NSString *sign = [self lastSignWithParams:params Appkey:@"fa288fd6-c24e-49f2-b10e-2c3c3cea3528"];
    [params setObject:sign forKey:@"sign"];
    
    NSString *URL = @"https://userapi.zkyouxi.com/token";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 20;
    AFHTTPSessionManager *jsonAFNmanager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy
                                        policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = NO;
    securityPolicy.validatesDomainName = YES;
    [jsonAFNmanager setSecurityPolicy:securityPolicy];
    [jsonAFNmanager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [jsonAFNmanager setResponseSerializer:[AFJSONResponseSerializer
                                           serializer]];
    [jsonAFNmanager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [jsonAFNmanager POST:URL parameters:params progress:^(NSProgress * _Nonnull
                                                          uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable
                responseObject) {
        NSLog(@"--请求数据成功:%@", responseObject);
        
        if (responseObject != nil && [[responseObject objectForKey:@"state"]
                                      intValue] == 1){
            
            
            NSDictionary *dataDic = [responseObject objectForKey:@"data"];
            NSString *userid=[QKSdkProxyUtility stringValue:[dataDic objectForKey:@"user_id"]];
            NSString *token=[QKSdkProxyUtility stringValue:[dataDic objectForKey:@"access_token"]];
            NSString *username=[QKSdkProxyUtility stringValue:[dataDic objectForKey:@"user_name"]];
            [SdkDataManager Instance].SdkUid=userid ;
            [SdkDataManager Instance].loginToken=token;
            [SdkDataManager Instance].ServerName=username;
            NSDictionary* dic=@{@"IsSuccess":@YES,
                                @"Uid":userid,
                                @"Token":token,
                                //                                @"UidName":username
                                };
            
            SDKLoginUser *user = [SDKLoginUser new];
            user.user_id = [dataDic objectForKey:@"user_id"];
            user.user_name = [dataDic objectForKey:@"user_name"];
            user.access_token = [dataDic objectForKey:@"access_token"];
            [[ZoneApp sharedZoneApp]onLoginRespWithUserInfo:user];
            
            NSString* retStr=[QKSdkProxyUtility Json_DicToString:dic];
            self.LoginInitCallback(retStr);
        }else{
            NSDictionary* dic=@{@"IsSuccess":@NO};
            NSString *errMsy=[responseObject objectForKey:@"msg"];
            NSLog(@"鉴权失败:%@",errMsy);
            NSString* retStr=[QKSdkProxyUtility Json_DicToString:dic];
            self.LoginInitCallback(retStr);
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull
               error) {
        NSDictionary* dic=@{@"IsSuccess":@NO};
        NSLog(@"登录失败");
        NSString* retStr=[QKSdkProxyUtility Json_DicToString:dic];
        self.LoginInitCallback(retStr);
    }];
    
}

-(void )onPaxFaild:(NSNotification *)notification{
    NSString *errMsg=(NSString *)notification.object;
    NSLog(@"DLUnionSDKDemo:%@",errMsg);
}
-(void)Logout:(NSString *)strData callback:(QKUnityCallbackFunc)callback{
    self.LoginOutInitCallback = callback;
    [[ZoneApp sharedZoneApp]userLogout];
}
-(void)Pay:(NSString *)strData callback:(QKUnityCallbackFunc)callback{
    self.PayInitCallBack = callback;
    self.PayCancelInitCallBack=callback;
    NSLog(@"充值调用");
    NSDictionary* infoDic=[QKSdkProxyUtility Json_StringToDic:strData];
    
    GMmentInfo *info=[[GMmentInfo alloc]init];
    [info setOut_trade_no:@"OrderId"];//订单号
    [info setTotal_charge:[infoDic[@"Price"]intValue]];//支付余额
    [info setProduct_amount:[infoDic[@"Count"]intValue]];//商品数量
    [info setProduct_id:infoDic[@"ProductId"]];//商品id
    [info setProduct_name:infoDic[@"Title"]];//商品名
    [info setRate:100];//兑换比例
    [info setProduct_desc:infoDic[@"Des"]];//详细信息
    [info setCallback_url:@"http://rmb.jzsc3.xgd666.com/callback/51_1_ios_jh/pay.php"];//支付结果回调地址
    [info setRole_id:[SdkDataManager Instance].RoleId];//角色ID
    [info setRole_name:[SdkDataManager Instance].RoleName];//角色名
    [info setServer_id:[SdkDataManager Instance].ServerId];//区服ID
    
    
    
    [[ZoneApp sharedZoneApp] RealmentInfo:info];
}

- (void)onInitSuccess:(NSNotification *)notification {
    NSLog(@"SDK初始化成功");
    self.initCallback(@"true");
}

- (void)onInitFailed:(NSNotification *)notification {
    NSLog(@"SDK初始化失败：%@", (NSString *)notification.object);
    self.initCallback(@"false");
}

//- (void)onInitSuccess:(id)sender {
//    self.initCallback(@"true");
//}
//-(void)onInitFailed:(id)sender{
//   self.initCallback(@"false");
//}

-(void)onInitLogoutSuccess:(id)sender{
    self.LoginOutInitCallback(@"true");
}
-(void)onInitLogoutFailed:(id)sender{
    self.LoginOutInitCallback(@"false");
}
-(void)onInitPaySuccess:(id)sender{
    self.PayInitCallBack(@"true");
}
-(void)onInitPayFailed:(id)sender{
    self.PayInitCallBack(@"false");
}
-(void)onInitPayCancelFailed:(id)sender{
    self.PayCancelInitCallBack(@"false");
}
-(void)onInitChangeUserFailed:(id)sender{
    //    [[QKUnityBridgeManager Instance] CallUnity:<#(NSString *)#> strData:@"true"];
}
@end








