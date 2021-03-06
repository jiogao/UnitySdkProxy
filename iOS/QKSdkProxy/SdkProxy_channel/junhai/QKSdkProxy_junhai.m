//
//  QKSdkProxy_junhai.m
//  Unity-iPhone
//
//  Created by wending on 2018/5/23.
//

#import "QKSdkProxy_junhai.h"

#import <GameAgent/JHAgentCommon.h>
#import "QKSdkProxyUtility.h"
#import "SdkDataManager.h"

IMPL_QKSDK_PROXY_SUBCLASS(QKSdkProxy_junhai)

@interface QKSdkProxy_junhai ()

@property(nonatomic, copy) QKUnityCallbackFunc initCallback;
@property(nonatomic, copy) QKUnityCallbackFunc loginCallback;
@property(nonatomic, copy) QKUnityCallbackFunc logoutCallback;
@property(nonatomic, copy) QKUnityCallbackFunc payCallback;

@end

@implementation QKSdkProxy_junhai

- (void)SdkInit:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.initCallback = callback;
    
    [[JHAgentCommon sharedJHAgentCommon] setRootViewController:UnityGetGLViewController()];
    // TODO:这里先进行游戏引擎初始化的相关操作
    // 先注册初始化回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onInitSuccess:) name:JHASonInitSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onInitFailed:) name:JHASonInitFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onLogoutSuccess:) name:JHASonLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onLogoutFailed:) name:JHASonLogoutFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onLoginSuccess:) name:JHASonLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onLoginFailed:) name:JHASonLoginFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onPaySuccess:) name:JHASonPaySuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onPayFailed:) name:JHASonPayFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(junhai_onPayCancel:) name:JHASonPayCancel object:nil];
    
    // 开始SDK初始化操作
    [[JHAgentCommon sharedJHAgentCommon] initSDK];
}

- (void)Login:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    NSLog(@"Login()........");
    self.loginCallback = callback;
    [[JHAgentCommon sharedJHAgentCommon] setRootViewController:UnityGetGLViewController()];
    [[JHAgentCommon sharedJHAgentCommon] login];
}

- (void)Logout:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
     NSLog(@"Logout()........");
    self.logoutCallback = callback;
    [[JHAgentCommon sharedJHAgentCommon] logout];
}

- (void)Pay:(NSString*)strData callback:(QKUnityCallbackFunc)callback
{
    self.payCallback = callback;
    /**
     @property (strong) NSString *orderId;//订单号
     @property (strong) NSString *productId;//商品ID
     @property (strong) NSString *productName;//商品名称
     @property (assign) unsigned int productCount;//商品数量
     @property (assign) unsigned int payMoney;//总金额，单位为分
     @property (assign) unsigned int serverId;//区服id
     @property (strong) NSString *serverName;//区服名称
     @property (strong) NSString *roleId;//角色id
     @property (strong) NSString *roleName;//角色名
     @property (assign) unsigned int rate;//兑换比例，即1元可以买多少商品
     @property (strong) NSString *paymentDesc;//订单详情信息
     @property (strong) NSString *notifyUrl;//充值回调地址
     **/
    
    NSLog(@"充值接口调用。。。。");
    NSDictionary* infoDic = [QKSdkProxyUtility Json_StringToDic:strData];
    
    JHASPaymentInfo *info = [[JHASPaymentInfo alloc] init];
    [info setOrderId:infoDic[@"OrderId"]];   //订单号，必传。
    [info setPayMoney:[infoDic[@"Price"] intValue]]; //支付金额，单位为分，必传。
    [info setProductCount:[infoDic[@"Count"] intValue]]; //商品数量，必传。
    [info setProductId: infoDic[@"ProductId"]];   //商品ID，必传。
    [info setProductName: infoDic[@"Title"]];   //商品名，商品名称前请不要添加任何量词。如钻石。必传。
    [info setRate:100]; //兑换比例，即1元可以买多少商品
    [info setPaymentDesc:infoDic[@"Des"]];    //订单详情信息，必传
    [info setNotifyUrl:@"http://rmb.jzsc3.xgd666.com/callback/51_1_ios_jh/pay.php"];    //支付结果回调地址，必传
    [info setRoleId:[SdkDataManager Instance].RoleId];  //角色id，必传
    [info setRoleName:[SdkDataManager Instance].RoleName];    //角色名，必传
    [info setServerId:[[SdkDataManager Instance].ServerId intValue]];   //区服id，必传
    [info setServerName:[SdkDataManager Instance].ServerName];   //区服名称，必传
    
    [[JHAgentCommon sharedJHAgentCommon] payWithPayMentInfo:info];
}

