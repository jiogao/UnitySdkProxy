package qksdkproxy.SdkProxy.Base;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;

import qksdkproxy.NetworkChangeReceiver;
import qksdkproxy.PowerConnectionReceiver;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.Utility.QKSdkProxyUtility;
import qksdkproxy.Utility.QKWebActivity;
import qksdkproxy.Utility.SdkDataManager;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;

import org.json.JSONException;
import org.json.JSONObject;

public abstract class QKBaseSdkProxy
{
    private enum InitState
    {
        NoInit,
        Success,
        Fail,
    }
    protected interface InitImpCallback {
        void Invoke(boolean isInitSuccess);
    }

    static final String TAG = "qksdkproxy";
    public Activity context;

    //渠道id
    protected abstract String Pfid();

    private InitState initState = InitState.NoInit;
    private int initNums = 0;
    private QKUnityBridgeManager.QKUnityCallbackFunc initCallback;                  //初始化回调

    protected QKUnityBridgeManager.QKUnityCallbackFunc logoutInitiativeCallback;      //主动登出回调
    protected QKUnityBridgeManager.QKUnityCallbackFunc switchAccountCallback;      //主动登出回调
    protected QKUnityBridgeManager.QKUnityCallbackFunc backPressCallback;            //返回键回调

    //注册sdk主动登出事件
    public void RegisterLogout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        logoutInitiativeCallback = callback;
    }

    //注册sdk主动切换账号事件
    public void RegisterSwitchAccount(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        switchAccountCallback = callback;
    }

    //注册返回键事件
    public void RegisterBackPress(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        backPressCallback = callback;
    }

    //初始化
    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        initNums = 0;
        Log.i("QKBaseSdkProxy","SdkInit");
        initCallback = callback;
        OnInitOver();
    }

    protected void SdkInitImp(InitImpCallback callback) {
        callback.Invoke(true);
    }

    //登录

    /**
     *
     登录成功:
     try {
     JSONObject jsonObject = new JSONObject();
     jsonObject.put("IsSuccess", true);
     jsonObject.put("Token", token);
     jsonObject.put("Uid", uid);
     } catch (JSONException ex) {
     ex.printStackTrace();
     }
     loginCallback.Invoke(jsonObject.toString());

     登录失败:
     try {
     JSONObject jsonObject = new JSONObject();
     jsonObject.put("IsSuccess", false);
     loginCallback.Invoke(jsonObject.toString());
     } catch (JSONException e) {
     e.printStackTrace();
     }

     * @param strData
     * @param callback
     */
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //登出
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //支付
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //显示用户中心
    public void ShowUserCenter(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //分享
    public void ShareToSocial(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //退出游戏
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        callback.Invoke("false");
    }
    //重启游戏
    public void RestartApp(String strData) {
        Intent mStartActivity = new Intent(context, context.getClass());
        int mPendingIntentId = 0;
        PendingIntent mPendingIntent = PendingIntent.getActivity(context,
                mPendingIntentId, mStartActivity,
                PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager mgr = (AlarmManager) context
                .getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 100,
                mPendingIntent);
        System.exit(0);
    }

    //获取设备信息
    public void GetDeviceInfo(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("BundleVersion", String.valueOf(QKSdkProxyUtility.getVersionCode()));
            jsonObject.put("Version", QKSdkProxyUtility.getVersionName());
            jsonObject.put("DeviceId", "");
            callback.Invoke(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    //获取设备状态
    public  void GetDeviceStatus(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        PowerConnectionReceiver.powercallback = callback;
    }
    //获取网络状态
    public  void GetNetWorkChanged(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        NetworkChangeReceiver.networkchangecallback = callback;
    }
    //显示悬浮窗
    public void ShowFloat(String strData) {}
    //隐藏悬浮窗
    public void HideFloat(String strData) {}
    //选服
    public void SelectServer(String strData) {
        SdkDataManager.getInstance().SaveServerInfo(strData);
    }
    //创角
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData);
    }
    //登录
    public void SelectRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData);
    }
    //进入游戏
    public void EnterGame(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //升级
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData);
    }
    //物品更新
    public void UpdateUserGoods(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    //游戏事件上报
    public void GameEventReport(String strData) {}

    public void OpenUrl(String strData) {}
    public void OpenUrlWithWebView(String strData,boolean isLandScape) {
        QKWebActivity.showWeb(context, strData, isLandScape);
    }
    //预留接口
    public void SdkExtraAction(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {}

    //sdk主动退出事件中调用
    protected void OnInitiativeLogout(boolean isSuccess) {
        if (logoutInitiativeCallback != null) {
            logoutInitiativeCallback.Invoke(isSuccess ? "true" : "false");
        }
    }

    //返回键事件中调用
    protected void OnBackPress() {
        if (backPressCallback != null) {
            backPressCallback.Invoke("true");
        }
    }

    //<editor-fold desc="生命周期">

    /**
     * //super中会调用初始化, 初始化之前需要调用的代码放在super之前
     * @Override
     *     public void onCreate(Bundle savedInstanceState) {
     *         //your code
     *
     *         //基类onCreate方法中会调用sdk初始化, 初始化之前需要调用的代码放在super之前
     *         super.onCreate(savedInstanceState);
     *     }
     * @param savedInstanceState
     */
    public void onCreate(Bundle savedInstanceState) {
        StartSdkInit();
    }
    public void onStart() {}
    public void onRestart() {}
    public void onResume() {}
    public void onPause() {}
    public void onStop() {}
    public void onDestroy() {}
    public void onNewIntent(Intent newIntent) {}
    public void onActivityResult(int requestCode, int resultCode, Intent data) {}
    public void onConfigurationChanged(Configuration newConfig) {}
    @TargetApi(Build.VERSION_CODES.M)
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {}

    //返回键
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if(event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            OnBackPress();
        }
        return true;
    }
    //</editor-fold>

    //<editor-fold desc="内部初始化流程">
    private void StartSdkInit() {
        initNums = 0;
        initState = InitState.NoInit;
        DoSdkInit();
    }

    private void DoSdkInit()
    {
        ++initNums;
        SdkInitImp(new InitImpCallback() {
            @Override
            public void Invoke(boolean isInitSuccess) {
                if (isInitSuccess) {
                    OnInitSuccess();
                } else {
                    Log.e("QKBaseSdkProxy", "init fail");
                    if(initNums > 3) {
//                        Toast.makeText(context,"初始化失败,重试中...",Toast.LENGTH_SHORT).show();
//                        OnInitFail();

                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                StartSdkInit();
                            }
                        }, 5000);
                    } else {
                        DoSdkInit();
                    }
                }
            }
        });
    }

    private void OnInitSuccess() {
        initState = InitState.Success;
        OnInitOver();
    }

    private void OnInitFail() {
        initState = InitState.Fail;
        OnInitOver();
    }

    private void OnInitOver()
    {
        if (initState != InitState.NoInit && initCallback != null){
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("IsSuccess", true);
                jsonObject.put("IsSuccess", (initState == InitState.Success));
                jsonObject.put("PfId", Pfid());
                initCallback.Invoke(jsonObject.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }
    //</editor-fold>
}
