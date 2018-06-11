package qksdkproxy.Utility;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.*;

public class SdkDataManager {
    //静态内部类
    private static class LazyHolder {
        private static final SdkDataManager INSTANCE = new SdkDataManager();
    }
    public static final SdkDataManager getInstance() {
        return LazyHolder.INSTANCE;
    }

    private Map data = new HashMap();

    public String SdkUserId;

    public String ServerId;
    public String ServerName;

    public String RoleId;
    public String RoleName;
    public String RoleLevel;
    public String RoleCreateTime;
    public String UpdateRoleTime;
    public String RoleVipLevel;
    public String RoleGold;


    //保存服务器信息
    public void SaveServerInfo(String strData) {
        try {
            JSONObject jsonObject  = new JSONObject(strData);
            ServerId = jsonObject.getString("ServerId");
            ServerName = jsonObject.getString("ServerName");
            data.put("ServerId",ServerId);
            data.put("ServerName",ServerName);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    //保存角色器信息
    public void SaveRoleInfo(String strData) {
        try {
            JSONObject jsonObject  = new JSONObject(strData);
            RoleId = jsonObject.getString("RoleId");
            RoleName = jsonObject.getString("RoleName");
            RoleLevel = jsonObject.getString("RoleLevel");
            RoleCreateTime = jsonObject.getString("RoleCreateTime");
            UpdateRoleTime = jsonObject.getString("RoleUpdateTime");
            RoleVipLevel = jsonObject.getString("RoleVipLevel");
            RoleGold = jsonObject.getString("RoleGold");


            data.put("RoleId",RoleId);
            data.put("RoleName",RoleName);
            data.put("RoleLevel",RoleLevel);
            data.put("RoleCreateTime",RoleCreateTime);
            data.put("RoleUpdateTime",UpdateRoleTime);
            data.put("RoleVipLevel",RoleVipLevel);
            data.put("RoleGold",RoleGold);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /*
        sdk用户信息
     */
    public void SaveSKDUserInfo(String strData)
    {
        try {
            JSONObject jsonObject  = new JSONObject(strData);
            SdkUserId = jsonObject.getString("uid");
            data.put("SdkUserId",SdkUserId);
        } catch (JSONException e)
        {
            e.printStackTrace();
        }
    }

    public void clearData()
    {
        Iterator it = data.entrySet().iterator();
        while (it.hasNext())
        {
            Map.Entry e = (Map.Entry)it.next();
            e.setValue("");
        }
        data.clear();
    }
}
