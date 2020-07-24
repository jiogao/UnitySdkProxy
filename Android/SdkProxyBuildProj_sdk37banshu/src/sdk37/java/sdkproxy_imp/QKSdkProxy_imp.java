package sdkproxy_imp;

import android.annotation.TargetApi;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.game.usdk.GameUSDK;
import com.game.usdk.listener.GameUExitListener;
import com.game.usdk.listener.GameUInitListener;
import com.game.usdk.listener.GameULoginListener;
import com.game.usdk.listener.GameULogoutListener;
import com.game.usdk.listener.GameUPayListener;
import com.game.usdk.listener.GameUSwitchAccountListener;
import com.game.usdk.model.GameUGameData;
import com.game.usdk.model.GameUOrder;
import com.game.usdk.model.GameUser;
import com.game.usdk.xutils.tools.utils.ToastUtil;

import org.json.JSONException;
import org.json.JSONObject;

import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;
import qksdkproxy.Utility.MyHttpURLConnect;
import qksdkproxy.Utility.SdkDataManager;

public class QKSdkProxy_imp extends QKBaseSdkProxy {
    //当前渠道id
    static final String c_pfid = "hope_37";

    private QKUnityBridgeManager.QKUnityCallbackFunc loginCallback;
    private String m_uid;
    private String m_token;

    @Override
    protected String Pfid()
    {
        return c_pfid;
    }
    //初始化代码
    @Override
    protected void SdkInitImp(InitImpCallback callback) {

        //初始化 - *注意* 需先添加全局回调事件后，再调用init
        GameUSDK.getInstance().init(context, new GameUInitListener() {

            @Override
            public void initSuccess() {
                callback.Invoke(true);
            }

            @Override
            public void initFail(int code, String msg) {
                Log.i("QKSdkProxy_imp", "SdkInitImp initFail: " + code + ",msg:" + msg);
                ToastUtil.toast(context, "初始化失败，code:" + code + ",msg:" + msg);
                callback.Invoke(false);
            }
        });
    }

    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Login(strData, callback);
        Log.i("QKSdkProxy_imp","StartLogin");