- (void)SelectServer:(NSString*)strData
{
    [super SelectServer:strData];
}

- (void)CreateRole:(NSString*)strData
{
    [super CreateRole:strData];
    [self uploadUserData:strData type:JH_CREATE_ROLE];
}

- (void)SelectRole:(NSString*)strData
{
    [super SelectRole:strData];
    [self uploadUserData:strData type:JH_ENTER_SERVER];
}

- (void)LevelUp:(NSString*)strData
{
    [super LevelUp:strData];
    [self uploadUserData:strData type:JH_ROLE_UPDATE];
}

//上报物品变化信息
- (void)UpdateUserGoods:(NSString*)strData
{
    NSLog(@"上报物品信息变化。。。。");
    [super UpdateUserGoods:strData];
    
    JHASBuyItemInfo *itemInfo = [[JHASBuyItemInfo alloc]init];
    itemInfo.userId = [SdkDataManager Instance].SdkUid;
    itemInfo.roleId = [SdkDataManager Instance].RoleId;
    itemInfo.playerName = [SdkDataManager Instance].RoleName;
    itemInfo.serverId = [[SdkDataManager Instance].ServerId intValue];
    itemInfo.consumeCoin = [[SdkDataManager Instance].ConsumCoin intValue];  //消耗 10 虚拟货币
    itemInfo.remainCoin = [[SdkDataManager Instance].RemainCoin intValue];
    itemInfo.consumeBindCoin = [[SdkDataManager Instance]. ConsumeBind intValue];
    itemInfo.remainBindCoin = [[SdkDataManager Instance].RemainBind intValue];
    itemInfo.itemName = [SdkDataManager Instance].ItemName;
    itemInfo.itemCount = [[SdkDataManager Instance].ItemCount intValue];
    itemInfo.itemDesc = [SdkDataManager Instance].ItemDes;
    
    [[JHAgentCommon sharedJHAgentCommon] onBuyItem:itemInfo];
}

//上报用户数据
- (void)uploadUserData:(NSString*)strData type:(NSString*)type
{
    NSDictionary *dict = @{JH_ROLE_ID:[SdkDataManager Instance].RoleId,   //角色ID
                           JH_ROLE_NAME:[SdkDataManager Instance].RoleName,    //角色名
                           JH_ROLE_LEVEL:[SdkDataManager Instance].RoleLevel,   //角色等级
                           JH_SERVER_ID:[SdkDataManager Instance].ServerId, //区服ID
                           JH_SERVER_NAME:[SdkDataManager Instance].ServerName,   //区服名称
                           JH_VIP_LEVEL:[SdkDataManager Instance].RoleVipLevel,   //VIP等级
                           JH_PRODUCT_COUNT:@"0",   //商品数量
                           JH_PRODUCT_NAME:@"0",};  //商品名
    [[JHAgentCommon sharedJHAgentCommon] uploadUserData:type userData:dict];
}

//---------------JunHaiSdkDelegate---------------
-(void)junhai_onInitSuccess:(NSNotification *)result
{
     NSLog(@"onInitSuccess()........");
    self.initCallback(@"true");
}

-(void)junhai_onInitFailed:(NSNotification *)result
{
     NSLog(@"onInitFailed()........");
    self.initCallback(@"false");
}

