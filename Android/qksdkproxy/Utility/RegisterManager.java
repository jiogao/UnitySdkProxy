package qksdkproxy.Utility;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;

import java.util.HashMap;
import java.util.Map;
import qksdkproxy.NetworkChangeReceiver;
import qksdkproxy.PowerConnectionReceiver;

/**
 * 监听管理
 * 需要监听的对象在map里补上
 *
 */
public class RegisterManager {

    private static final RegisterManager _instance = new RegisterManager();

    private static final Map<BroadcastReceiver,IntentFilter> map = new HashMap<BroadcastReceiver, IntentFilter>()
    {
        {
            IntentFilter filter = new IntentFilter();
            filter.addAction(Intent.ACTION_BATTERY_CHANGED);
            filter.addAction(Intent.ACTION_BATTERY_LOW);
            filter.addAction(Intent.ACTION_BATTERY_OKAY);
            put(new PowerConnectionReceiver(), filter);

            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
            intentFilter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
            intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
            put(new NetworkChangeReceiver(),intentFilter);
        }
    };

    public static RegisterManager getInstance(){
        return _instance;
    }

    /**
     * 注册监听
     * @param context
     */
    public void registerReceiverFunc(Context context){
        for(Map.Entry<BroadcastReceiver,IntentFilter> entry : map.entrySet()){
            BroadcastReceiver receiver1 = entry.getKey();
            IntentFilter filter1 = entry.getValue();
            context.registerReceiver(receiver1,filter1);
        }
    }

    /**
     * 取消监听
     *
     * @param context
     */
    public void destroyReceiverFunc(Context context){
        for(Map.Entry<BroadcastReceiver,IntentFilter> entry : map.entrySet()){
            context.unregisterReceiver(entry.getKey());
        }
    }

}
