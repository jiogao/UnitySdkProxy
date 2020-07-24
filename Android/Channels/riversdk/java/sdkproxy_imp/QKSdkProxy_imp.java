package sdkproxy_imp;

import android.content.Intent;
import android.content.SharedPreferences;
import android.nfc.Tag;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

import com.games37.riversdk.core.RiverSDKApi;
import com.games37.riversdk.core.callback.SDKCallback;
import com.games37.riversdk.core.callback.ShowViewCallback;
import com.games37.riversdk.core.constant.CallbackKey;
import com.games37.riversdk.core.constant.StatusCode;
import com.games37.riversdk.core.login.model.UserType;
import com.games37.riversdk.core.model.SDKPlatform;
import com.games37.riversdk.core.purchase.model.PurchaseType;
import com.games37.riversdk.core.share.SocialType;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;
import qksdkproxy.Utility.MyHttpURLConnect;
import qksdkproxy.Utility.SdkDataManager;

public class QKSdkProxy_imp extends QKBaseSdkProxy {
    private final String TAG = "QKSdkProxy_imp";
    //当前渠道id
    static final String c_pfid = "1";

    private RiverSDKApi riverSDKApi;

    private QKUnityBridgeManager.QKUnityCallbackFunc loginCallback;
    private String m_uid;
    private String m_token;
    private String m_loginTimeStamp;
//    @Override
//    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
//        callback.Invoke("true");
//    }

    //初始化代码
    @Override
    protected void SdkInitImp(InitImpCallback callback) {
        //SDK初始化操作
        riverSDKApi.sqSDKInit(context, new SDKCallback() {
            @Override
            public void onResult(int statusCode, Map<String, String> params) {
                if (StatusCode.SUCCESS == statusCode) {
                    String pName = params.get(CallbackKey.PACKAGENAME);//游戏包名
                    String gameId = params.get(CallbackKey.GID);//游戏id
                    String pId = params.get(CallbackKey.PID);//平台Id
                    String ptCode = params.get(CallbackKey.PTCODE);//平台简码
                    String deviceType = params.get(CallbackKey.DEV);//设备类型

                    Log.d(TAG, "SDKInit success: " +
                            pName + "  :" + gameId + "  :" + pId + " :" + ptCode + " :" + deviceType);
                    callback.Invoke(true);

                    SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
                    boolean isLaunched = prefs.getBoolean("kIsLaunched", false);
                    if (!isLaunched) {
                        prefs.edit().putBoolean("kIsLaunched", true);
                        //上报首次启动
                        SDKTrackGameEvent("custom_loss", "launchgame_new_firsttime", "1");
                    }
                    //上报开始加载
                    SDKTrackGameEvent("custom_loss", "loading_schedule", "1");
                } else {
                    Log.d(TAG, "SDKInit fail: " + statusCode);
                    callback.Invoke(false);
                }
            }
        });
    }

    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Login(strData, callback);
        Log.i(TAG,"StartLogin");

