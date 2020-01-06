package sdkproxy_imp;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import qksdkproxy.NetworkChangeReceiver;
import qksdkproxy.PowerConnectionReceiver;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;
import qksdkproxy.Utility.QKSdkProxyUtility;

public class QKSdkProxy_imp extends QKBaseSdkProxy {

    public QKUnityBridgeManager.QKUnityCallbackFunc logincallback;

    //初始化代码
    @Override
    protected void SdkInitImp(InitImpCallback callback) {
        callback.Invoke(true);
    }

    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Login(strData, callback);
        Log.i("QKSdkProxy_imp","StartLogin");
        logincallback = callback;
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("scode", "test_scode");
            jsonObject.put("uid", "test_uid");
            logincallback.Invoke(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void SelectRole(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.SelectRole(strData, callback);
        Log.i("QKSdkProxy_imp","SelectRole");
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc exitcallback;
    @Override
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.ExitGame(strData, callback);
        Log.i("QKSdkProxy_imp","ExitGame");
        exitcallback = callback;
    }

    @Override
    public void SelectServer(String strData) {
        super.SelectServer(strData);
        Log.i("QKSdkProxy_imp","SelectServer");
    }

    @Override
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.CreateRole(strData,callback);
        Log.i("QKSdkProxy_imp","CreateRole");
    }

    @Override
    public  void EnterGame(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
        super.EnterGame(strData,callback);
        Log.i("QKSdkProxy_imp","EnterGame");
    }

    @Override
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LevelUp(strData,callback);
        Log.i("QKSdkProxy_imp","LevelUp");
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc logoutcallback;
    @Override
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Logout(strData, callback);
        Log.i("QKSdkProxy_imp","Logout");
        logoutcallback = callback;
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc payCallback;
    @Override
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Pay(strData, callback);
        payCallback = callback;
        Log.i("QKSdkProxy_imp","Pay");
    }
}
