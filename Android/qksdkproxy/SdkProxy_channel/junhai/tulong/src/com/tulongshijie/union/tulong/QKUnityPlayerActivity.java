package com.tulongshijie.union.tulong;
import android.content.Intent;
import android.util.Log;
import com.igexin.sdk.PushManager;
import prj.chameleon.channelapi.ChannelInterface;
import qksdkproxy.SdkProxy_channel.junhai.QKSdkProxy_junhai;
import qksdkproxy.SdkProxy_channel.junhai.QKService;
import android.os.Bundle;
import android.view.KeyEvent;

import qksdkproxy.QKSdkProxyFactory;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.Utility.SdkDataManager;

public class QKUnityPlayerActivity extends UnityPlayerActivity {
    static QKUnityPlayerActivity context = null;

    @Override protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        context = this;

        Log.e("unitylog","onCreate()....");
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onCreate(QKUnityPlayerActivity.this);
            }
        });

        PushManager.getInstance().initialize(QKUnityPlayerActivity.this, QKService.class);
        PushManager.getInstance().registerPushIntentService(QKUnityPlayerActivity.this, qksdkproxy.SdkProxy_channel.junhai.IntentService.class);
        QKSdkProxyFactory.setSdkProxyType(QKSdkProxy_junhai.class, this);
    }


    protected void onResume() {
        super.onResume();
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onResume(QKUnityPlayerActivity.this);
            }
        });
    }

    protected void onPause() {
        super.onPause();
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onPause(QKUnityPlayerActivity.this);
            }
        });
    }

    protected void onStop() {
        super.onStop();
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onStop(QKUnityPlayerActivity.this);
            }
        });
    }

    protected void onRestart() {
        super.onRestart();
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onRestart(QKUnityPlayerActivity.this);
            }
        });
    }

    protected void onDestroy() {
        super.onDestroy();
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onDestroy(QKUnityPlayerActivity.this);
            }
        });
    }

    protected void onStart() {
        super.onStart();
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onStart(QKUnityPlayerActivity.this);
            }
        });
    }


    protected void onNewIntent(final Intent arg0) {
        super.onNewIntent(arg0);
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onNewIntent(QKUnityPlayerActivity.this, arg0);
            }
        });
    }

    protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        this.runOnUiThread(new Runnable() {
            public void run() {
                ChannelInterface.onActivityResult(QKUnityPlayerActivity.this, requestCode, resultCode, data);
            }
        });
    }

    public void onWindowFocusChanged(final boolean arg0) {
        super.onWindowFocusChanged(arg0);
        this.runOnUiThread(new Runnable() {
            public void run() {

                ChannelInterface.onWindowFocusChanged(QKUnityPlayerActivity.this, arg0);
            }
        });
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event)
    {
        QKSdkProxyFactory.getSdkProxy().onKeyUp(keyCode, event);
        return super.onKeyUp(keyCode, event);
    }

    public void FloatWindow()
    {
    }

    //SdkProxy
    public void QKNative_Call(String funcName, String strData)
    {
        Log.e("unitylog","QKNative_Call()....funcName=" + funcName);
        this.runOnUiThread(new Runnable() {
            public void run() {
                QKUnityBridgeManager.getInstance().OnCall(funcName, strData);
            }
        });
    }

    public static QKUnityPlayerActivity getInstance() {
        return context;
    }
}
