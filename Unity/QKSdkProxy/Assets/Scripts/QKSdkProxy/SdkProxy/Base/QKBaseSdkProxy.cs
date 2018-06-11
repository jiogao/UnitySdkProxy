﻿using QKNativeBridge;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace QKSdkProxy
{
    public abstract partial class QKBaseSdkProxy // IQKSdkProxy//, IQKNativeInterface
    {
        virtual public void SdkInit(UnityAction<bool> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("SdkInit", null, (string strData)=>
            {
                callback(QKUtility.ToBoolean(strData));
            });
        }
        
        virtual public void Login(UnityAction<LoginInfoRet> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("Login", null, (string strData) =>
            {
                LoginInfoRet retObj = null;
                try
                {
                    retObj = JsonMapper.ToObject<LoginInfoRet>(strData);
                }
                catch (Exception)
                {
                    Debug.LogError("QKBaseSdkProxy Login ToObject failed: " + strData);
                }
                callback(retObj);
            });
        }
        
        virtual public void Logout(UnityAction<bool> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("Logout", null, (string strData) =>
            {
                callback(QKUtility.ToBoolean(strData));
            });
        }
        
        virtual public void Pay(PayInfo payInfo, UnityAction<bool> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("Pay", JsonMapper.ToJson(payInfo), (string strData) =>
            {
                callback(QKUtility.ToBoolean(strData));
            });
        }
        
        virtual public void ExitGame(UnityAction<bool> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("ExitGame", null, (string strData) =>
            {
                callback(QKUtility.ToBoolean(strData));
            });
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
        
        virtual public void ShowFloat()
        {
            QKNativeBridgeManager.Instance.CallNative("ShowFloat", null, null);
        }
        
        virtual public void HideFloat()
        {
            QKNativeBridgeManager.Instance.CallNative("HideFloat", null, null);
        }
        
        virtual public void SelectServer(ServerInfo serverInfo)
        {
            QKNativeBridgeManager.Instance.CallNative("SelectServer", QKUtility.ObjectToJson(serverInfo), null);
        }
        
        virtual public void CreateRole(RoleInfo roleInfo)
        {
            QKNativeBridgeManager.Instance.CallNative("CreateRole", QKUtility.ObjectToJson(roleInfo), null);
        }
        
        virtual public void SelectRole(RoleInfo roleInfo)
        {
            QKNativeBridgeManager.Instance.CallNative("SelectRole", QKUtility.ObjectToJson(roleInfo), null);
        }
        
        virtual public void EnterGame()
        {
            QKNativeBridgeManager.Instance.CallNative("EnterGame", null, null);
        }
        
        virtual public void LevelUp(RoleInfo roleInfo)
        {
            QKNativeBridgeManager.Instance.CallNative("LevelUp", QKUtility.ObjectToJson(roleInfo), null);
        }

        virtual public void UpdateUserGoods(UserGoodsInfo userGoodsInfo)
        {
            QKNativeBridgeManager.Instance.CallNative("UpdateUserGoods", QKUtility.ObjectToJson(userGoodsInfo), null);
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