-(void)junhai_onLoginSuccess:(NSNotification *)result
{
    NSLog(@"loginSuccess : %@", result);
    
    //[self dispatchMsg:@"SDKmsg" msg:@"登陆回调成功"];
    NSDictionary *userInfo = (NSDictionary *)result.object;
    // 目前Dictionary中只有SessionID有用，请使用常量获取该值即可进行验证
    
    NSString *channel = @"ios_jh";
    NSString *userId = [userInfo objectForKey:JH_UID];
    NSString *token = [userInfo objectForKey:JH_SESSION_ID];
    int channel_id = JHAgentCommon.sharedJHAgentCommon.getChannelId; //[userInfo objectForKey:JH_CHANNEL_ID];
    int game_id = 153;
    int game_channel_id = JHAgentCommon.sharedJHAgentCommon.getGameChannelId;
    
    if (![token isEqualToString:@""])
    {
        // NSData *getdata = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        //NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
        //NSString *appId = [dict objectForKey:@"DALAN_APPID"];
        //NSString* defurl = [NSString stringWithFormat:@"http://jzsc2.chklogin.xgd666.com/checklogin.php?appid=%@&channel=ios_jh&sessionid=", appId];
        //        NSString *loginUrl = [NSString stringWithFormat:@"http://chklogin.jzsc3.xgd666.com/checklogin.php?channel=%@&userId=%@&token=%@&productCode=%d@%d@%d", channel, userId, token, productCode, game_id, game_channel_id];
        NSString *loginUrl = [NSString stringWithFormat:@"http://chklogin.jzsc3.xgd666.com/checklogin.php?channel=%@&userId=%@&token=%@&productCode=%d@%d@%d", channel, userId, token, channel_id, game_id, game_channel_id];
        
        NSLog(@"loginUrl:%@", loginUrl);
        //二次验证
        loginUrl = [loginUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:loginUrl]];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:60];
        [request setHTTPShouldHandleCookies:FALSE];
        [request setHTTPMethod:@"GET"];
        
        NSHTTPURLResponse *response;
        NSError *errorstr;
        NSData *returnData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        
        NSString *strReturn =[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"HTTP strReturn: %@", strReturn);
        NSLog(@"HTTP请求结果: %ld; %@", [(NSHTTPURLResponse *)response statusCode], errorstr);
        if(strReturn!=nil){//返回有值
            if(errorstr){
                //                NSLog(@"HTTP请求失败");
            }else if([(NSHTTPURLResponse *)response statusCode]!=200){
                //                NSLog(@"HTTP请求失败");
            }else{
                //登录成功
                NSData *nsreturndata = [strReturn dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:nsreturndata options:NSJSONReadingMutableLeaves error:nil];
                
                if (dictionary != nil)
                {
                    NSLog(@"Second check success:%@",dictionary);
                    NSString *retCode = [dictionary objectForKey:@"ret"]; //是否成功
                    if([retCode isEqualToString:@"1"]){//返回成功
                        
                        //                        NSString *content = [dictionary objectForKey:@"content"];
                        //                        NSData *contentDATA = [content dataUsingEncoding:NSUTF8StringEncoding];
                        //                        NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:contentDATA options:kNilOptions error:nil];
                        
                        NSDictionary *contentDic = [dictionary objectForKey:@"content"];
                        
                        if(contentDic !=nil)
                        {
                            NSString *userid = [QKSdkProxyUtility stringValue:[contentDic objectForKey:@"user_id"]]; //获取userid
                            NSString *token = [QKSdkProxyUtility stringValue:[contentDic objectForKey:@"access_token"]]; //获取token
                            
                            [SdkDataManager Instance].SdkUid = userid;
                            [SdkDataManager Instance].loginToken = token;
                            NSDictionary* dic = @{@"IsSuccess":@YES,
                                                  @"Uid":userid,
                                                  @"Token":token};
                            NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                            self.loginCallback(retStr);
                            
                            JHASLoginUser  *loginUser = [JHASLoginUser new];
                            loginUser.uid = userid;
                            loginUser.token = token;
                            
                            [[JHAgentCommon sharedJHAgentCommon] onLoginResp:loginUser];
                            
                            NSLog(@"loginUser uid:%@,accessToken:%@",userid,token);
                        }else{
                            NSLog(@"login error contentDic == null");
                            NSDictionary* dic = @{@"IsSuccess":@NO};
                            NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                            self.loginCallback(retStr);
                        }
                        
                    }else{//返回失败
                        NSLog(@"login error retCode: %@", retCode);
                        NSDictionary* dic = @{@"IsSuccess":@NO};
                        NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                        self.loginCallback(retStr);
                    }
                }else{//解析dictionary失败
                    NSLog(@"login error 解析dictionary失败");
                    NSDictionary* dic = @{@"IsSuccess":@NO};
                    NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
                    self.loginCallback(retStr);
                }
            }
        }
    }
}

-(void)junhai_onLoginFailed:(NSNotification *)result
{
    NSLog(@"login junhai_onLoginFailed");
    NSDictionary* dic = @{@"IsSuccess":@NO};
    NSString* retStr = [QKSdkProxyUtility Json_DicToString:dic];
    self.loginCallback(retStr);
}

