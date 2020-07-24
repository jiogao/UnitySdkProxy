package qksdkproxy.SdkProxy.SdkSupport;

import android.annotation.TargetApi;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
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
    }@Override
    protected void onStart() {
        super.onStart();
        QKSdkProxyFactory.getSdkProxy().onStart();
    }

    @Override
    public void onRestart() {
        super.onRestart();
        QKSdkProxyFactory.getSdkProxy().onRestart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        QKSdkProxyFactory.getSdkProxy().onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        QKSdkProxyFactory.getSdkProxy().onPause();
    }

    @Override
    protected void onStop() {
        super.onStop();
        QKSdkProxyFactory.getSdkProxy().onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        QKSdkProxyFactory.getSdkProxy().onDestroy();
    }

    @Override
    public void onNewIntent(Intent newIntent) {
        super.onNewIntent(newIntent);
        QKSdkProxyFactory.getSdkProxy().onNewIntent(newIntent);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        QKSdkProxyFactory.getSdkProxy().onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        QKSdkProxyFactory.getSdkProxy().onConfigurationChanged(newConfig);
    }

    @Override
    @TargetApi(Build.VERSION_CODES.M)
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        QKSdkProxyFactory.getSdkProxy().onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        QKSdkProxyFactory.getSdkProxy().onKeyUp(keyCode, event);
        return super.onKeyUp(keyCode, event);
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
