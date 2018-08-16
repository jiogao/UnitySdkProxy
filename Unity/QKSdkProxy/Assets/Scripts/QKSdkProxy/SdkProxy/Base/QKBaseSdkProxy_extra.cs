using QKNativeBridge;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Events;

namespace QKSdkProxy
{
    public partial class QKBaseSdkProxy
    {
        //安卓返回键
        public const string BackPressedEvent = "BackPressedEvent";
        //注册sdk主动登出
        public const string SdkLogoutEvent = "SdkLogoutEvent";

        virtual public void RegisterEvent(string eventName, UnityAction<string> callback)
        {
            QKNativeBridgeManager.Instance.AddCallback(eventName, callback);
        }

        virtual public void GetDeviceInfo(UnityAction<DeviceInfoRet> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("GetDeviceInfo", null, (string strData) =>
            {
                DeviceInfoRet retObj = null;
                try
                {
                    retObj = JsonMapper.ToObject<DeviceInfoRet>(strData);
                }
                catch (Exception)
                {
                    Debug.LogError("QKBaseSdkProxy GetDeviceInfo ToObject failed: " + strData);
                }
                callback(retObj);
            });
        }

        virtual public void GetDeviceStatus(UnityAction<DeviceStatusRet> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("GetDeviceStatus", null, (string strData) =>
            {
                DeviceStatusRet retObj = null;
                try
                {
                    retObj = JsonMapper.ToObject<DeviceStatusRet>(strData);
                }
                catch (Exception)
                {
                    Debug.LogError("QKBaseSdkProxy GetDeviceStatus ToObject failed: " + strData);
                }
                callback(retObj);
            });
        }

        virtual public void GetNetWorkChanged(UnityAction<NetworkReachability> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("GetNetWorkChanged", null, (string strData) =>
            {
                int status = 0;
                int.TryParse(strData, out status);
                NetworkReachability type = (NetworkReachability)Enum.ToObject(typeof(NetworkReachability), status);
                callback(type);
            });
        }

        virtual public void OpenUrl(string url)
        {
            QKNativeBridgeManager.Instance.CallNative("OpenUrl", url, null);
        }

        virtual public void OpenUrlWithWebView(string url)
        {
            QKNativeBridgeManager.Instance.CallNative("OpenUrlWithWebView", url, null);
        }
    }
}
