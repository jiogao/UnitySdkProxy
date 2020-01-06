package SdkProxy_channel.okw;

import android.Manifest;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.view.KeyEvent;

import qksdkproxy.NetworkChangeReceiver;
import qksdkproxy.PowerConnectionReceiver;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;
import qksdkproxy.Utility.PermissionCheck;
import qksdkproxy.Utility.QKSdkProxyUtility;
import qksdkproxy.Utility.SdkDataManager;
import android.util.Log;
import android.widget.Toast;

import com.nbsdk.helper.NBPayInfo;
import com.nbsdk.helper.NBResult;
import com.nbsdk.helper.NBServerRoleSubmitTypes;
import com.nbsdk.main.NBSDK;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.*;

public class QKSdkProxy_okwan extends QKBaseSdkProxy
{
    public QKUnityBridgeManager.QKUnityCallbackFunc logincallback;
    public QKUnityBridgeManager.QKUnityCallbackFunc initcallback;
    private boolean isinit = false;
    private int initNums = 0;
    @Override
    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.SdkInit(strData, callback);
        initNums = 0;
        Log.e("qiku","SdkInit().....");
        initcallback = callback;
        SdkInitImp();
    }


    private void SdkInitImp()
    {
        initNums++;
        NBSDK.getInstance().init(context, new NBResult() {
            @Override
            public void onResult(int nbResultCode, Map<String, String> result) {
                switch (nbResultCode) {
                    case NBResult.INIT_SUCCESS:
                        Log.e("qiku", "INIT_SUCCESS");
                        isinit = true;
                        initcallback.Invoke("YES");
                        break;
                    case NBResult.INIT_FAILED:
                        Log.e("qiku", "INIT_FAILED");
                        isinit = false;
                        if(initNums > 3)
                        {
                            Toast.makeText(context,"多次初始化失败！！！",Toast.LENGTH_SHORT).show();
                            initcallback.Invoke("false");
                        }
                        else
                        {
                            SdkInitImp();
                        }
                        break;
                    case NBResult.LOGIN_SUCCESS:
                        Log.e("qiku", "Login_success");
                        loginSucess(result);
                        break;
                    case NBResult.LOGIN_FAILED:
                        Log.e("qiku", "Login_failed");
                        break;
                    case NBResult.PAY_SUCCESS:
                        payCallback.Invoke("YES");
                        break;
                    case NBResult.PAY_FAILED:
                        payCallback.Invoke("false");
                        break;
                    case NBResult.LOGOUT_SUCCESS:
                        Log.e("qiku", "LOGOUT_SUCCESS");
                        logoutcallback.Invoke("YES");
                        break;
                    case NBResult.LOGOUT_FAILED:
                        Log.e("qiku", "LOGOUT_FAILED");
                        logoutcallback.Invoke("false");
                        break;
                    case NBResult.EXIT_SUCCESS:
                        Log.e("qiku", "EXIT_SUCCESS");
                        exitcallback.Invoke("YES");
                        System.exit(0);
                        break;
                }
            }
        });
    }


    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Login(strData, callback);
        Log.e("qiku","StartLogin.....");
        if(isinit)
        {
            Log.e("qiku","StartLogin21222222.....");
            NBSDK.getInstance().login();
        }
        logincallback = callback;
    }

    private void loginSucess(Map<String, String> result){
        String uid = result.get("pfUid");
        String token = result.get("pfToken");
        JSONObject jObject=new JSONObject();
        try {
            jObject.put("IsSuccess",true);
            jObject.put("Uid", uid);
            jObject.put("Token",token);
            jObject.put("game_id","");
            jObject.put("channel_id","");
            jObject.put("game_channel_id","");
            logincallback.Invoke(jObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void SelectRole(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.SelectRole(strData, callback);
        Log.e("unitylog","SelectRole().....");
        Map<String, String> info = new HashMap<String, String>();
        info.put("roleId", SdkDataManager.getInstance().RoleId); //角色ID
        info.put("roleName", SdkDataManager.getInstance().RoleName); //角色名称
        info.put("roleLevel", SdkDataManager.getInstance().RoleLevel); //角色等级
        info.put("roleCreateTime",SdkDataManager.getInstance().RoleCreateTime); //角色创建时时间戳
        info.put("cpUid", SdkDataManager.getInstance().CpUid); //游戏CP方帐号ID，无此参数时使用角色ID
        NBSDK.getInstance().submitServerAndRole(NBServerRoleSubmitTypes.SELECT_ROLE, info);
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc exitcallback;
    @Override
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.ExitGame(strData, callback);
        Log.e("unitylog","QKSdkProxy_okwan.ExitGame().....");
        exitcallback = callback;
    }

    @Override
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.CreateRole(strData,callback);
        Log.e("unitylog","QKSdkProxy_okwan.CreateRole().....");
        Map<String, String> info = new HashMap<String, String>();
        info.put("roleId", SdkDataManager.getInstance().RoleId); //角色ID
        info.put("roleName", SdkDataManager.getInstance().RoleName); //角色名称
        info.put("roleLevel", SdkDataManager.getInstance().RoleLevel); //角色等级
        info.put("roleCreateTime",SdkDataManager.getInstance().RoleCreateTime); //角色创建时时间戳
        info.put("cpUid", SdkDataManager.getInstance().CpUid); //游戏CP方帐号ID，无此参数时使用角色ID
        NBSDK.getInstance().submitServerAndRole(NBServerRoleSubmitTypes.CREATE_ROLE,info);
    }

    @Override
    public void LoginRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LoginRole(strData,callback);
        Log.e("unitylog","QKSdkProxy_okwan.LoginRole().....");
    }

    @Override
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LevelUp(strData,callback);
        Log.e("unitylog","QKSdkProxy_okwan.LevelUp().....");
        Map<String, String> info = new HashMap<String, String>();
        info.put("roleId", SdkDataManager.getInstance().RoleId); //角色ID
        info.put("roleName", SdkDataManager.getInstance().RoleName); //角色名称
        info.put("roleLevel", SdkDataManager.getInstance().RoleLevel); //角色等级
        info.put("roleCreateTime",SdkDataManager.getInstance().RoleCreateTime); //角色创建时时间戳
        info.put("cpUid", SdkDataManager.getInstance().CpUid); //游戏CP方帐号ID，无此参数时使用角色ID
        NBSDK.getInstance().submitServerAndRole(NBServerRoleSubmitTypes.ROLE_LEVELUP, info);
    }

    /**
     * 进入游戏
     * @param strData
     */
    @Override
    public  void EnterGame(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
        Map<String, String> info = new HashMap<String, String>();
        info.put("serverId", SdkDataManager.getInstance().ServerId); //服务器ID
        info.put("serverName", SdkDataManager.getInstance().ServerName); //服务器名称
        info.put("roleId", SdkDataManager.getInstance().RoleId); //角色ID
        info.put("roleName", SdkDataManager.getInstance().RoleName); //角色名称
        info.put("roleLevel", SdkDataManager.getInstance().RoleLevel); //角色等级
        info.put("roleCreateTime",SdkDataManager.getInstance().RoleCreateTime); //角色创建时时间戳
        info.put("cpUid", SdkDataManager.getInstance().CpUid); //游戏CP方帐号ID，无此参数时使用角色ID
        NBSDK.getInstance().submitServerAndRole(NBServerRoleSubmitTypes.ENTER_GAME, info);
    }

    @Override
    public void OpenUrlWithWebView(String strData,boolean isLandScape) {
        Log.e("unitylog","QKSdkProxy_okwan.OpenUrlWithWebView().....");
        super.OpenUrlWithWebView(strData,isLandScape);
    }



    @Override
    public void SelectServer(String strData) {
        super.SelectServer(strData);
        Log.e("unitylog","QKSdkProxy_okwan.SelectServer.....");
        Map<String, String> info = new HashMap<String, String>();
        info.put("serverId", SdkDataManager.getInstance().ServerId); //服务器ID
        info.put("serverName", SdkDataManager.getInstance().ServerName); //服务器名称
        NBSDK.getInstance().submitServerAndRole(NBServerRoleSubmitTypes.SELECT_SERVER, info);
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc logoutcallback;
    @Override
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Logout(strData, callback);
        Log.e("unitylog","QKSdkProxy_okwan.Logout.....");
        NBSDK.getInstance().logout();
        logoutcallback = callback;
    }

    private QKUnityBridgeManager.QKUnityCallbackFunc payCallback;
    @Override
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Pay(strData, callback);
        payCallback = callback;
        Log.e("unitylog","QKSdkProxy_okwan.Pay().....");
        final String data = strData;
        new Thread(new Runnable() {
            @Override
            public void run() {
                if(null != data)
                {
                    try {
                        JSONObject jsonObject=new JSONObject(data);
                        NBPayInfo payInfo=new NBPayInfo();
                        payInfo.setCpOrderId(jsonObject.getString("OrderId")); //游戏订单ID，全局唯一，
                        payInfo.setGoodsId(jsonObject.getString("ProductId")); //计费点ID/商品ID
                        payInfo.setGoodsName(jsonObject.getString("Title")); //商品名称
                        payInfo.setGoodsDesc(jsonObject.getString("Des")); //商品描述
                        payInfo.setOrderAmount(Integer.valueOf(jsonObject.getString("Price"))); //充值总金额,int,分
                        payInfo.setUnitName(jsonObject.getString("Vcname")); //可选，虚拟货币名称
                        payInfo.setGoodsNum(Integer.valueOf(jsonObject.getString("Count"))); //可选，商品数量，一般为1
                        payInfo.setGoinNum(Integer.valueOf(jsonObject.getString("AddVCount"))); //可选，此商品每份增加的虚拟货币数
                        payInfo.setCpExtra(jsonObject.getString("ExtraInfo")); //可选，透传参数，发货回调时
                        NBSDK.getInstance().pay(payInfo);
                    }
                    catch (JSONException e)
                    {
                        Log.e("Json Parse Error","Pay");
                    }
                }
            }
        }).start();
    }


    @Override
    public void GetDeviceStatus(String data, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.GetDeviceStatus(data, callback);
        Log.e("qiku","GetDeviceStatus.......");
        PowerConnectionReceiver.powercallback = callback;
    }

    @Override
    public void GetNetWorkChanged(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.GetNetWorkChanged(strData, callback);
        NetworkChangeReceiver.networkchangecallback = callback;
    }

    @Override
    public void RestartApp(String data) {
        super.RestartApp(data);
        Intent mStartActivity = new Intent(context, context.getClass());
        int mPendingIntentId = 123456;
        PendingIntent mPendingIntent = PendingIntent.getActivity(context,
                mPendingIntentId, mStartActivity,
                PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager mgr = (AlarmManager) context
                .getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 100,
                mPendingIntent);
        System.exit(0);
    }

    @Override
    public void GetDeviceInfo(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.GetDeviceInfo(strData, callback);
        Log.e("qiku","GetDeviceInfo.....");
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("BundleVersion", String.valueOf(QKSdkProxyUtility.getVersionCode()));
            jsonObject.put("Version", QKSdkProxyUtility.getVersionName());
            jsonObject.put("DeviceId", QKSdkProxyUtility.getIMEI());
            callback.Invoke(jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return super.onKeyUp(keyCode, event);
    }
}