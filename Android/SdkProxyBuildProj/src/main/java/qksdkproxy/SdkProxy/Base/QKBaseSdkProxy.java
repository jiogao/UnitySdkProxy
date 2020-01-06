package qksdkproxy.SdkProxy.Base;

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
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

public class QKBaseSdkProxy
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

    private InitState initState = InitState.NoInit;
    private int initNums = 0;
    public QKUnityBridgeManager.QKUnityCallbackFunc initcallback;

    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        initNums = 0;
        Log.i("QKBaseSdkProxy","SdkInit");
        initcallback = callback;
        OnInitOver();
    }

    protected void SdkInitImp(InitImpCallback callback) {
        callback.Invoke(true);
    }

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
                        Toast.makeText(context,"初始化失败,重试中...",Toast.LENGTH_SHORT).show();
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
        if (initState != InitState.NoInit && initcallback != null){
            String ret = (initState == InitState.Success ? "true" : "false");
            initcallback.Invoke(ret);
        }
    }
    //</editor-fold>

    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        //callback.Invoke("false");
    }
    public  void GetDeviceInfo(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
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
    public  void GetDeviceStatus(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        PowerConnectionReceiver.powercallback = callback;
    }
    public  void GetNetWorkChanged(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        NetworkChangeReceiver.networkchangecallback = callback;
    }
    public void ShowFloat(String strData) {}
    public void HideFloat(String strData) {}
    public void SelectServer(String strData) {
        SdkDataManager.getInstance().SaveServerInfo(strData);
    }
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData);
    }
    public void SelectRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData);
    }

    public void EnterGame(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData);
    }
    public void UpdateUserGoods(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    public void OpenUrl(String strData) {

    }
    public void OpenUrlWithWebView(String strData,boolean isLandScape) {
        QKWebActivity.showWeb(context, strData, isLandScape);
    }

    public void SdkExtraAction(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
    }

    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if(event.getKeyCode() == KeyEvent.KEYCODE_BACK)
        {
//            QKUnityBridgeManager.getInstance().OnCall("ExitGame","");
            QKUnityBridgeManager.getInstance().CallUnity("BackPressedEvent", "");
        }
        return true;
    }

    public String getGameName(){return "";}


    protected void RestartApp(String data) {
        Intent mStartActivity = new Intent(context, context.getClass());
        int mPendingIntentId = 123456;
        PendingIntent mPendingIntent = PendingIntent.getActivity(context,
                mPendingIntentId, mStartActivity,
                PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager mgr = (AlarmManager) context
                .getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 100,
                mPendingIntent);
        System.exit(0);
    }

    public void onCreate(Bundle savedInstanceState) {
        StartSdkInit();
    }
}
