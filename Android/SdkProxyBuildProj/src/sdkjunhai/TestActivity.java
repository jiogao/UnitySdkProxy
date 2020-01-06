package qksdkproxy.SdkProxy_channel.junhai;

import android.app.Activity;
import android.os.Bundle;
import com.igexin.sdk.PushManager;

public class TestActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PushManager.getInstance().initialize(TestActivity.this, QKService.class);
        PushManager.getInstance().registerPushIntentService(TestActivity.this, IntentService.class);
    }
}
