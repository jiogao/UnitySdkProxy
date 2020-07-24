package qksdkproxy.Utility;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.support.v4.content.ContextCompat;

public class PermissionCheck {
    /**
     * 检测具体某个权限
     * @param context
     * @param strPermission
     */
    public static boolean check(Context context,String strPermission)
    {
        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.M) {
            return (ContextCompat.checkSelfPermission(context, strPermission) == PackageManager.PERMISSION_GRANTED);
        }
        else
        {
            return true;
        }
    }
}
