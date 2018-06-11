using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace QKSdkProxy
{
    //oc/java->unity  在oc/java中的回调中传入相应的json结构

    //登录返回
    public class LoginInfoRet
    {
        public bool IsSuccess;//登录成功/失败
        public string Uid;
        public string Token;
        public string game_id;
        public string channel_id;
        public string game_channel_id;
    }

    //设备信息
    public class DeviceInfoRet
    {
        public string BundleVersion;//build版本号
        public string Version;//app版本号
        public string DeviceId;//设备标识码
    }

    //设备状态
    public class DeviceStatusRet
    {
        public double Power;//电量
    }

    //网络状态
    public enum NetworkStatus : int 
    {
        NotReachable = 0,
        ReachableViaWiFi = 2,
        ReachableViaWWAN = 1,
    }

    //unity->oc/java

    //服务器信息
    public class ServerInfo
    {
        public string ServerId;//服务器id0
        public string ServerName;//服务器名
    }

    //角色信息
    public class RoleInfo
    {
        public string RoleId;//角色ID
        public string RoleName;//角色名称
        public string RoleLevel;//角色等级
        public string RoleCreateTime;//角色创建时时间戳
        public string RoleUpdateTime;//角色信息更新时间
        public string RoleVipLevel;//角色vip等级
        public string RoleGold;//角色拥有的金币
    }
    
    //商品信息
    public class PayInfo
    {
        public string OrderId;     //订单号

        //1 消耗型计费点,如金币，元宝等
        //2:非消耗型计费点,一次购买永远拥有的，如vip等功能
        //3:订阅型计费点，如使用周期一个星期，到期后还需要续费的
        public string paymentType;

        public string ProductId;   //商品id
        public string Title;       //商品名称
        public string Price;       //充值金额，单位分
        public string Des;         //商品描述
        public string Count;       //商品数量
        public string Vcname;      //虚拟货币名称
        public string AddVCount;       //添加的虚拟货币数量
        public string ExtraInfo;   //透传参数
    }

    //物品变化信息
    public class UserGoodsInfo
    {
        public string ConsumCoin;       // 购买道具所花费的游戏币
        public string RemainCoin;       // 剩余多少游戏币
        public string ConsumeBind;      // 购买道具所花费的绑定游戏币
        public string RemainBind;       // 剩余多少绑定游戏币
        public string ItemName;         // 道具名称
        public string ItemCount;        // 购买道具的数量
        public string ItemDes;          // 道具描述,可以传空串
    }


    //class SdkProxyData
    //{
    //}
}
