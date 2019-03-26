//
//  QkSdkProxy_tucheng.m
//  Unity-iPhone
//
//  Created by wending on 2018/12/26.
//

#import "QkSdkProxy_tucheng.h"
#import <XSDK/XSDK.h>
#import "SdkDataManager.h"
#import "QKSdkProxyUtility.h"


IMPL_QKSDK_PROXY_SUBCLASS(QkSdkProxy_tucheng)
typedef enum{
    ROLE_ENTER,
    ENTER_SERVER,
    LEVEL_UP
} UploadUserDataType;
@interface QkSdkProxy_tucheng()
@property (nonatomic, copy) QKUnityCallbackFunc initCallback;
@property (nonatomic, copy) QKUnityCallbackFunc loginOutCallback;
@property (nonatomic, copy) QKUnityCallbackFunc loginCallback;
@property(nonatomic,copy)QKUnityCallbackFunc payCallback;
@end


@implementation QkSdkProxy_tucheng

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkInitNotify:) name:SDK_NOTIFICATION_INIT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkLoginNotify:) name:SDK_NOTIFICATION_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkRegNotify:) name:SDK_NOTIFICATION_REG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkLogoutNotify:) name:SDK_NOTIFICATION_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdkPaymentNotify:) name:SDK_NOTIFICATION_PAYMENT object:nil];
}

//登录成功回调
-(void)sdkInitNotify:(NSNotification *)sender
{
    self.initCallback(@"true");
}

//登录成功回调
-(void)sdkLoginNotify:(NSNotification *)sender
{
    UserInfo* userInfo = [sender object];
    [SdkDataManager Instance].SdkUid = userInfo.uid;
    [SdkDataManager Instance].loginToken = userInfo.token;
    //    [SdkDataManager Instance].ServerName=username;
    
    NSDictionary* dic=@{@"IsSuccess":@YES,
                        @"Uid":userInfo.uid,
                        @"Token":userInfo.token
                        };
    
    NSLog(@"登录成功=%@",dic);
    
    NSString* retStr=[QKSdkProxyUtility Json_DicToString:dic];
    self.loginCallback(retStr);
    
}

//注册成功
- (void)sdkRegNotify:(NSNotification * )nofify{
    //注册成功会调用自动登录，若CP有其他处理可在此处CODE
    NSLog(@"--------------注册成功----------------");
}

//注销登录成功
- (void)sdkLogoutNotify:(NSNotification * )nofify{
    //注销登录接口
    NSLog(@"--------------注销登录成功----------------");
    self.loginOutCallback(@"true");
}

//支付成功
- (void)sdkPaymentNotify:(NSNotification * )nofify{
    NSLog(@"--------------支付成功----------------");
    NSDictionary* data = [nofify object];
    NSString* trade_no = [data objectForKey:@"trade_no"];
    float amount = [[data objectForKey:@"amount"] floatValue];
    NSString* subject = [data objectForKey:@"subject"];
    //    NSString* body = [data objectForKey:@"body"];
    //    int server = [[data objectForKey:@"server"] intValue];
    //    NSString* role_id = [data objectForKey:@"role_id"];
    //    NSString* role_name = [data objectForKey:@"role_name"];
    
    NSString *content=[NSString stringWithFormat:@"trade_no:%@\namount:%f\nsubject:%@", trade_no, amount, subject];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付回调信息" message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)SdkInit:(NSString *)strData callback:(QKUnityCallbackFunc)callback
{
    self.initCallback = callback;
    [self registerNotification];
    
    [[SDKManager getInstance] setScreenOrientation:UIInterfaceOrientationLandscapeLeft];
    [[SDKManager getInstance] init:@"10019" appKey:@"6301618f3a8c652920805bd821df566e"];
}

//登录
- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.loginCallback = callback;
    [[SDKManager getInstance]login];
}
- (void)showUserInfo{
    if(![[SDKManager getInstance] isLogin]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"还未登录！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    UserInfo* userInfo = [[SDKManager getInstance] getUserInfo];
    
    NSString *content=[NSString stringWithFormat:@"username:%@\nuid:%@\ntoken:%@", userInfo.userName, userInfo.uid, userInfo.token];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录回调信息" message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)Pay:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.payCallback=callback;
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    NSLog(@"充值接口调用。。。。: $@", strData);
    [[SDKManager getInstance] payment:[infoDic valueForKey:@"ProductId"] tradeNo:[infoDic valueForKey:@"OrderId"] amount:[[infoDic valueForKey:@"Price"] integerValue]/100 subject:[infoDic valueForKey:@"Title"] body:[infoDic valueForKey:@"Des"] server:1 role_id:[SdkDataManager Instance].RoleId role_name:[SdkDataManager Instance].RoleName];
}
- (void)Logout:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.loginOutCallback=callback;
    [[SDKManager getInstance]logout];
}
- (void)CreateRole:(NSString*)strData
{
    [super CreateRole:strData];
    [self uploadUserData:strData type:ROLE_ENTER];
}

- (void)SelectRole:(NSString*)strData
{
    [super SelectRole:strData];
    [self uploadUserData:strData type:ENTER_SERVER];
}

- (void)LevelUp:(NSString*)strData
{
    [super LevelUp:strData];
    [self uploadUserData:strData type:LEVEL_UP];
}

- (void)RoleChat:(NSString*)strData
{
    [super RoleChat:strData];
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    [[SDKManager getInstance]roleChat:[SdkDataManager Instance].ServerId cp_uid:[infoDic valueForKey:@"Uid"] role_id:[infoDic valueForKey:@"PlayerID"] role_name:[infoDic valueForKey:@"Player"] flag:[infoDic valueForKey:@"Flag"] msg:[infoDic valueForKey:@"Msg"] receiver:[infoDic valueForKey:@"Receiver"]];
}

//上报用户数据
- (void)uploadUserData:(NSString*)strData type:(UploadUserDataType)type
{
    NSLog(@"strData: %@", strData);
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    switch (type) {
        case ROLE_ENTER:
            [[SDKManager getInstance]roleEnter:[SdkDataManager Instance].ServerId cp_uid:[infoDic valueForKey:@"RoleId"] role_id:[infoDic valueForKey:@"RoleId"] role_name:[infoDic valueForKey:@"RoleName"] job:@"" level:[infoDic valueForKey:@"RoleLevel"] camp:@"" faction_id:@"" faction_name:@""];
            break;
            
        case ENTER_SERVER:
            [[SDKManager getInstance]roleUpdate:[SdkDataManager Instance].ServerId cp_uid:[infoDic valueForKey:@"RoleId"] role_id:[infoDic valueForKey:@"RoleId"] role_name:[infoDic valueForKey:@"RoleName"] job:@"" level:[infoDic valueForKey:@"RoleLevel"]  camp:[SdkDataManager Instance].ServerName faction_id:@"" faction_name:@""];
            break;
            
        case LEVEL_UP:
            [[SDKManager getInstance]roleUpdate:[SdkDataManager Instance].ServerId cp_uid:[infoDic valueForKey:@"RoleId"] role_id:[infoDic valueForKey:@"RoleId"] role_name:[infoDic valueForKey:@"RoleName"] job:@"" level:[infoDic valueForKey:@"RoleLevel"]  camp:[SdkDataManager Instance].ServerName faction_id:@"" faction_name:@""];
            break;
        default:
            break;
    }
}

@end

