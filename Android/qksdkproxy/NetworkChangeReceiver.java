package qksdkproxy;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;

public class NetworkChangeReceiver extends BroadcastReceiver
{
    public enum NetWorkSate{
        NotConnected("0"),
        ViaCarrieerDataNet("1"),
        ViaLocalAreaNet("2");
        private final String id;
        private NetWorkSate(String id){
            this.id = id;
        }
        private String getId(){
            return id;
        }
    }
    private NetWorkSate netType = NetWorkSate.NotConnected;
    public static QKUnityBridgeManager.QKUnityCallbackFunc networkchangecallback;

    public void onReceive(Context context, Intent intent) {
        ConnectivityManager manager = (ConnectivityManager) context
                .getSystemService("connectivity");

        NetworkInfo activeInfo = manager.getActiveNetworkInfo();
        if (activeInfo != null && activeInfo.isAvailable()) {
            if ((activeInfo.isConnected()) && (activeInfo.getType() == ConnectivityManager.TYPE_MOBILE)) {
                netType =  NetWorkSate.ViaCarrieerDataNet;
                System.out.println("手机网络连接");
            } else if ((activeInfo.isConnected()) && (activeInfo.getType() == ConnectivityManager.TYPE_WIFI)) {
                netType = NetWorkSate.ViaLocalAreaNet;
                System.out.println("wifi连接");
            } else {
                netType = NetWorkSate.NotConnected;
                System.out.println("网络连接断了");
            }
        } else {
            System.out.println("网络未连接。。。。。");
            netType = NetWorkSate.NotConnected;
        }

        if (networkchangecallback != null) {
            networkchangecallback.Invoke(netType.id);
        }
    }
}