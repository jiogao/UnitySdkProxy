package qksdkproxy.SdkProxy_channel.junhai;

import asynchttp.AsyncHttpClient;
import asynchttp.JsonHttpResponseHandler;
import asynchttp.RequestParams;
import com.ijunhai.sdk.common.util.SdkInfo;
import com.tulongshijie.union.tulong.QKUnityPlayerActivity;
import org.json.JSONException;
import org.json.JSONObject;
import prj.chameleon.channelapi.ChannelInterface;
import prj.chameleon.channelapi.Constants;
import prj.chameleon.channelapi.IDispatcherCb;
import prj.chameleon.channelapi.cbinding.AccountActionListener;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;
import android.util.Log;
import qksdkproxy.Utility.SdkDataManager;

import java.util.HashMap;

public class QKSdkProxy_junhai extends QKBaseSdkProxy
{
    private final String TAG = "unitylog";
    @Override
    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
        super.SdkInit(strData,callback);
        Log.e(TAG,"SdkInit()....");
        ChannelInterface.init(QKUnityPlayerActivity.getInstance(), true, new IDispatcherCb() {
            @Override
            public void onFinished(int i, JSONObject jsonObject) {
                if (i == 0) {
                    Log.e(TAG,"sdk初始化成功");
                    callback.Invoke("true");
                } else {
                    Log.e(TAG,"sdk初始化失败");
                    callback.Invoke("false");
                }
            }
        });
    }

    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Login(strData,callback);
        Log.e(TAG,"Login()....");
        ChannelInterface.login(QKUnityPlayerActivity.getInstance(),
                new IDispatcherCb() {
                    @Override
                    public void onFinished(int code,
                                           JSONObject jsonObject) {
                        if (code == Constants.ErrorCode.ERR_OK)
                        {
                            try {
                                RequestParams req = new RequestParams();
                                req.put("userId",
                                        (String) jsonObject
                                                .get("uid"));
                                //req.put("user_name", (String) jsonObject.get("user_name"));
                                req.put("token",
                                        (String) jsonObject
                                                .get("session_id"));
                                req.put("channel","and_jh");

                                String productCode = ChannelInterface
                                        .getChannelID()
                                        + "@"
                                        + SdkInfo.getInstance()
                                        .getGameId()
                                        + "@"
                                        + ChannelInterface
                                        .getGameChannelId();
                                req.put("productCode", productCode);
                                req.put("others",
                                        (String) jsonObject
                                                .get("others"));
                                new AsyncHttpClient()
                                        .get(URL_Info.loginURL,req,new JsonHttpResponseHandler() {
                                                    @Override
                                                    public void onSuccess(int statusCode,cz.msebera.android.httpclient.Header[] headers,
                                                            JSONObject response) {
                                                        Log.e(TAG,"登录成功。。。。");
                                                        try {
                                                            JSONObject content = response.getJSONObject("content");
                                                            //String user_name = content.getString("user_name");
                                                            String user_id = content.getString("user_id");
                                                            String channel_id = content.getString("channel_id");
                                                            String game_channel_id = content.getString("game_channel_id");
                                                            String access_token = content.getString("access_token");
                                                            JSONObject jo = new JSONObject();
                                                            //userInfo.put("userName", user_name);
                                                            jo.put("Uid", user_id);
                                                            jo.put("IsSuccess",true);
                                                            SdkDataManager.getInstance().SdkUserId = user_id;
                                                            jo.put("Token", access_token);
                                                            jo.put("game_id", SdkInfo.getInstance().getGameId());
                                                            jo.put("channel_id", channel_id);
                                                            jo.put("game_channel_id", game_channel_id);

                                                            response.put("code", 0);
                                                            JSONObject loginInfo = new JSONObject();
                                                            loginInfo.put("uid", user_id);
                                                            loginInfo.put("token", access_token);

                                                            response.put("loginInfo", loginInfo);
                                                            ChannelInterface.onLoginRsp(response.toString());
                                                            callback.Invoke(jo.toString());

                                                        } catch (JSONException e) {
                                                            Log.e(TAG,"111111111111。。。。" + e.getMessage());
                                                            e.printStackTrace();
                                                        }
                                                    }

                                                    @Override
                                                    public void onFailure(
                                                            int statusCode,
                                                            cz.msebera.android.httpclient.Header[] headers,
                                                            String responseBody,
                                                            Throwable e)
                                                    {
                                                        Log.e(TAG,"登录失败。。。。");
                                                    }
                                                });
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        } else {
                            Log.e(TAG,"code != Constants.ErrorCode.ERR_OK");
                        }
                    }
                }, new AccountActionListener() {
                    @Override
                    public void onAccountLogout() {
                        Log.e(TAG,"SDK logout success");

                        SdkDataManager.getInstance().clearData();
                        callback.Invoke("YES");

// @TODO 游戏收到登出回调后,需要退到游戏登录界面,让玩家重新登录游戏.
//                        JSONObject jo = new JSONObject();
//                        try {
//                            jo.put("resultCode", 102);
//                            jo.put("data", "");
//
//                            SendMessage(jo.toString());
//                        } catch (JSONException e) {
//                            // TODO Auto-generated catch block
//                            e.printStackTrace();
//                        }
                    }
                });
    }

    ///获取实名制信息。
    public void JunhaiGetRealNameInfo(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
        Log.e(TAG,"JunhaiGetRealNameInfo()....");
        ChannelInterface.getPlayerInfo(QKUnityPlayerActivity.getInstance(), new IDispatcherCb()
        {
            @Override
            public void onFinished(int retCode, JSONObject data) {
                // TODO Auto-generated method stub
                /**
                 * retCode说明：
                 * Constants.ErrorCode.AUTHENTICATION_OK，表示渠道SDK有实名制且能够获取实名制结果，研发只需要通过data获取验证结果，然后实现防沉迷功能
                 * Constants.ErrorCode.AUTHENTICATION_UNKNOWN，表示渠道SDK有实名制但不能获取实名制结果，研发不需要实现实名制功能，但是需要实现防沉迷功能
                 * Constants.ErrorCode.AUTHENTICATION_NEVER，表示渠道SDK没有实名制功能，研发需要自行实现实名制功能，并实现防沉迷功能
                 *
                 返回的数据为json对象，直接从data里获取
                 研发拿到这些数据后，根据需要进行实名制和防沉迷等逻辑操作。
                 返回的数据格式如下：
                 {
                 "age": "17", 玩家年龄。如果获取不到数据就为空串。
                 "is_adult": "false", 玩家是否成年，true表示成年，false表示未成年。如果获取不到数据就为空串。注意是字符串类型。
                 "real_name_authentication": "false", 玩家是否实名制，true表示完成了实名制，false表示没有完成实名制。如果获取不到数据就为空串。注意是字符串类型。
                 "mobile": "", 玩家手机号码。如果获取不到数据就为空串。
                 "real_name": "", 玩家真实姓名。如果获取不到数据就为空串。
                 "id_card":"" 玩家身份证号码。如果获取不到数据就为空串。
                 }
                 */


                JSONObject jo = new JSONObject();
                try {

                    String ageStr = data.getString("age");
                    if(ageStr.equals(""))
                    {
                        ageStr = "0";
                    }
                    String adultStr = data.getString("is_adult");
                    if(adultStr.equals(""))
                    {
                        adultStr = "false";
                    }
                    String authenticationStr = data.getString("real_name_authentication");
                    if(authenticationStr.equals(""))
                    {
                        authenticationStr = "false";
                    }

                    int age = 0;
                    boolean is_adult = false;
                    boolean real_name_authentication = false;
                    try {
                        age = Integer.parseInt(ageStr);
                    }catch (NumberFormatException e)
                    {
                        e.printStackTrace();
                    }

                    is_adult = Boolean.valueOf(adultStr);
                    real_name_authentication = Boolean.valueOf(authenticationStr);
                    String mobile = data.getString("mobile");
                    String real_name = data.getString("real_name");
                    String id_card = data.getString("id_card");

                    jo.put("retCode", retCode);
                    jo.put("age", age);
                    jo.put("is_adult", is_adult);
                    jo.put("real_name_authentication", real_name_authentication);
                    jo.put("mobile", mobile);
                    jo.put("real_name", real_name);
                    jo.put("id_card", id_card);

                    callback.Invoke(jo.toString());
                } catch (JSONException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    try {
                        jo.put("retCode", retCode);
                    } catch (JSONException e1) {
                        e1.printStackTrace();
                    }
                    callback.Invoke(jo.toString());
                }
            }
        });
    }

    @Override
    public void Pay(String jData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Pay(jData,callback);
        Log.e(TAG,"Pay()....");
                try {
                    JSONObject jo = new JSONObject(jData);
                    String orderId = jo.getString("OrderId");
                    String roleUid = SdkDataManager.getInstance().RoleId;
                    String roleName = SdkDataManager.getInstance().RoleName;
                    String serverId = SdkDataManager.getInstance().ServerId;
                    String productName = "元宝";
                    String productID = jo.getString("ProductId");
                    String payInfo = jo.getString("Des");
                    int productCount = jo.getInt("Count");
                    int realPayMoney = jo.getInt("Price");
                    String notifyUrl = URL_Info.notifyURL;
                    ChannelInterface.buy(QKUnityPlayerActivity.getInstance(), orderId, roleUid, roleName, serverId, productName, productID, payInfo, productCount, realPayMoney, notifyUrl, new IDispatcherCb() {
                        public void onFinished(int code, JSONObject jsonObject) {
                            if (code == 0) {
                                Log.e(TAG,"支付成功！！！");
                                callback.Invoke("true");
                            } else {
                                Log.e(TAG,"支付失败！！！");
                                callback.Invoke("false");
                            }

                        }
                    });
                } catch (JSONException var12) {
                    var12.printStackTrace();
                }
    }

    @Override
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Logout(strData,callback);
        Log.e(TAG,"Logout()....");
        ChannelInterface.logout(QKUnityPlayerActivity.getInstance(), new IDispatcherCb() {
            public void onFinished(int code, JSONObject jsonObject) {
                if (22 == code) {
                    Log.e(TAG,"Logout  ！！！");
                    SdkDataManager.getInstance().clearData();
                    callback.Invoke("YES");
                }
                else{
                    Log.e(TAG,"Logout FAILURE  ！！！");
                }
            }
        });

    }

    @Override
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.ExitGame(strData,callback);
        Log.e(TAG,"ExitGame()....");
        ChannelInterface.exit(QKUnityPlayerActivity.getInstance(), new IDispatcherCb() {
            public void onFinished(int retCode, JSONObject data) {
                switch(retCode) {
                    case 25:
                        int result = data.optInt("content", 33);
                        if (result != 33) {
                            callback.Invoke("YES");
                            QKUnityPlayerActivity.getInstance().finish();
                        }
                        break;
                    case 26:
                        Log.e(TAG,"ExitGame FAILURE  ！！！");
                }

            }
        });

    }

    @Override
    public void UpdateUserGoods(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.UpdateUserGoods(strData,callback);
        Log.e(TAG,"UpdateUserGoods()....");
            try {
            JSONObject jo = new JSONObject(strData);
            HashMap<String, Object> params = new HashMap();
            params.put("action", 4);
            params.put("CONSUME_COIN", jo.getInt("ConsumCoin"));
            params.put("CONSUME_BIND_COIN", jo.getInt("ConsumeBind"));
            params.put("REMAIN_COIN", jo.getInt("RemainCoin"));
            params.put("REMAIN_BIND_COIN", jo.getInt("RemainBind"));
            params.put("ITEM_COUNT", jo.getInt("ItemCount"));
            params.put("ITEM_NAME", jo.getString("ItemName"));
            params.put("ITEM_DESC", jo.getString("ItemDes"));
            ChannelInterface.uploadUserData( QKUnityPlayerActivity.getInstance(), params);
        } catch (JSONException var3) {
            var3.printStackTrace();
        }
    }

    @Override
    public void SelectRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.SelectRole(strData,callback);
        Log.e(TAG,"SelectRole()....");
        HashMap<String, Object> params = new HashMap();
        params.put("serverID", SdkDataManager.getInstance().ServerId);
        params.put("serverName",SdkDataManager.getInstance().ServerName);
        params.put("roleID", SdkDataManager.getInstance().RoleId);
        params.put("roleName", SdkDataManager.getInstance().RoleName);
        params.put("roleLevel", SdkDataManager.getInstance().RoleLevel);
        params.put("vipLevel", SdkDataManager.getInstance().RoleVipLevel);
        params.put("balance", SdkDataManager.getInstance().RoleGold);
        params.put("partyName", "unknown");
        params.put("role_create_time", SdkDataManager.getInstance().RoleCreateTime);
        params.put("role_update_time", SdkDataManager.getInstance().UpdateRoleTime);
        params.put("action", 1);
        ChannelInterface.uploadUserData( QKUnityPlayerActivity.getInstance(), params);
    }

    @Override
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
        super.CreateRole(strData,callback);
        Log.e(TAG,"CreateRole()....");
        HashMap<String, Object> params = new HashMap();
        params.put("serverID", SdkDataManager.getInstance().ServerId);
        params.put("serverName",SdkDataManager.getInstance().ServerName);
        params.put("roleID", SdkDataManager.getInstance().RoleId);
        params.put("roleName", SdkDataManager.getInstance().RoleName);
        params.put("roleLevel", SdkDataManager.getInstance().RoleLevel);
        params.put("vipLevel", SdkDataManager.getInstance().RoleVipLevel);
        params.put("balance", SdkDataManager.getInstance().RoleGold);
        params.put("partyName", "unknown");
        params.put("role_create_time", SdkDataManager.getInstance().RoleCreateTime);
        params.put("role_update_time", SdkDataManager.getInstance().UpdateRoleTime);
        params.put("action", 2);
        ChannelInterface.uploadUserData( QKUnityPlayerActivity.getInstance(), params);
    }

    @Override
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LevelUp(strData,callback);
        Log.e(TAG,"LevelUp()....");
        HashMap<String, Object> params = new HashMap();
        params.put("serverID", SdkDataManager.getInstance().ServerId);
        params.put("serverName",SdkDataManager.getInstance().ServerName);
        params.put("roleID", SdkDataManager.getInstance().RoleId);
        params.put("roleName", SdkDataManager.getInstance().RoleName);
        params.put("roleLevel", SdkDataManager.getInstance().RoleLevel);
        params.put("vipLevel", SdkDataManager.getInstance().RoleVipLevel);
        params.put("balance", SdkDataManager.getInstance().RoleGold);
        params.put("partyName", "unknown");
        params.put("role_create_time", SdkDataManager.getInstance().RoleCreateTime);
        params.put("role_update_time", SdkDataManager.getInstance().UpdateRoleTime);
        params.put("action", 3);
        ChannelInterface.uploadUserData( QKUnityPlayerActivity.getInstance(), params);
    }
}