package sdkproxy_imp;

import android.content.Context;
import android.support.multidex.MultiDex;
import android.util.Log;

import com.games37.riversdk.core.RiverSDKApplication;

public class ProxyApplication extends RiverSDKApplication {

    @Override
    protected void attachBaseContext(Context base) {
//        Log.i("ProxyApplication","attachBaseContext");
        MultiDex.install(base);
        super.attachBaseContext(base);
    }
}