        loginCallback = callback;
        LoginImp();
    }

    @Override
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        Log.i(TAG,"StartLogin");
        super.Logout(strData, callback);
        riverSDKApi.sqSDKLogout(context, new SDKCallback() {
            @Override
            public void onResult(int statusCode, Map<String, String> params) {
                Log.i(TAG,"StartLogin onResult: " + statusCode);
                if (statusCode == StatusCode.SUCCESS) {
                    callback.Invoke("true");
                } else {
                    //登出失败,获取提示信息
                    String msg = params.get(CallbackKey.MSG);
//                    Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
                    callback.Invoke("false");
                }
            }
        });
    }

    @Override
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Pay(strData, callback);
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

            riverSDKApi.sqSDKInAppPurchase(context,
                    SdkDataManager.getInstance().RoleId, // 角色id
                    SdkDataManager.getInstance().RoleName, // 角色名称
                    SdkDataManager.getInstance().RoleLevel, // 角色等级
                    SdkDataManager.getInstance().ServerId, // 服务器编号
                    productId, // 商品项
                    orderId, // 开发商订单号
                    extraInfo, // 扩展参数
                    PurchaseType.ITEM_TYPE_APP, // 购买类型
                    new SDKCallback() {
                        @Override
                        public void onResult(int statusCode, Map<String, String> params) {
                            Log.i(TAG,"Pay onResult: " + statusCode);
                            if (StatusCode.SUCCESS == statusCode) { // 成功
//                                // 成功只返回商品项（sku）
////                                String productId = params.get(CallbackKey.PRODUCTID);
////                                String str = "productId: " + productId;
                                callback.Invoke("true");
                            } else { // 失败
                                // 失败通过message查看失败原因
                                String message = params.get(CallbackKey.MSG);
                                Log.i(TAG,"Pay error message: " + message);
                                Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
                                callback.Invoke("false");
                            }
                        }
                    });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //显示用户中心
    @Override
    public void ShowUserCenter(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        riverSDKApi.sqSDKPresentUserCenterView(context, new ShowViewCallback() {
            @Override
            public void onViewShow() {
                //界面展示
                Log.i(TAG, "userCenter: " + "onViewShow");
                callback.Invoke("true");
            }
            @Override
            public void onViewDismiss() {
                //界面消失
                Log.i(TAG, "userCenter: " + "onViewDismiss");
                callback.Invoke("false");
            }
        });
    }

    //分享
    @Override
    public void ShareToSocial(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        //注意需要先获取存储权限
        try {
            JSONObject jsonObject  = new JSONObject(strData);
            int socialTypeInt = Integer.valueOf(jsonObject.getString("SocialType"));

            String title = "";
            if (jsonObject.has("Title")) title = jsonObject.getString("Title");
            String url = "";
            if (jsonObject.has("Url")) url = jsonObject.getString("Url");
            String imgPath = "";
            if (jsonObject.has("ImgPath")) imgPath = jsonObject.getString("ImgPath");

            SocialType socialType = SocialType.FACEBOOK_TYPE;
            switch (socialTypeInt)
            {
                case 0:
                    socialType = SocialType.FACEBOOK_TYPE;
                    break;
                case 1:
                    socialType = SocialType.MESSENGER_TYPE;
                    break;
                case 2:
                    socialType = SocialType.LINE_TYPE;
                    break;
                case 3:
                    socialType = SocialType.TWITTER_TYPE;
                    break;
                default:
                    break;
            }

            riverSDKApi.sqSDKShareToSocialAPP(context,
                    socialType, title, url, imgPath,
                    new SDKCallback() {
                        @Override
                        public void onResult(int statusCode, Map<String, String> params) {
                            if (StatusCode.SUCCESS == statusCode) {
                                //分享成功
//                                Toast.makeText(context, "Share success", Toast.LENGTH_SHORT).show();
                                callback.Invoke("true");
                            } else {
                                //分享失败
                                Toast.makeText(context, "Share fail:" + statusCode, Toast.LENGTH_SHORT).show();
                                callback.Invoke("false");
                            }
                            String msg = params.get(CallbackKey.MSG);
                            Log.i(TAG, "sqSDKShareToSocialAPP onResult statusCode=" + statusCode + " msg=" + msg);
                        }
                    });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public  void EnterGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.EnterGame(strData,callback);
        Log.i(TAG,"EnterGame");
        riverSDKApi.sqSDKReportServerCode(context, //上下文对象
                SdkDataManager.getInstance().ServerId, //服务器id
                SdkDataManager.getInstance().RoleId, //角色id
                SdkDataManager.getInstance().RoleName);
    }

    @Override
    public void GameEventReport(String strData) {
        super.GameEventReport(strData);
        try {
            JSONObject jsonObject  = new JSONObject(strData);
            String eventName = jsonObject.getString("EventName");
            String eventKey = jsonObject.getString("EventKey");
            String eventValue = jsonObject.getString("EventValue");

            SDKTrackGameEvent(eventName, eventKey, eventValue);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //生命周期
    @Override
    public void onCreate(Bundle savedInstanceState) {
        //创建SDK对象（填入对应平台  GLOBAL, GM99...）
        riverSDKApi = RiverSDKApi.getInstance(SDKPlatform.GLOBAL);

        super.onCreate(savedInstanceState);

        riverSDKApi.onCreate(context);

        riverSDKApi.sqSDKSetSwitchAccountCallback(new SDKCallback() {
            @Override
            public void onResult(int statusCode, Map<String, String> params) {
                // 收到该回调时，无论成功与否需要重启游戏，执行游戏重登的逻辑

                if (StatusCode.SUCCESS == statusCode) {
                    //切换账号成功，重启游戏！回调的参数信息跟登录成功的参数信息一致
//                    loginSuccess(params);
                    if (switchAccountCallback != null) {
//                        CheckLogin(switchAccountCallback, params);
                        OnInitiativeLogout(true);
                    } else {
                        RestartApp(null);
                    }
                } else {
                    //获取账号信息失败，需要重启游戏
                    String msg = params.get(CallbackKey.MSG);
                    Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();

                    RestartApp(null);
                }
            }
        });
    }

    @Override
    public void onStart() {
        super.onStart();
        riverSDKApi.onStart(context);
    }

    @Override
    public void onResume() {
        super.onResume();
        riverSDKApi.onResume(context);
    }

    @Override
    public void onPause() {
        super.onPause();
        riverSDKApi.onPause(context);
    }

    @Override
    public void onStop() {
        super.onStop();
        riverSDKApi.onStop(context);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        riverSDKApi.onDestroy(context);
    }

    @Override
    public void onRestart() {
        super.onRestart();
        riverSDKApi.onRestart(context);
    }

    @Override
    public void onNewIntent(Intent newIntent) {
        super.onNewIntent(newIntent);
        riverSDKApi.onNewIntent(context, newIntent);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        riverSDKApi.onActivityResult(context, requestCode, resultCode, data);
    }

    //<editor-fold desc="登录流程">
    private void LoginImp() {

        Log.i(TAG,"LoginImp");
        //请确保该接口在主线程运行
        riverSDKApi.sqSDKAutoLogin(context, new SDKCallback() {
            @Override
            public void onResult(int statusCode, Map<String, String> params) {
                Log.i(TAG,"statusCode: " + statusCode);
                if (StatusCode.SUCCESS == statusCode) {
                    CheckLogin(loginCallback, params);
                } else {
                    //登录失败处理
                    String msg = params.get(CallbackKey.MSG); // "msg"
                    String str = "Login fail:"  + statusCode + ",msg:" + msg;
                    Toast.makeText(context, str, Toast.LENGTH_LONG).show();
                    try {
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("IsSuccess", false);
                        loginCallback.Invoke(jsonObject.toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }

    private void CheckLogin(QKUnityBridgeManager.QKUnityCallbackFunc callback, Map<String, String> params) {
        Log.i(TAG,"CheckLogin");

        // 登录成功都返回以下7个值
        UserType userType = UserType.toUserType(params.get(CallbackKey.USERTYPE)); // 登录方式
        String userId = params.get(CallbackKey.USERID); // 用户id
        String sign = params.get(CallbackKey.SIGN); //
        String timeStamp = params.get(CallbackKey.TIMESTAMP); // 时间戳
        String dev = params.get(CallbackKey.DEV); // "android"
        String gameCode = params.get(CallbackKey.GAMECODE); // 游戏简码
        String channelId = params.get(CallbackKey.CHANNELID); // "googlePlay"
        String str = "Login success:" + "\n" +
                "userId:"  + userId + "\n" +
                "sign:" + sign + "\n" +
                "timeStamp:" + timeStamp + "\n" +
                "dev:" + dev + "\n" +
                "gameCode:" + gameCode + "\n" +
                "channelId:" + channelId;
        Log.i(TAG, str);

        m_uid = userId;
        m_token = sign;
        m_loginTimeStamp = timeStamp;

        SdkHttpCommon.CheckLogin(m_uid, m_token, c_pfid, m_loginTimeStamp, new MyHttpURLConnect.HttpHander() {

            @Override
            public void onResult(String result) {
                Log.i(TAG,"CheckLogin onResult: " + result);
                try {
                    JSONObject resultJson = new JSONObject(result);
                    int errorCode = resultJson.getInt("ErrorCode");
                    String message = resultJson.getString("Message");
                    if (errorCode == 1) {
//                        JSONObject dataJson = resultJson.getJSONObject("Data");

                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("IsSuccess", true);
                        jsonObject.put("Token", m_token);
                        jsonObject.put("Uid", m_uid);
                        jsonObject.put("pfid", c_pfid);
                        callback.Invoke(jsonObject.toString());
                    } else {
                        Toast.makeText(context, "login check fail：\nerror:" + errorCode + ", " + message, Toast.LENGTH_LONG).show();
                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("IsSuccess", false);
                        callback.Invoke(jsonObject.toString());
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(context, "login check json parse fail：\nerror:" + e, Toast.LENGTH_LONG).show();
                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("IsSuccess", false);
                    } catch (JSONException ex) {
                        ex.printStackTrace();
                    }
                    callback.Invoke(jsonObject.toString());
                }
            }
        });
    }
    //</editor-fold>

    private void SDKTrackGameEvent(String eventName, String eventKey, String eventValue)
    {
        riverSDKApi.sqSDKTrackGameEvent(eventName, eventKey, eventValue);
    }
}
