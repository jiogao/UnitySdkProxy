//
//  SDKJunHai.h
//  Unity-iPhone
//

#import "QKSDKSupport_junhai.h"
#import "SDKUnityApi.h"
#import "JHAgentCommon.h"
#import "SdkDataManager.h"

IMPL_QKSDK_PROXY_SUBCLASS(QKSDKSupport_junhai)

@implementation QKSDKSupport_junhai

-(void)action_init
{
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

-(void)action_login
{
    [[JHAgentCommon sharedJHAgentCommon] setRootViewController:UnityGetGLViewController()];
    [[JHAgentCommon sharedJHAgentCommon] login];
}

-(void)action_logout
{
    [[JHAgentCommon sharedJHAgentCommon] logout];
}

-(void)action_showfloat
{
    
}

-(void)action_hidefloat
{
    
}

-(void)action_pay:(NSString*) _productName
        productId:(NSString*) _productId
          orderId:(NSString*) _orderId
     productPrice:(NSString*) _productPrice
       productNum:(NSString*) _productNum
           roleId:(NSString*) _roleId
         roleName:(NSString*) _roleName
        roleLevel:(NSString*) _roleLevel
         serverId:(NSString*) _serverId
       serverName:(NSString*) _serverName
{
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
    
    NSString* PaymentDescMsg = [NSString stringWithFormat:@"充值%@元宝", _productNum];
    
    JHASPaymentInfo *info = [[JHASPaymentInfo alloc] init];
    [info setOrderId:_orderId];   //订单号，必传。
    [info setPayMoney:[_productPrice intValue]]; //支付金额，单位为分，必传。
    [info setProductCount:[_productNum intValue]]; //商品数量，必传。
    [info setProductId: _productId];   //商品ID，必传。
    [info setProductName: _productName];   //商品名，商品名称前请不要添加任何量词。如钻石。必传。
    [info setRate:100]; //兑换比例，即1元可以买多少商品
    [info setPaymentDesc:PaymentDescMsg];    //订单详情信息，必传
    [info setNotifyUrl:@"http://rmb.jzsc3.xgd666.com/callback/51_1_ios_jh/pay.php"];    //支付结果回调地址，必传
    [info setRoleId:_roleId];  //角色id，必传
    [info setServerName:_serverName];   //区服名称，必传
    [info setServerId: [_serverId intValue]];   //区服id，必传
    [info setRoleName:_roleName];    //角色名，必传
    
    [[JHAgentCommon sharedJHAgentCommon] payWithPayMentInfo:info];
}

-(void)action_createrole:(NSString*) _roleId
               roleLevel:(NSString*) _roleLevel
                roleName:(NSString*) _roleName
          roleCreateTime:(NSString*) _roleCreateTime
                serverId:(NSString*) _serverId
              serverName:(NSString*) _serverName;
{
    NSDictionary *dict = @{JH_ROLE_ID:_roleId,   //角色ID
                           JH_SERVER_ID:_serverId, //区服ID
                           JH_SERVER_NAME:_serverName,   //区服名称
                           JH_ROLE_NAME:_roleName,    //角色名
                           JH_ROLE_LEVEL:_roleLevel,   //角色等级
                           JH_VIP_LEVEL:@"0",   //VIP等级
                           JH_PRODUCT_COUNT:@"0",   //商品数量
                           JH_PRODUCT_NAME:@"0",};  //商品名
    [[JHAgentCommon sharedJHAgentCommon] uploadUserData:JH_CREATE_ROLE userData:dict];
}

-(void)action_rolelogin:(NSString*) _roleId
              roleLevel:(NSString*) _roleLevel
               roleName:(NSString*) _roleName
         roleCreateTime:(NSString*) _roleCreateTime
               serverId:(NSString*) _serverId
             serverName:(NSString*) _serverName
{
    NSDictionary *dict = @{JH_ROLE_ID:_roleId,   //角色ID
                             JH_SERVER_ID:_serverId, //区服ID
                             JH_SERVER_NAME:_serverName,   //区服名称
                             JH_ROLE_NAME:_roleName,    //角色名
                             JH_ROLE_LEVEL:_roleLevel,   //角色等级
                             JH_VIP_LEVEL:@"0",   //VIP等级
                             JH_PRODUCT_COUNT:@"0",   //商品数量
                             JH_PRODUCT_NAME:@"0",};  //商品名
    [[JHAgentCommon sharedJHAgentCommon] uploadUserData:JH_ENTER_SERVER userData:dict];
}

-(void)action_levelup:(NSString*) _roleId
            roleLevel:(NSString*) _roleLevel
             roleName:(NSString*) _roleName
       roleCreateTime:(NSString*) _roleCreateTime
             serverId:(NSString*) _serverId
           serverName:(NSString*) _serverName
{
    NSDictionary *dict = @{JH_ROLE_ID:_roleId,   //角色ID
                           JH_SERVER_ID:_serverId, //区服ID
                           JH_SERVER_NAME:_serverName,   //区服名称
                           JH_ROLE_NAME:_roleName,    //角色名
                           JH_ROLE_LEVEL:_roleLevel,   //角色等级
                           JH_VIP_LEVEL:@"0",   //VIP等级
                           JH_PRODUCT_COUNT:@"0",   //商品数量
                           JH_PRODUCT_NAME:@"0",};  //商品名
    [[JHAgentCommon sharedJHAgentCommon] uploadUserData:JH_ROLE_UPDATE userData:dict];
}

-(void)action_UpdateUserGoods:(NSString*) _userId
                    roleId:(NSString*) _roleId
                     roleName:(NSString*) _roleName
               serverId:(NSString*) _serverId
                     consumeCoin:(NSString*) _consumeCoin
                   remainCoin :(NSString*) _remainCoin
                       consumeBindCoin :(NSString*) _consumeBindCoin
                     remainBindCoin :(NSString*) _remainBindCoin
                     itemName :(NSString*) _itemName
                  itemCount :(NSString*) _itemCount
                  itemDesc  :(NSString*) _itemDesc
{
    JHASBuyItemInfo *itemInfo = [[JHASBuyItemInfo alloc]init];
    itemInfo.userId = _userId;
    itemInfo.roleId = _roleId;
    itemInfo.playerName = _roleName;
    itemInfo.serverId = [_serverId intValue];
    itemInfo.consumeCoin = [_consumeCoin intValue];  //消耗 10 虚拟货币
    itemInfo.remainCoin = [_remainCoin intValue];
    itemInfo.consumeBindCoin = [_consumeBindCoin intValue];
    itemInfo.remainBindCoin = [_remainBindCoin intValue];
    itemInfo.itemName = _itemName;
    itemInfo.itemCount = [_itemCount intValue];
    itemInfo.itemDesc = _itemDesc;
    
    [[JHAgentCommon sharedJHAgentCommon] onBuyItem:itemInfo];}

//---------------JunHaiSdkDelegate---------------
-(void)junhai_onInitSuccess:(NSNotification *)result
{
    [[SDKUnityApi Instance] onInitSuccess:result.object];
}

-(void)junhai_onInitFailed:(NSNotification *)result
{
    [[SDKUnityApi Instance] onInitFailed:result.object];
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
                    NSString *retIs = [dictionary objectForKey:@"ret"]; //是否成功
                    if([retIs isEqualToString:@"1"]){//返回成功
                        
//                        NSString *content = [dictionary objectForKey:@"content"];
//                        NSData *contentDATA = [content dataUsingEncoding:NSUTF8StringEncoding];
//                        NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:contentDATA options:kNilOptions error:nil];
                        
                        NSDictionary *contentDic = [dictionary objectForKey:@"content"];
                        
                        if(contentDic !=nil)
                        {
                            NSString *token = [contentDic objectForKey:@"access_token"]; //获取token
                            NSString *userid = [contentDic objectForKey:@"user_id"]; //获取userid
                            
                            [[SdkDataManager Instance] setSdkUserId:userid];
                            //NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
                            //NSString* channel_id = [dict objectForKey:@"CHANNEL_LABEL"];
                            
                            [[SDKUnityApi Instance] onLoginSuccess:result.object];
                            
                            JHASLoginUser  *loginUser = [JHASLoginUser new];
                            loginUser.uid = userid;
                            loginUser.token = token;
                            
                            [[JHAgentCommon sharedJHAgentCommon] onLoginResp:loginUser];
                            
                            NSLog(@"loginUser uid:%@,accessToken:%@",userid,token);
                            
                        }else{
                            NSLog(@"contentDic null");
                        }
                        
                    }else{//返回失败
                        NSLog(@"登录失败");
                    }
                }else{//解析dictionary失败
                    NSLog(@"解析dictionary失败");
                }
            }
        }
    }
}

-(void)junhai_onLoginFailed:(NSNotification *)result
{
    [[SDKUnityApi Instance] onLoginFailed:result.object];
}

-(void)junhai_onLogoutSuccess:(NSNotification *)result
{
    [[SDKUnityApi Instance] onLogoutSuccess:result.object];
}

-(void)junhai_onLogoutFailed:(NSNotification *)result
{
    [[SDKUnityApi Instance] onLogoutFailed:result.object];
}

-(void)junhai_onPaySuccess:(NSNotification *)result
{
    [[SDKUnityApi Instance] onPaySuccess:result.object];
}

-(void)junhai_onPayFailed:(NSNotification *)result
{
    [[SDKUnityApi Instance] onPayFailed:result.object];
}

-(void)junhai_onPayCancel:(NSNotification *)result
{
    [[SDKUnityApi Instance] onPayCancel:result.object];
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

//---
- (void)didReceiveMemoryWarning
{
}

@end
