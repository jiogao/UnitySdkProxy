package qksdkproxy.SdkProxy_channel.okw;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * Created by zwq on 2016/8/26.
 * SDK判断支付成功后会发送一条广播通知,“1”为成功
 */
public class PlatformPayReceiver extends BroadcastReceiver {
	@Override
	public void onReceive(Context context, Intent intent) {
		Log.e("unitylog","PlatformPayReceiver.onReceive()........");
		String status = intent.getStringExtra("status");
		if(status.equals("1"))
		{
			QKSdkProxy_okwan.payCallback.Invoke("true");
		}
		else
		{
			Log.e("unitylog","支付失败！！！");
			QKSdkProxy_okwan.payCallback.Invoke("false");
		}

	}
}
