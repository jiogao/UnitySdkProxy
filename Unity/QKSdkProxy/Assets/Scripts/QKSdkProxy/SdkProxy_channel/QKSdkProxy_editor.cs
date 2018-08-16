using QKNativeBridge;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Events;

namespace QKSdkProxy
{
    public class QKSdkProxy_editor : QKBaseSdkProxy
    {
        //sdk相应接口
        override public void SdkInit(UnityAction<bool> callback)
        {
            callback(true);
        }
        override public void Login(UnityAction<LoginInfoRet> callback)
        {
            LoginInfoRet edutorlogin = new LoginInfoRet();
            edutorlogin.IsSuccess = true;
            edutorlogin.Uid = "463295";
            callback(edutorlogin);
        }

        override public void Logout(UnityAction<bool> callback)
        {
            callback(true);
        }

        override public void Pay(PayInfo payInfo, UnityAction<bool> callback)
        {
            callback(false);
        }

        override public void ExitGame(UnityAction<bool> callback)
        {
            callback(false);
        }

        override public void GetDeviceInfo(UnityAction<DeviceInfoRet> callback)
        {
            callback(new DeviceInfoRet());
        }
        
        override public void GetDeviceStatus(UnityAction<DeviceStatusRet> callback)
        {
            callback(new DeviceStatusRet());
        }
    }
}
