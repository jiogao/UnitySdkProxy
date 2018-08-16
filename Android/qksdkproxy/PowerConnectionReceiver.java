package qksdkproxy;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import org.json.JSONObject;

import qksdkproxy.QKUnityBridge.QKUnityBridgeManager;

public class PowerConnectionReceiver extends BroadcastReceiver{

	 public static QKUnityBridgeManager.QKUnityCallbackFunc powercallback;
	  public void onReceive(Context context, Intent intent)
	  {
	    if (Intent.ACTION_BATTERY_CHANGED.equals(intent.getAction()))
	    {
	      int level = intent.getIntExtra("level", 0);

	      int total = intent.getIntExtra("scale", 100);
	      if (total != 0) {
	        float nowPow = (float)level / total;
	        if(null != powercallback)
			{
				Log.e("unitylog","电量回调。。。。");
				try{
                    JSONObject data = new JSONObject();
                    data.put("Power",(double)nowPow);
                    powercallback.Invoke(data.toString());
                }catch (Exception e){
                    Log.e("qiku",e.getMessage());
                }
			}
	      }
	    }
	    else if(Intent.ACTION_BATTERY_LOW.equals(intent.getAction()))
        {
            Toast.makeText(context,"电量过低，请尽快充电！",Toast.LENGTH_LONG).show();
        }
        else if(Intent.ACTION_BATTERY_OKAY.equals(intent.getAction())){
            Toast.makeText(context,"电量已恢复，可以使用！",Toast.LENGTH_LONG).show();
        }
	  }
}
