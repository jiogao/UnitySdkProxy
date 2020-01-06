package qksdkproxy.SdkProxy.SdkSupport;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;

import com.unity3d.player.UnityPlayerActivity;

import qksdkproxy.QKSdkProxyFactory;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import sdkproxy_imp.QKSdkProxy_imp;

public class QKUnityPlayerActivity extends UnityPlayerActivity {
    static QKUnityPlayerActivity context = null;

    @Override protected void onCreate(Bundle savedInstanceState)
    {
        Log.i("QKUnityPlayerActivity","onCreate");
        super.onCreate(savedInstanceState);
        context = this;

        QKSdkProxyFactory.setSdkProxyType(QKSdkProxy_imp.class, this);
        QKSdkProxyFactory.getSdkProxy().onCreate(savedInstanceState);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        QKSdkProxyFactory.getSdkProxy().onKeyUp(keyCode, event);
        return super.onKeyUp(keyCode, event);
    }

    public void FloatWindow()
    {
    }

    //SdkProxy
    public void QKNative_Call(String funcName, String strData)
    {
        QKUnityBridgeManager.getInstance().OnCall(funcName, strData);
    }

    public static QKUnityPlayerActivity getInstance() {
        return context;
    }
}
