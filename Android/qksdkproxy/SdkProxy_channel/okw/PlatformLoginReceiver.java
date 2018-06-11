package qksdkproxy.SdkProxy_channel.okw;

import android.content.SharedPreferences;
import qksdkproxy.Utility.MyHttpURLConnect;
import qksdkproxy.Utility.SdkDataManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by zwq on 2016/8/26.
 * SDK登陆成功后会发送一条广播通知，并携带返回数据
 * uid 注册
 * scode 登录
 */
public class PlatformLoginReceiver extends BroadcastReceiver
{
	private Context context;

	@Override
	public void onReceive(Context context, Intent intent) {

		Log.e("unitylog","skd方法onReceive()..............登录成功");
		try {
			String uid = intent.getStringExtra("uid");
			String scode = intent.getStringExtra("scode");
			String server = intent.getStringExtra("server");
			String sdk = intent.getStringExtra("sdk");

			if(uid.equals("")){
				Log.e("unitylog", "uid为空字符串！！！");

			}
			if(scode.equals("")){
				Log.e("unitylog", "scode为空字符串！！！");
			}
			SdkDataManager.getInstance().scode = scode;

			SharedPreferences preferences = context.getSharedPreferences("log", Context.MODE_PRIVATE);
			SharedPreferences.Editor editor = preferences.edit();
			editor.putString("server", server);
			editor.putString("sdk", sdk);

			String receive = "";
			SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			Date date = new Date(System.currentTimeMillis());
			JSONObject jo = new JSONObject();
			try
			{
				jo.put("IsSuccess",true);
				jo.put("Token","");
				if ("".equals(uid)){

					receive = "0"+"???"+scode+"???"+simpleDateFormat.format(date);

					new Runnable() {
						@Override
						public void run() {
							String responseStr = null;
							try {
								String params = "channel=ios_okw"+ "&token=" + scode + "&api_key=" + FinalInfos.APIKEY;
								MyHttpURLConnect.doPost(FinalInfos.OKLOGINURL,params, new MyHttpURLConnect.HttpHander() {
									public void onResult(String result)
									{
										Log.e("unitylog","接收返回的data数据：" + result);
										if(!result.equals(""))
										{
											try {
												JSONObject obj = new JSONObject(result);
												jo.put("Uid",obj.getString("uid"));
												SdkDataManager.getInstance().SdkUserId = obj.getString("uid");
												QKSdkProxy_okwan.loginCallback.Invoke(jo.toString());
											}catch (JSONException e)
											{
												e.printStackTrace();
											}
										}
										else
										{
											Log.e("unitylog","接收返回的data数据为空字符串！！！！！");
										}
									}
								});

							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					}.run();
				}else {
					receive = uid+"???"+scode+"???"+simpleDateFormat.format(date);
					SdkDataManager.getInstance().SdkUserId = uid;
					jo.put("Uid",uid);
					QKSdkProxy_okwan.loginCallback.Invoke(jo.toString());
				}

				editor.putString("receive", receive);
				editor.commit();

			}catch (JSONException e)
			{
				e.printStackTrace();
			}

		}catch (Exception e)
		{
			Log.e("unitylog","12121212121 " + e.getMessage());

		}
	}

}
