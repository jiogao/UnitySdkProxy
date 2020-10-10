package sdkproxy_imp;

import com.game.usdk.GameUSDK;
import org.json.JSONException;
import org.json.JSONObject;
import qksdkproxy.Utility.MyHttpURLConnect;

public class SdkHttpCommon {
    static String game_id = "109";
    static String host = "http://124.70.180.1:10004/api/login/checklogin";

// 登录验证接口
//    http://134.175.164.47/checklogin.php
//
//    请求参数
//    channel		 渠道标记，用来区分调用sdk接口    （hope_37）
//    userid		用户id （有的渠道是发用户id 过来验证是否通过,没有就填“”）
//    token		登录token （各渠道可能定义的字段名不同，这边统一用token字段传）
//    ext			保留扩展字段
//
//37sdk 参数
//    game_id		游戏id		(69)
//    c_game_id		客户端通过GameUSDK.getInstance().getChildGameId()获取的⼦游戏id
//
//返回
//    {
//        "ErrorCode":1,
//            "Message":"success",
//            "Data":{
//        "uid": 5237256, //⽤户uid
//                "is_phone_bind": 0, //是否绑定⼿机，1表示已绑定，0表示未绑定
//                "is_idcard_bind": 0, //是否绑定身份证，1表示已绑定，0表示未绑定
//                "is_adult": 0, //是否成年，1表示已绑定，0表示未绑定
//                "vip_level": 0, //vip等级
//                "is_youke": 1, //是否为第三⽅来源帐号，1表示是，0表示否
//                "is_bind_alias": 0 //是否绑定平台个性帐号
//    },
//    }
//    Data 中的内容为sdk 返回data中内容一至

    public static void CheckLogin(String userid, String token, String pfid, MyHttpURLConnect.HttpHander handler)
    {
        String Clinetid=GameUSDK.getInstance().getClientId();
        String childGameId = GameUSDK.getInstance().getChildGameId();
        String appid = GameUSDK.getInstance().getPlatformId();
        JSONObject ext=new JSONObject();
        try {
            ext.put("game_id",game_id);
            ext.put("c_game_id",childGameId);
            ext.put("clientid",Clinetid);
            ext.put("appid", appid);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        MyHttpURLConnect.doPost(host,
                "channel=" + pfid + "&userid=" + userid + "&token=" + token + "&ext=" + ext.toString(),
                handler);
    }
}
