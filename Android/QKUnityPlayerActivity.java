package com.okw.sjcq;

import qksdkproxy.SdkProxy_channel.okw.QKSdkProxy_okwan;
import android.os.Bundle;
import android.view.KeyEvent;

import qksdkproxy.QKSdkProxyFactory;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;

public class QKUnityPlayerActivity extends UnityPlayerActivity {
    static QKUnityPlayerActivity context = null;

    @Override protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        context = this;

        QKSdkProxyFactory.setSdkProxyType(QKSdkProxy_okwan.class, this);
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
