using QKNativeBridge;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
/// <summary>
/// QKSdkProxy unity部分
/// 
/// 1.QKSdkProxyFactory.SdkProxy 获取当前QKSdkProxy
/// 2.扩展sdk proxy方法 : 
///     新增 QKBaseSdkProxy partial 方法public partial class QKBaseSdkProxy
///     参考 QKSdkProxy_okwan 和 QKSdkProxy_junhai
/// 
/// </summary>
namespace QKSdkProxy
{

#if UNITY_EDITOR || UNITY_STANDALONE || QK_NATIVE_CLOSE
    using Current_SdkProxy = QKSdkProxy_editor;
#else
    using Current_SdkProxy = QKSdkProxy_common;
#endif

    //#if UNITY_EDITOR
    public class QKSdkProxyFactory
    {
        static private Current_SdkProxy sdkProxy;
        static public Current_SdkProxy SdkProxy
        {
            get
            {
                if (sdkProxy == null)
                {
                    sdkProxy = new Current_SdkProxy();
                }
                return sdkProxy;
            }
        }
    }
}
