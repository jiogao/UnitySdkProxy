package qksdkproxy.SdkProxy_channel.okw;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Created by zwq on 2016/8/26.
 * SDK获取Token后会发送一条广播通知，并携带token数据
 */
public class PlatformTokenReceiver extends BroadcastReceiver {
	
	@Override
	public void onReceive(Context context, Intent intent) {
		String token = intent.getStringExtra("token");

	}

}
