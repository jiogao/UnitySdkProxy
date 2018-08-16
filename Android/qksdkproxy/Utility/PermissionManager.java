package qksdkproxy.Utility;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import static android.support.v4.app.ActivityCompat.requestPermissions;

public class PermissionManager {

    private final static PermissionManager _instance = new PermissionManager();
    public static PermissionManager getInstance(){
        return _instance;
    }

    /**
     * 敏感权限列表
     */
    private List<String> dangerpermissionList = Arrays.asList(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.BATTERY_STATS,
            Manifest.permission.READ_PHONE_STATE
//            Manifest.permission.CHANGE_WIFI_STATE
//            Manifest.permission.CHANGE_NETWORK_STATE
//            Manifest.permission.ACCESS_NETWORK_STATE
//            Manifest.permission.ACCESS_WIFI_STATE
    );

    private List<String> list = new ArrayList<>();
    public void RequestPermission(Context context)
    {
        list.clear();
        for(String strPermission:dangerpermissionList){
            boolean b = (PermissionCheck.check(context,strPermission));
            if(!b){
                list.add(strPermission);
            }
        }

        if(list.size() > 0){
            String[] strings = new String[list.size()];
            String[] str = list.toArray(strings);
            if(null != str){
                requestPermissions((Activity)context, str, 1);
            }
        }
    }
}