        loginCallback = callback;
        LoginImp();
    }

    @Override
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Logout(strData, callback);
        Log.i("QKSdkProxy_imp","Logout");

        /**
         * 该接口用于清除登录态，便于下次调用登录界面
         */
        GameUSDK.getInstance().logout(context, new GameULogoutListener() {
            @Override
            public void logoutSuccess() {
                Log.i("QKSdkProxy_imp", "logoutSuccess");
                callback.Invoke("true");
            }

            @Override
            public void logoutFail(int code, String errMsg) {
                Log.e("QKSdkProxy_imp", "logoutFail code: " + code + "msg: " + errMsg);
                callback.Invoke("false");
            }
        });
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc payCallback;
    @Override
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Pay(strData, callback);
        payCallback = callback;
        Log.i("QKSdkProxy_imp","Pay");

        try {
            JSONObject jsonObject  = new JSONObject(strData);
            String orderId = jsonObject.getString("OrderId");
            String paymentType = jsonObject.getString("paymentType");
            String productId = jsonObject.getString("ProductId");
            String orderTime = jsonObject.getString("OrderTime");
            String title = jsonObject.getString("Title");
            String price = jsonObject.getString("Price");
            String des = jsonObject.getString("Des");
            String count = jsonObject.getString("Count");
            String ratio = jsonObject.getString("Ratio");
            String sign = jsonObject.getString("Sign");
            String extraInfo = jsonObject.getString("ExtraInfo");

            GameUOrder order = new GameUOrder();
            order.setCpOrderId(orderId);
            order.setProductId(productId);
            order.setProductName(title);
            order.setRealPayMoney(Integer.parseInt(price));
            order.setRadio(Integer.parseInt(ratio));
            order.setServerId(Integer.parseInt(SdkDataManager.getInstance().ServerId));
            order.setServerName(SdkDataManager.getInstance().ServerName);
            order.setRoleId(SdkDataManager.getInstance().RoleId);
            order.setRoleName(SdkDataManager.getInstance().RoleName);
            order.setOrderTime(orderTime);
            order.setSign(sign);
            order.setChildGameId(GameUSDK.getInstance().getChildGameId());
            order.setExt(extraInfo);
            GameUSDK.getInstance().pay(context, order, new GameUPayListener() {
                @Override
                public void paySuccess() {
                    callback.Invoke("true");
                }

                @Override
                public void payFail(int code, String msg) {
                    ToastUtil.toast(context, "支付失败，msg:" + msg);
                    callback.Invoke("false");
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.ExitGame(strData, callback);
        Log.i("QKSdkProxy_imp","ExitGame");
        GameUSDK.getInstance().exit(context, new GameUExitListener() {
            @Override
            public void exitSuccess() {
                callback.Invoke("true");
            }
        });
    }

    @Override
    public void SelectServer(String strData) {
        super.SelectServer(strData);
        Log.i("QKSdkProxy_imp","SelectServer");
        ReportData(GameUGameData.GAMEDATA_TYPE_SELECT_SERVER);
    }

    @Override
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.CreateRole(strData,callback);
        Log.i("QKSdkProxy_imp","CreateRole");
        ReportData(GameUGameData.GAMEDATA_TYPE_CREATE_ROLE);
    }

    @Override
    public void SelectRole(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.SelectRole(strData, callback);
        Log.i("QKSdkProxy_imp","SelectRole");
    }

    @Override
    public  void EnterGame(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.EnterGame(strData,callback);
        Log.i("QKSdkProxy_imp","EnterGame");
        ReportData(GameUGameData.GAMEDATA_TYPE_ENTER_GAME);
    }

    @Override
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LevelUp(strData,callback);
        Log.i("QKSdkProxy_imp","LevelUp");
        ReportData(GameUGameData.GAMEDATA_TYPE_ROLE_UPDATE);
    }

    //<editor-fold desc="生命周期">
    @Override
    public void onCreate(Bundle savedInstanceState) {
        //周期方法 - onCreate() 必接
        GameUSDK.getInstance().onCreate(context, savedInstanceState);

        GameUSDK.getInstance().setSwitchAccountListener(new GameUSwitchAccountListener() {
            @Override
            public void logoutSuccess() {
                Log.i("QKSdkProxy_imp", "GameUSDK logoutSuccess");
                //悬浮窗切换账号成功，推荐游戏处理为回到登录场景页
                OnInitiativeLogout(true);
            }

            @Override
            public void logoutFail(int code, String errMsg) {
                Log.e("QKSdkProxy_imp", "GameUSDK logoutFail,code=" + code + "msg:" + errMsg);
                OnInitiativeLogout(false);
            }
        });
        //super中会调用初始化, 初始化之前需要调用的代码放在super之前
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onStart() {
        super.onStart();
        GameUSDK.getInstance().onStart();
    }

    @Override
    public void onRestart() {
        super.onRestart();
        GameUSDK.getInstance().onRestart();
    }

    @Override
    public void onResume() {
        super.onResume();
        GameUSDK.getInstance().onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
        GameUSDK.getInstance().onPause();
    }

    @Override
    public void onStop() {
        super.onStop();
        GameUSDK.getInstance().onStop();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        GameUSDK.getInstance().onDestroy();
    }

    @Override
    public void onNewIntent(Intent newIntent) {
        super.onNewIntent(newIntent);
        GameUSDK.getInstance().onNewIntent(newIntent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        GameUSDK.getInstance().onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        GameUSDK.getInstance().onConfigurationChanged(newConfig);
    }

    @Override
    @TargetApi(Build.VERSION_CODES.M)
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        GameUSDK.getInstance().onRequestPermissionResult(requestCode, permissions, grantResults);
    }
    //</editor-fold>

    //<editor-fold desc="登录流程">
    private void LoginImp() {

        GameUSDK.getInstance().login(context, new GameULoginListener() {
            @Override
            public void loginSuccess(GameUser user) {
                m_token = user.getToken();
                m_uid = user.getUid();
                Log.i("QKSdkProxy_imp","loginSuccess" + user);
//                ToastUtil.toast(context, "登录成功 \n token:" + m_token);

                CheckLogin();
            }

            @Override
            public void loginFail(int code, String errMsg) {
                String loginFailMsg = "code:" + code + ",msg:" + errMsg;
                Log.i("QKSdkProxy_imp","loginFail " + loginFailMsg);
                ToastUtil.toast(context, "登录失败：\ncode:" + loginFailMsg);
                try {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("IsSuccess", false);
                    loginCallback.Invoke(jsonObject.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void CheckLogin() {
        Log.i("QKSdkProxy_imp","CheckLogin");
        SdkHttpCommon.CheckLogin(m_uid, m_token, c_pfid, new MyHttpURLConnect.HttpHander() {

            @Override
            public void onResult(String result) {
                Log.i("QKSdkProxy_imp","CheckLogin onResult: " + result);
                try {
                    JSONObject resultJson = new JSONObject(result);
                    int errorCode = resultJson.getInt("ErrorCode");
                    String message = resultJson.getString("Message");
                    if (errorCode == 1) {
                        JSONObject dataJson = resultJson.getJSONObject("Data");
                        m_uid = dataJson.getString("uid");
//                        boolean is_phone_bind = dataJson.getBoolean("is_phone_bind");//是否绑定⼿机，1表示已绑定，0表示未绑定
//                        boolean is_idcard_bind = dataJson.getBoolean("is_idcard_bind");//是否绑定身份证，1表示已绑定，0表示未绑定
//                        boolean is_adult = dataJson.getBoolean("is_adult");//是否成年，1表示已绑定，0表示未绑定
//                        boolean vip_level = dataJson.getBoolean("vip_level");//vip等级
//                        boolean is_youke = dataJson.getBoolean("is_youke");//是否为第三⽅来源帐号，1表示是，0表示否
//                        boolean is_bind_alias = dataJson.getBoolean("is_bind_alias");//是否绑定平台个性帐号

                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("IsSuccess", true);
                        jsonObject.put("Token", m_token);
                        jsonObject.put("Uid", m_uid);
                        jsonObject.put("pfid", c_pfid);
                        loginCallback.Invoke(jsonObject.toString());
                    } else {
                        ToastUtil.toast(context, "登录校验失败：\nerror:" + errorCode + ", " + message);
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("IsSuccess", false);
                        loginCallback.Invoke(jsonObject.toString());
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("IsSuccess", false);
                    } catch (JSONException ex) {
                        ex.printStackTrace();
                    }
                    loginCallback.Invoke(jsonObject.toString());
                }
            }
        });
    }
    //</editor-fold>

    //上报数据
    //GameUGameData.GAMEDATA_TYPE_SELECT_SERVER - 选服成功(到达创角页)，注意此事件和创角事件不同（1001）
    //GameUGameData.GAMEDATA_TYPE_CREATE_ROLE - 创建角色（1002）
    //GameUGameData.GAMEDATA_TYPE_ENTER_GAME - 进入游戏（1003）
    //GameUGameData.GAMEDATA_TYPE_ROLE_UPDATE - 角色升级（1004）
    private void ReportData(int dataType) {
        GameUGameData gameData = new GameUGameData();
        gameData.setDataType(dataType); //事件类型
        gameData.setZoneId(SdkDataManager.getInstance().ServerId); //区服ID
        gameData.setZoneName(SdkDataManager.getInstance().ServerName);  //区服名称

        if (GameUGameData.GAMEDATA_TYPE_SELECT_SERVER != dataType) {
            float roleGold = 0;
            try {
                roleGold = Float.parseFloat(SdkDataManager.getInstance().RoleGold);
            } catch (Exception e) {
                e.printStackTrace();
            }
            int roleLevel = 0;
            try {
                roleLevel = Integer.parseInt(SdkDataManager.getInstance().RoleLevel);
            } catch (Exception e) {
                e.printStackTrace();
            }

            gameData.setRoleId(SdkDataManager.getInstance().RoleId); //角色ID
            gameData.setRoleName(SdkDataManager.getInstance().RoleName);   //角色名称
            gameData.setPartyName(""); //无帮派则默认传""
            gameData.setVipLevel(SdkDataManager.getInstance().RoleVipLevel); //无vip则默认传"0"
            gameData.setBalance(roleGold);   //用户余额（RMB 购买的游戏币,例如钻石）
            gameData.setRoleLevel(roleLevel); //角色等级
            gameData.setPower(0); //用户战力值

            //角色创建时间（单位：秒）（无角色时传 -1，有角色时传真实创建时间，每种类型事件均需传角色创建时间）
            gameData.setRoleCTime(SdkDataManager.getInstance().RoleCreateTime);

            //角色等级变化时间（单位：秒）（创建角色和进入游戏时传 -1，升级时传真实升级时间）
            String changeTime;
            if (GameUGameData.GAMEDATA_TYPE_ROLE_UPDATE == dataType) {
                changeTime =  String.valueOf(System.currentTimeMillis());
            } else {
                changeTime = "-1";
            }
            gameData.setRoleLevelMTime(changeTime);

        }else {
            //角色创建时间（单位：秒）（无角色时传 -1，有角色时传真实创建时间，每种类型事件均需传角色创建时间）
            gameData.setRoleCTime("-1");
        }

        GameUSDK.getInstance().reportData(gameData);
    }
}
