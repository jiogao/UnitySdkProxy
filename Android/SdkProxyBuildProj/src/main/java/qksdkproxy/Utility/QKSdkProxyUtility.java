package qksdkproxy.Utility;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.unity3d.player.UnityPlayer;

import org.json.JSONException;
import org.json.JSONObject;

import qksdkproxy.SdkProxy.SdkSupport.QKUnityPlayerActivity;

import static android.content.Context.TELEPHONY_SERVICE;

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

    public static String getIMEI() {
        Log.e("qiku", "getIMEI.....");
        String imei = "no permission";
        Context context = QKUnityPlayerActivity.getInstance();
        TelephonyManager tm = (TelephonyManager) context.getSystemService(TELEPHONY_SERVICE);
        if (null != tm) {
            Log.e("qiku", "getIMEI-1.....");
            Context ctx = QKUnityPlayerActivity.getInstance().getApplicationContext();
            if (ActivityCompat.checkSelfPermission(ctx, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                imei = tm.getDeviceId();
            }
        }
        return imei;
    }
}
