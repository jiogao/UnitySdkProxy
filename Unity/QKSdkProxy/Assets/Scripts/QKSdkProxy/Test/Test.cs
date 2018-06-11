using QKSdkProxy;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace QKSdkProxy
{
    public class Test : MonoBehaviour
    {

        // Use this for initialization
        void Start()
        {
            Debug.Log("TestScene Start");
            //初始化
            QKSdkProxyFactory.SdkProxy.SdkInit((bool initRet) =>
            {
                Debug.Log("initRet: " + initRet);
                //登录
                QKSdkProxyFactory.SdkProxy.Login((LoginInfoRet loginRet) =>
                {
                    Debug.Log("loginRet: " + loginRet);

                    //显示悬浮框
                    QKSdkProxyFactory.SdkProxy.ShowFloat();
                    //隐藏悬浮框
                    QKSdkProxyFactory.SdkProxy.HideFloat();

                    //登录服务器
                    QKSdkProxyFactory.SdkProxy.SelectServer(new ServerInfo() { ServerId = "s1" });
                    //创建角色
                    QKSdkProxyFactory.SdkProxy.CreateRole(new RoleInfo() { RoleId = "1" });
                    //登录角色
                    QKSdkProxyFactory.SdkProxy.SelectRole(new RoleInfo());
                    //进入游戏角色
                    QKSdkProxyFactory.SdkProxy.EnterGame();
                    //角色升级
                    QKSdkProxyFactory.SdkProxy.LevelUp(new RoleInfo());
                    //物品变化(需要数据比较多,如果当前的sdk没有这个接口可以先不接)
                    QKSdkProxyFactory.SdkProxy.UpdateUserGoods(new UserGoodsInfo());
                    //获取当前设备信息
                    QKSdkProxyFactory.SdkProxy.GetDeviceInfo((DeviceInfoRet deviceInfo) =>
                    {
                        Debug.Log("GetDeviceInfo: " + deviceInfo);
                    });

                    //获取当前是被状态
                    QKSdkProxyFactory.SdkProxy.GetDeviceStatus((DeviceStatusRet deviceStatus) =>
                    {
                        Debug.Log("GetDeviceStatus: " + deviceStatus);
                    });

                    //监听网络状态变化
                    QKSdkProxyFactory.SdkProxy.GetNetWorkChanged((NetworkReachability networkStatus) =>
                    {
                        Debug.Log("GetNetWorkChanged: " + networkStatus);
                    });

                    //支付
                    QKSdkProxyFactory.SdkProxy.Pay(new PayInfo(), (bool ret) =>
                    {
                    });

                    //登出
                    QKSdkProxyFactory.SdkProxy.Logout((bool logoutRet) =>
                    {
                        Debug.Log("Logout: " + logoutRet);
                    });

                    //退出游戏
                    QKSdkProxyFactory.SdkProxy.ExitGame((bool exitGameRet) =>
                    {
                        Debug.Log("ExitGame: " + exitGameRet);
                    });

                    //okwan sdk 分销
                    QKSdkProxyFactory.SdkProxy.TBLoginDistribution();
                    //okwan sdk 提现
                    QKSdkProxyFactory.SdkProxy.TBwithdrawal(new QKSdkTBwithdrawalInfo());

                    //获取 junhai sdk 实名制信息
                    QKSdkProxyFactory.SdkProxy.JunhaiGetRealNameInfo((JunhaiRealNameInfo realNameInfo) =>
                    {
                        Debug.Log("JunhaiGetRealNameInfo: " + realNameInfo);
                    });

                });
            });

        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}