-(void)junhai_onLogoutSuccess:(NSNotification *)result
{
    if (self.logoutCallback) {
        self.logoutCallback(@"true");
        self.logoutCallback = nil;
    } else {
      [QKUnityBridgeManager.Instance CallUnity:@"SdkLogoutEvent" strData:@""];
    }
}

-(void)junhai_onLogoutFailed:(NSNotification *)result
{
    if (self.logoutCallback) {
        self.logoutCallback(@"false");
        self.logoutCallback = nil;
    }
}

-(void)junhai_onPaySuccess:(NSNotification *)result
{
    NSLog(@"充值成功。。。。");
    self.payCallback(@"true");
}

-(void)junhai_onPayFailed:(NSNotification *)result
{
    NSLog(@"充值失败。。。。");
    self.payCallback(@"false");
}

-(void)junhai_onPayCancel:(NSNotification *)result
{
    NSLog(@"充值取消。。。。");
    self.payCallback(@"false");
}

-(void)JunhaiGetRealNameInfo:(NSString*)strData callback:(QKUnityCallbackFunc)callback{
    NSLog(@"获取实名认证信息接口调用。。。。。。。");
    [[JHAgentCommon sharedJHAgentCommon] ga_getUserAuthenticationInfo:^(JHAuthentication authenticationCode, NSDictionary *userInfo) {
        if (authenticationCode == JHAuthenticationOK) {
            NSLog(@"获取实名制信息成功并回调!!!!!");
            
            NSDictionary*data = @{
                                  @"retCode": [NSNumber numberWithInteger:41],
                                  @"age":[NSNumber numberWithInteger:[userInfo[@"age"] integerValue]],
                                  @"is_adult":[NSNumber numberWithBool:[userInfo[@"is_adult"] isEqualToString:@"true"]],
                                  @"real_name_authentication":[NSNumber numberWithBool:[userInfo[@"real_name_authentication"] isEqualToString:@"true"]],
                                  @"mobile":userInfo[@"mobile"],
                                  @"real_name":userInfo[@"real_name"],
                                  @"id_card":userInfo[@"id_card"]
                                  };
            NSString*userData = [QKSdkProxyUtility Json_DicToString:data];
            callback(userData);
            
        } else if (authenticationCode == JHAuthenticationUnknow) {
            NSLog(@"实名制未知!!!!!");
            NSDictionary*data = @{
                                  @"retCode": [NSNumber numberWithInteger:40],
                                  };
            NSString*userData = [QKSdkProxyUtility Json_DicToString:data];
            callback(userData);
        }  else if (authenticationCode == JHAuthenticationNever) {
            NSLog(@"实名制功能不存在!!!!!");
            NSDictionary*data = @{
                                  @"retCode": [NSNumber numberWithInteger:42],
                                  };
            NSString*userData = [QKSdkProxyUtility Json_DicToString:data];
            callback(userData);
        }
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonInitFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonLogoutFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonLoginFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonPaySuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonPayFailed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JHASonPayCancel object:nil];
}

//--------------- for AppController ---------------
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    //注意：手趣、悦玩SDK，慎重调用此方法。部分渠道SDK UI有缺陷。
    //应用支持方向
    return [[JHAgentCommon sharedJHAgentCommon] application:application supportedInterfaceOrientationsForWindow:window];
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    //应用间跳转处理，必须在 AppDelegate 相应的方法内调用！
    [[JHAgentCommon sharedJHAgentCommon] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    //应用间跳转处理，必须在 AppDelegate 相应的方法内调用！
    [[JHAgentCommon sharedJHAgentCommon] handleUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    //应用间跳转处理，必须在 AppDelegate 相应的方法内调用！
    [[JHAgentCommon sharedJHAgentCommon] handleUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
    //程序进入后台
    [[JHAgentCommon sharedJHAgentCommon] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    //程序进入前台
    [[JHAgentCommon sharedJHAgentCommon] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    //程序进入活跃状态
    [[JHAgentCommon sharedJHAgentCommon]applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication*)application
{
    //程序进入挂起状态
    [[JHAgentCommon sharedJHAgentCommon] applicationWillResignActive:application];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    //程序意外退出
    [[JHAgentCommon sharedJHAgentCommon]applicationWillTerminate:application];
}

@end
