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
                                             selector:@selector(onInitLoginSuccess:) name:JHonLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onInitLoginFailed:) name:JHonLoginFailed object:nil];
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
    [[ZoneApp sharedZoneApp] initWithAppId:@"ZKAPPID" withAppKey:@"ZKAPPKey" Ad_id:@"ZKAD_ID"];
    
}
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

-(void)authenticationWithAuthorize_code:(NSString *)authorize_code {
    NSMutableDictionary *params = [NSMutableDictionary dictionary]; [params setObject:@"6001" forKey:@"app_id"];
    [params setObject:authorize_code forKey:@"authorize_code"];
    [params setObject:@"base" forKey:@"scope"];
    [params setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    //    NSString *sign = [self lastSignWithParams:params Appkey:@"6a54862f-2a29-43fd-a923-11e9fe15b8c7"];
    //    [params setObject:sign forKey:@"sign"];
    
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
        
        
        if (responseObject != nil && [[responseObject objectForKey:@"state"]
                                      intValue] == 1){
            
            
            NSDictionary *dataDic = [responseObject objectForKey:@"data"];
            NSString *userid=[QKSdkProxyUtility stringValue:[dataDic objectForKey:@"user_id"]];
            NSString *token=[QKSdkProxyUtility stringValue:[dataDic objectForKey:@"access_token"]];
            NSString *username=[QKSdkProxyUtility stringValue:[dataDic objectForKey:@"user_name"]];
            SDKLoginUser *user = [SDKLoginUser new];
            user.user_id = [dataDic objectForKey:@"user_id"];
            user.user_name = [dataDic objectForKey:@"user_name"];
            user.access_token = [dataDic objectForKey:@"access_token"];
            
            [SdkDataManager Instance].SdkUid=userid ;
            [SdkDataManager Instance].loginToken=token;
            [SdkDataManager Instance].ServerName=username;
            NSDictionary* dic=@{@"IsSuccess":@YES,
                                @"Uid":userid,
                                @"Token":token,
                                @"UidName":username
                                };
            //[[ZoneApp sharedZoneApp]onLoginRespWithUserInfo:user];
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
    self.LoginInitCallback = callback;
    [[ZoneApp sharedZoneApp]userLogout];
}
-(void)Pay:(NSString *)strData callback:(QKUnityCallbackFunc)callback{
    self.PayInitCallBack = callback;
    self.PayCancelInitCallBack=callback;
    GMmentInfo *info=[[GMmentInfo alloc]init];
    [info setOut_trade_no:@"1234567890"];
    [info setTotal_charge:600];
    [info setProduct_amount:60];
    [info setProduct_id:@"11RoomCards"];
    [info setProduct_name:@"钻石"];
    [info setRate:10];
    [info setProduct_desc:@"这个是支付的详细信息"];
    [info setCallback_url:@"http://baidu.com"];
    [info setRole_id:@"asdfasdfasdf"];
    [info setServer_id:@"1"];
    [info setRole_name:@"测试角色名"];
    [info setZone_Info:@"99"];
    [info setCurrency_code:@"CNY"];
    [info setExtend:@""];
    
    [[ZoneApp sharedZoneApp] RealmentInfo:info];
//    [[SDKCenter sharedSDKCenter]RealmentInfo:info];
}

- (void)onInitSuccess:(id)sender {
    self.initCallback(@"true");
}
-(void)onInitFailed:(id)sender{
    self.initCallback(@"false");
}
-(void)onInitLoginSuccess:(id)sender{
    self.LoginInitCallback(@"true");
}
-(void)onInitLoginFailed:(id)sender{
    self.LoginInitCallback(@"false");
}
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
    
}
@end





