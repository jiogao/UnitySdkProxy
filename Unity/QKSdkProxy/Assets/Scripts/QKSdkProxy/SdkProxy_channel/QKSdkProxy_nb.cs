using QKNativeBridge;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine.Events;

namespace QKSdkProxy
{
    // nbsdk
    public partial class QKBaseSdkProxy
    {
        //nbsdk 绑定手机
        virtual public void NBBindPhone(UnityAction<bool> callback)
        {
            QKNativeBridgeManager.Instance.CallNative("NBBindPhone", null, (string strData) =>
            {
                callback(QKUtility.ToBoolean(strData));
            });
        }
        
    }

    //public class QKSdkProxy_nb : QKBaseSdkProxy
    //{

    //}
}
