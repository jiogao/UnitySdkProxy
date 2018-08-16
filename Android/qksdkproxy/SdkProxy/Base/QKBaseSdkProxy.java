package qksdkproxy.SdkProxy.Base;

import android.content.Context;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.Utility.QKSdkProxyUtility;
import qksdkproxy.Utility.QKWebActivity;
import qksdkproxy.Utility.SdkDataManager;
import android.view.KeyEvent;
import org.json.JSONException;
import org.json.JSONObject;



public class QKBaseSdkProxy
{
    static final String TAG = "qksdkproxy";
    public Context context;

    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
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
            jsonObject.put("DeviceId", QKSdkProxyUtility.getDeviceId());
            callback.Invoke(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    public  void GetDeviceStatus(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {

    }
    public  void GetNetWorkChanged(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {

    }
    public void ShowFloat(String strData) {}
    public void HideFloat(String strData) {}
    public void SelectServer(String strData) {
        SdkDataManager.getInstance().SaveServerInfo(strData);
    }
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData,true);
    }
    public void SelectRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData,true);
    }

    public void EnterGame(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {}
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        SdkDataManager.getInstance().SaveRoleInfo(strData,false);
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



}
