using QKNativeBridge;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine.Events;

namespace QKSdkProxy
{
    // okwan 提现功能扩展
    //提现信息
    public class QKSdkTBwithdrawalInfo
    {
        public string Amount;
        public string ExtraInfo;
    }

    // okwan
    public partial class QKBaseSdkProxy
    {

        //okWan 分销接口
        virtual public void TBLoginDistribution()
        {
            QKNativeBridgeManager.Instance.CallNative("TBLoginDistribution", null, null);
        }

        //okWan 提现接口
        virtual public void TBwithdrawal(QKSdkTBwithdrawalInfo withdrawInfo)
        {
            QKNativeBridgeManager.Instance.CallNative("TBwithdrawal", JsonMapper.ToJson(withdrawInfo), null);
        }
    }

    //public class QKSdkProxy_okwan : QKBaseSdkProxy
    //{

    //}
}
