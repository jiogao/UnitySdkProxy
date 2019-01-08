//
//  tucheng.m
//  Unity-iPhone
//
//  Created by wending on 2018/12/12.
//
//$(inherited) -weak_framework CoreMotion -weak-lSystem
#import "duoqu.h"
#import <WFRRramework/breaksFramework_patient.h>
#import "SdkDataManager.h"
#import "QKSdkProxyUtility.h"

IMPL_QKSDK_PROXY_SUBCLASS(duoqu)

typedef enum
{
    CREATE_ROLE,
    ENTER_SERVER,
    LEVEL_UP
} UploadUserDataType;

@interface duoqu()
@property (nonatomic, copy) QKUnityCallbackFunc loginCallback;
@property (nonatomic, copy) QKUnityCallbackFunc payCallBack;
@end

@implementation duoqu
-(void)SdkInit:(NSString *)strData callback:(QKUnityCallbackFunc)callback
{
    callback(@"true");
}

//初始化游戏启动时调用
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginCallBack:) name:@"SDFLoginCallBack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KCregchargCallBack:) name:@"SDFregchargCallBack" object:nil];
    //SDK初始化 游戏启动时调用
    breaksFramework_patient *cf = [breaksFramework_patient sharedInstance];
    [cf breaksinit_patient];
    return YES;
}

//s登录
- (void)Login:(NSString *)strData callback:(QKUnityCallbackFunc)callback
{
    self.loginCallback = callback;
    
    breaksFramework_patient *cf=[breaksFramework_patient sharedInstance];
    [cf breaksLogin_patient];
}
//登录成功回调
-(void)loginCallBack:(NSNotification *)sender{
    NSDictionary *dics=sender.userInfo;
    NSString *userid=dics[@"account"];
    NSString *token=dics[@"token"];
    NSString *time=dics[@"time"];
    [SdkDataManager Instance].SdkUid=userid ;
    [SdkDataManager Instance].loginToken=token;
//    [SdkDataManager Instance].ServerName=username;
    
    NSDictionary* dic=@{@"IsSuccess":@YES,
                        @"Uid":userid,
                        @"Token":token
                        };
    NSString* retStr=[QKSdkProxyUtility Json_DicToString:dic];
    self.loginCallback(retStr);
    
    NSLog(@"account=%@",userid);
    NSLog(@"登录成功=%@",sender.userInfo);
}
//跳转到充值页面
-(void )Pay:(NSString *)strData callback:(QKUnityCallbackFunc)callback{
    self.payCallBack = callback;
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    NSLog(@"Pay:%@",infoDic);
    NSLog(@"RoleName:%@",[SdkDataManager Instance].RoleName);
    NSLog(@"ServerId:%@",[SdkDataManager Instance].ServerId);
    NSInteger price =[[infoDic valueForKey:@"Price"]integerValue]/100;
    
    breaksFramework_patient *cf=[breaksFramework_patient sharedInstance];
    [cf breaksgamename_patient:[SdkDataManager Instance].RoleName
                         andmy:[NSString stringWithFormat:@"%ld", (long)price]
                   andserverid:[SdkDataManager Instance].ServerId
                andproductname:[infoDic valueForKey:@"Title"]
                   anddescribe:[infoDic valueForKey:@"Des"]
                andinformation:[infoDic valueForKey:@"ProductId"]
                     andattach:[infoDic valueForKey:@"ExtraInfo"]];
}

- (void)SelectServer:(NSString*)strData
{
    [super SelectServer:strData];
}

- (void)CreateRole:(NSString*)strData
{
    [super CreateRole:strData];
    [self uploadUserData:strData type:CREATE_ROLE];
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

//上报用户数据
- (void)uploadUserData:(NSString*)strData type:(UploadUserDataType)type
{
    NSDictionary* dic = nil;
    switch (type) {
        case CREATE_ROLE:
            dic = [NSDictionary dictionaryWithObject:[SdkDataManager Instance].RoleName forKey:@"role"];
            break;
            
        case ENTER_SERVER:
            dic = [NSDictionary dictionaryWithObject:[SdkDataManager Instance].ServerId forKey:@"service"];
            break;
            
        case LEVEL_UP:
            dic = [NSDictionary dictionaryWithObject:[SdkDataManager Instance].RoleName forKey:@"grade"];
            break;
        default:
            break;
    }
    
    breaksFramework_patient *cfs=[breaksFramework_patient sharedInstance];
    [cfs breaksgameccount_patient:[SdkDataManager Instance].RoleId andService:[SdkDataManager Instance].ServerName andType:[QKSdkProxyUtility Json_DicToString:dic] andRolename:[SdkDataManager Instance].RoleName andRolelevel:[SdkDataManager Instance].RoleLevel];
}

//callbackStatus:充值回调状态
//callbackStatus true (支付成功)
//callbackStatus false (支付失败)
- (void)KCregchargCallBack:(NSNotification *)sender
{
    NSDictionary * dic = sender.userInfo;
    NSString * success = dic[@"success"];
    if ([success isEqual:@"false"]) {
        NSLog(@"支付失败=%@",success);
    }
    if (self.payCallBack) {
        self.payCallBack(success);
    }
    NSLog(@"支付回调=%@",sender.userInfo);
}
//设置横屏
-(void )applicationDidBecomeActive:(UIApplication *)application
{
    [self interfaceOrientation:(UIInterfaceOrientationLandscapeRight)];
    NSLog(@"程序再次激活");
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

//z注销登录
-(void )Logout:(NSString *)strData callback:(QKUnityCallbackFunc)callback{
    callback(@"true");
}
//支付


@end
