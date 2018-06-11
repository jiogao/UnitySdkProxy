package qksdkproxy.Utility;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.provider.Settings;
import android.util.Log;
import com.okw.sjcq.QKUnityPlayerActivity;

public class QKSdkProxyUtility {
    static final String TAG = "qksdkproxy";
    /**
     * 获取本地软件版本号
     */
    public static int getVersionCode() {
        int versionCode = 0;
        try {
            Context ctx = QKUnityPlayerActivity.getInstance().getApplicationContext();
            PackageInfo packageInfo = ctx.getPackageManager().getPackageInfo(ctx.getPackageName(), 0);
            versionCode = packageInfo.versionCode;
            Log.d(TAG, "versionCode: " + versionCode);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return versionCode;
    }

    /**
     * 获取本地软件版本号名称
     */
    public static String getVersionName() {
        String versionName = "";
        try {
            Context ctx = QKUnityPlayerActivity.getInstance().getApplicationContext();
            PackageInfo packageInfo = ctx.getApplicationContext()
                    .getPackageManager()
                    .getPackageInfo(ctx.getPackageName(), 0);
            versionName = packageInfo.versionName;
            Log.d("TAG", "versionName: " + versionName);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return versionName;
    }

    public static String getDeviceId() {
        Context ctx = QKUnityPlayerActivity.getInstance().getApplicationContext();
        String deviceId = Settings.Secure.getString(ctx.getContentResolver(), Settings.Secure.ANDROID_ID);
        return deviceId;
    }

}
