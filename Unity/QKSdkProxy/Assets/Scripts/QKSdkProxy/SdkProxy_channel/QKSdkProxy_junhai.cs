using QKNativeBridge;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Events;

namespace QKSdkProxy
{
    // junhai 实名制功能扩展

    /**
    * retCode说明：
    * Constants.ErrorCode.AUTHENTICATION_OK = 41，表示渠道SDK有实名制且能够获取实名制结果，研发只需要通过data获取验证结果，然后实现防沉迷功能
    * Constants.ErrorCode.AUTHENTICATION_UNKNOWN = 40，表示渠道SDK有实名制但不能获取实名制结果，研发不需要实现实名制功能，但是需要实现防沉迷功能
    * Constants.ErrorCode.AUTHENTICATION_NEVER = 42，表示渠道SDK没有实名制功能，研发需要自行实现实名制功能，并实现防沉迷功能
    *
    研发拿到这些数据后，根据需要进行实名制和防沉迷等逻辑操作。
    */
    public class JunhaiRealNameInfo
    {
        public enum SDKRetCode
        {
            AUTHENTICATION_UNKNOWN = 40,    //表示渠道SDK有实名制但不能获取实名制结果，研发不需要实现实名制功能，但是需要实现防沉迷功能
            AUTHENTICATION_OK = 41,         //表示渠道SDK有实名制且能够获取实名制结果，研发只需要通过data获取验证结果，然后实现防沉迷功能
            AUTHENTICATION_NEVER = 42,      //表示渠道SDK没有实名制功能，研发需要自行实现实名制功能，并实现防沉迷功能
        }

        public SDKRetCode retCode; //retCode
        public int age; //玩家年龄。如果获取不到数据就为空串。
        public bool is_adult; //玩家是否成年，true表示成年，false表示未成年。
        public bool real_name_authentication; //玩家是否实名制，true表示完成了实名制，false表示没有完成实名制。如果获取不到数据就为空串。
        public string mobile; //玩家手机号码。如果获取不到数据就为空串。
        public string real_name; //玩家真实姓名。如果获取不到数据就为空串。
        public string id_card; //玩家身份证号码。如果获取不到数据就为空串。
    }

    public partial class QKBaseSdkProxy
    {

        //junhai 实名制
        virtual public void JunhaiGetRealNameInfo(UnityAction<JunhaiRealNameInfo> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("JunhaiGetRealNameInfo", null, (string strData) =>
            {
                JunhaiRealNameInfo retObj = null;
                try
                {
                    retObj = JsonMapper.ToObject<JunhaiRealNameInfo>(strData);
                }
                catch (Exception)
                {
                    Debug.LogError("QKBaseSdkProxy GetDeviceStatus ToObject failed: " + strData);
                }
                callback(retObj);
            });
        }
    }

    //class QKSdkProxy_junhai
    //{
    //}
}
