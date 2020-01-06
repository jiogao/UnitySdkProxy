package qksdkproxy.SdkProxy_channel.okw;

import android.content.SharedPreferences;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;
import qksdkproxy.SdkProxy.Base.QKBaseSdkProxy;
import qksdkproxy.Utility.SdkDataManager;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import android.widget.Toast;
import com.haiyun.zwq.kxwansdk.activity.*;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.text.SimpleDateFormat;
import java.util.*;

import static android.content.Context.MODE_PRIVATE;

public class QKSdkProxy_okwan extends QKBaseSdkProxy
{

    public static QKUnityBridgeManager.QKUnityCallbackFunc loginCallback;
    public static QKUnityBridgeManager.QKUnityCallbackFunc payCallback;

    @Override
    public void SdkInit(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.SdkInit(strData, callback);
        Log.e("unitylog","QKSdkProxy_okwan.SdkInit().....");
        callback.Invoke("YES");
    }

    @Override
    public void Login(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Login(strData, callback);
        loginCallback = callback;
        Log.e("unitylog","skd方法login()..............");
        Intent intent = new Intent(context,NotificationStarterActivity.class);
        intent.putExtra("gid", "204");
        intent.putExtra("api_key", "90a7559f6a4b414861cb6c7f85b18865");
        intent.putExtra("secret_key", "8bc0e788fb2c69d193f04fe0be804507");
        context.startActivity(intent);
    }

    @Override
    public void ExitGame(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.ExitGame(strData, callback);
        Log.e("unitylog","QKSdkProxy_okwan.ExitGame().....");
        callback.Invoke("YES");
    }

