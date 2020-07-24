package qksdkproxy;

import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;

import android.app.Activity;
import android.content.Context;

public class QKSdkProxyFactory {

    static Class<? extends QKBaseSdkProxy> sdkProxyCls;
    static QKBaseSdkProxy sdkProxy = null;

    public static void setSdkProxyType(Class<? extends QKBaseSdkProxy> cls, Activity context) {
        sdkProxyCls = cls;
        if(sdkProxy == null) {
            try {
                sdkProxy = (QKBaseSdkProxy)sdkProxyCls.newInstance();
                sdkProxy.context = context;
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
            QKUnityBridgeManager.getInstance().setSdkProxyObj(sdkProxy);
        }
    }

    public static QKBaseSdkProxy getSdkProxy() {
        return sdkProxy;
    }
}
