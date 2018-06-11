package qksdkproxy.SdkProxy_channel;

import org.json.JSONException;
import org.json.JSONObject;

import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;

public class QKSdkProxy_test extends QKBaseSdkProxy {
    @Override
    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        callback.Invoke("true");
    }
    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("scode", "test_scode");
            jsonObject.put("uid", "test_uid");
            callback.Invoke(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