    @Override
    public void CreateRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.CreateRole(strData,callback);
        SDKGetRoleInfo(context);
        Log.e("unitylog","QKSdkProxy_okwan.CreateRole().....");
    }

    @Override
    public void LoginRole(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LoginRole(strData,callback);
        SDKGetRoleInfo(context);
        Log.e("unitylog","QKSdkProxy_okwan.LoginRole().....");
    }

    @Override
    public void LevelUp(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.LevelUp(strData,callback);
        Log.e("unitylog","QKSdkProxy_okwan.LevelUp().....");
        SDKGetRoleInfo(context);
    }

    @Override
    public void OpenUrlWithWebView(String strData,boolean isLandScape) {
        Log.e("unitylog","QKSdkProxy_okwan.OpenUrlWithWebView().....");
        super.OpenUrlWithWebView(strData,isLandScape);
    }

    public void SDKGetRoleInfo(Context context) {
        Log.e("unitylog","QKSdkProxy_okwan.SDKGetRoleInfo().....");

        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = new Date(System.currentTimeMillis());
        String num = getPhoneInfo();
        SharedPreferences preferences = context.getSharedPreferences("log", MODE_PRIVATE);
        Map<String, String> map = new HashMap<String,String>();
        map = (Map<String, String>) preferences.getAll();
        String server = map.get("server");
        String sdk = map.get("sdk");
        String receive = map.get("receive");
        //uid和scode需替换成真实值
        //String send = "uid"+"???"+"scode"+"???"+num+"???"+simpleDateFormat.format(date);
        String send = SdkDataManager.getInstance().SdkUserId +"???"+SdkDataManager.getInstance().scode+"???"+num+"???"+simpleDateFormat.format(date);
        KxwGetRoleInfoActivity info = new KxwGetRoleInfoActivity();
        info.getRoleInfo(context, SdkDataManager.getInstance().RoleName, SdkDataManager.getInstance().RoleLevel, SdkDataManager.getInstance().ServerId, SdkDataManager.getInstance().ServerName, server, sdk, receive, send);


        //KxwGetRoleInfoActivity info = new KxwGetRoleInfoActivity();
        //info.getRoleInfo(context,SdkDataManager.getInstance().RoleName,SdkDataManager.getInstance().RoleLevel,SdkDataManager.getInstance().ServerId,SdkDataManager.getInstance().ServerName);
    }



    /**
     * 获取设备编号
     */
    public String getPhoneInfo(){
        TelephonyManager tm = (TelephonyManager) context.getSystemService(context.getApplicationContext().TELEPHONY_SERVICE);
        String imei = tm.getDeviceId();
        if(imei == null){
            String android_id = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            if(android_id == null){
                String macSerial = null;
                String str = "";
                try {
                    Process pp = Runtime.getRuntime().exec("cat /sys/class/net/wlan0/address ");
                    InputStreamReader ir = new InputStreamReader(pp.getInputStream());
                    LineNumberReader input = new LineNumberReader(ir);
                    for (; null != str;) {
                        str = input.readLine();
                        if (str != null) {
                            macSerial = str.trim();// 去空格
                            break;
                        }
                    }
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                if(macSerial == null){
                    imei = "";
                }else {
                    imei = macSerial;
                }
            }else {
                imei = android_id;
            }
        }
        return imei;
    }


    @Override
    public void SelectServer(String strData) {
        super.SelectServer(strData);
    }

    public void TBLoginDistribution(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        if(!canGoOn())
        {
            return;
        }

        Log.e("unitylog","QKSdkProxy_okwan.TBLoginDistribution().....");
        Intent intent = new Intent(context,KxwDistributionSystemActivity.class);
        context.startActivity(intent);

        /*
        KxwDistributionSystemActivity activity = new KxwDistributionSystemActivity();
        activity.judge(context, new OnDistributionCallBack(){
            @Override
            public void onSuccess(String s) {
                Log.e("unitylog","QKSdkProxy_okwan.TBLoginDistribution.onSuccess().....");

                OpenUrlWithWebView(s,false);
            }

            @Override
            public void onError(String s) {

                Log.e("unitylog","获取分销URL登录失败。。。。。");
            }
        });
        */

    }

    public void TBwithdrawal(String strData,QKUnityBridgeManager.QKUnityCallbackFunc callback)
    {
        if(!canGoOn())
        {
            return;
        }
        Log.e("unitylog","QKSdkProxy_okwan.TBwithdrawal().....");
        if(null != strData) {
            KxwWithDrawActivity withDraw = new KxwWithDrawActivity();
            try {
                JSONObject value = new JSONObject(strData);
                String amount = value.getString("Amount");      //金额
                int amoutf = 0;
                try {
                    int aa = Integer.parseInt(amount);
                    if (aa < 100) {
                        Toast.makeText(context, "提现钻石数量不能小于100!", Toast.LENGTH_SHORT).show();
                        return;
                    }
                    amoutf = aa / 100;
                }catch (NumberFormatException e)
                {
                    e.printStackTrace();
                }
                String amountStr = String.valueOf(amoutf);
                String serid = SdkDataManager.getInstance().ServerId;
                String attach = value.getString("ExtraInfo");

                Intent intent = new Intent(context, KxwWithDrawActivity.class);
                intent.putExtra("amount", amountStr);
                intent.putExtra("serverId", serid);
                intent.putExtra("roleName", SdkDataManager.getInstance().RoleName);
                intent.putExtra("attach", attach);
                context.startActivity(intent);
                /*
                withDraw.applyWithDraw(context, amountStr, serid, SdkDataManager.getInstance().RoleName, attach, new OnWithDrawCallBack() {
                    @Override
                    public void onSuccess(String s) {
                        Log.e("unitylog","QKSdkProxy_okwan.TBwithdrawal.onSuccess().....");
                        OpenUrlWithWebView(s,true);
                    }

                    @Override
                    public void onError(String s) {
                        Log.e("unitylog", "申请提现失败。。。。。");
                        Toast.makeText(context, "提现失败！！！" + s, Toast.LENGTH_SHORT).show();
                    }
                });
                */
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }


    @Override
    public void Logout(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Logout(strData, callback);
        Log.e("unitylog","QKSdkProxy_okwan.Logout.....");
        KxwLoginOutActivity loginOut = new KxwLoginOutActivity();
        loginOut.loginOut(context);
        SdkDataManager.getInstance().clearData();
        callback.Invoke("YES");
    }


    @Override
    public void Pay(String strData, QKUnityBridgeManager.QKUnityCallbackFunc callback) {
        super.Pay(strData, callback);
        payCallback = callback;
        Log.e("unitylog","QKSdkProxy_okwan.Pay().....");
        if(null != strData)
        {
            SDKGetRoleInfo(context);
            try {
                JSONObject value = new JSONObject(strData);
                String gameName = getGameName();
                String orderOn = value.getString("OrderId");        //订单号
                String body = value.getString("Des");            //商品描述
                String moneyStr = value.getString("Price");
                String amount = "";
                try {
                    int a = Integer.valueOf(moneyStr).intValue();
                    amount = String.valueOf(a / 100);                  //金额
                }catch (NumberFormatException e)
                {
                    e.printStackTrace();
                }

                String goodsNum = value.getString("Count");     //商品数量
                Intent intent = new Intent(context,KxwAccountInfoActivity.class);
                intent.putExtra("gameName", gameName);
                intent.putExtra("orderOn", orderOn);
                intent.putExtra("body", body);
                intent.putExtra("roleId", SdkDataManager.getInstance().SdkUserId);
                intent.putExtra("serverName", SdkDataManager.getInstance().ServerName);
                intent.putExtra("serverId", SdkDataManager.getInstance().ServerId);
                intent.putExtra("amount", amount);
                intent.putExtra("goodsNum",goodsNum);
                intent.putExtra("attach", "");
                Log.e("unitylog","1111111111111111111 == Pay........");
                context.startActivity(intent);
            }
            catch (JSONException e)
            {
                e.printStackTrace();
            }
        }
    }


    private boolean isClicked = false;

    private boolean canGoOn()
    {
        if(isClicked)
            return false;
        isClicked = true;
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            public void run() {
                isClicked = false;
                System.out.println("-------设定要指定任务--------");
            }
        }, 2000);
        return true;
    }

    @Override
    public String getGameName()
    {
        return "赏金传奇";
    }

}