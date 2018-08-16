package qksdkproxy.QKUnityBridge;

import android.util.Log;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import com.tulongshijie.union.tulong.QKUnityPlayerActivity;
import com.unity3d.player.UnityPlayer;

import org.json.JSONException;
import org.json.JSONObject;

public class QKUnityBridgeManager {
    static final String TAG = "qksdkproxy";

    String BRIDGE_OBJ_NAME = "QKNativeBridgeManager";
    public interface QKUnityCallbackFunc {
        void Invoke(String strData);
    }

    private Object sdkProxyObj;
    public void setSdkProxyObj(Object obj) {
        sdkProxyObj = obj;
    }

    private QKUnityBridgeManager() {}
    //    private static QKUnityBridgeManager instance = null;
    //    //静态工厂方法
    //    public static QKUnityBridgeManager getInstance() {
    //        if (instance == null) {
    //            instance = new QKUnityBridgeManager();
    //        }
    //        return instance;
    //    }
    //静态内部类
    private static class LazyHolder {
        private static final QKUnityBridgeManager INSTANCE = new QKUnityBridgeManager();
    }
    public static final QKUnityBridgeManager getInstance() {
        return LazyHolder.INSTANCE;
    }

    //调用unity函数
    public void CallUnity(String funcName,String strData) {
        QKUnityPlayerActivity.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CallUnityFunc(funcName,strData);
            }
        });
    }


    public void CallUnityFunc(String funcName, String strData){

        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("funcName", funcName);
            jsonObject.put("strData", strData);
            UnityPlayer.UnitySendMessage(BRIDGE_OBJ_NAME, "OnNativeCall",  jsonObject.toString());

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    //接收unity调用
    public void OnCall(final String funcName, String strData) {
        if (this.sdkProxyObj != null && funcName != null && funcName.length() > 0) {
            Class cls = this.sdkProxyObj.getClass();
            try {
                Method method = null;
                try {
                    method = cls.getMethod(funcName, String.class, QKUnityCallbackFunc.class);
                    method.invoke(this.sdkProxyObj, strData, new QKUnityCallbackFunc() {
                        public void Invoke(String strData) {
                            CallUnity(funcName, strData);
                        }
                    });
                } catch (NoSuchMethodException e) {
                    Log.d(TAG, "try find funcName no callback");
                    method = cls.getMethod(funcName, String.class);
                    method.invoke(this.sdkProxyObj, strData);
                }
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
    }
}
