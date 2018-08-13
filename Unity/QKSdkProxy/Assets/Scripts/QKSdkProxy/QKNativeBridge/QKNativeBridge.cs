//#undef UNITY_EDITOR
//#define UNITY_ANDROID
//#define QK_SDK_PROXY_LOG
//#define QK_NATIVE_CLOSE

using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Events;

namespace QKNativeBridge
{
    //public interface IQKNativeInterface
    //{
    //    void OnCallback(string funcName, string strData);
    //}

    public class QKNativeBridgeManager : QKSingletonTemplate<QKNativeBridgeManager>
    {
        private const string FuncName = "funcName";
        private const string StrData = "strData";

#if !UNITY_EDITOR && !QK_NATIVE_CLOSE
#if UNITY_ANDROID
        private static AndroidJavaClass jc = null;
        private static AndroidJavaObject jo = null;
#elif UNITY_IOS
        [DllImport("__Internal")]
        public static extern void QKNative_Call(string funcName, string strData);
#endif
#endif

        //private IQKNativeInterface nativeInterface;
        //public IQKNativeInterface NativeInterface
        //{
        //    set { nativeInterface = value; }
        //}

        protected Dictionary<string, UnityAction<string>> CallbackDic = new Dictionary<string, UnityAction<string>>();

        public void AddCallback(String funcName, UnityAction<string> callback)
        {
            CallbackDic[funcName] = callback;
        }

        virtual public void InvokeCallback(string funcName, string strData)
        {
            if (CallbackDic.ContainsKey(funcName))
            {
                CallbackDic[funcName](strData);
            }
        }

        // Use this for initialization
        protected override void OnInit()
        {
#if !UNITY_EDITOR && !QK_NATIVE_CLOSE
#if UNITY_ANDROID
            jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
#elif UNITY_IOS

#endif
#else
            Debug.Log("OnInit");
#endif
        }

        //调用oc/java
        public void CallNative(string funcName, string strData, UnityAction<string> callback)
        {
#if QK_SDK_PROXY_LOG
            Debug.Log("CallNative: " + funcName + ", strData:" + strData);
#endif
            if (callback != null)
            {
                AddCallback(funcName, callback);
            }

#if !UNITY_EDITOR && !QK_NATIVE_CLOSE
#if UNITY_ANDROID
            jo.Call("QKNative_Call", funcName, strData);
#elif UNITY_IOS
            QKNative_Call(funcName, strData);
#endif
#endif
        }

        //接收oc/java回调
        public void OnNativeCall(string jsonStr)
        {
#if QK_SDK_PROXY_LOG
            Debug.Log("OnNativeCall: " + jsonStr);
#endif
            JsonData jsonData = JsonMapper.ToObject(jsonStr);

            string funcName = jsonData[FuncName].ToString();
            string strData = jsonData[StrData].ToString();

            InvokeCallback(funcName, strData);

//            if (nativeInterface != null)
//            {
//                if (strData == null)
//                {
//                    strData = "";
//                }

//                nativeInterface.OnCallback(funcName, strData);

////                Type t = nativeInterface.GetType();
////                try
////                {
////                    MethodInfo m = t.GetMethod(funcName, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
////                    if (m != null)
////                    {
////#if QK_SDK_PROXY_LOG
////                        Debug.Log("found method: " + m.ReflectedType.Name + ":" + m.Name + "; " + (m.IsStatic ? "Static" : "Instance"));
////#endif
////                        m.Invoke(nativeInterface, new object[] { strData });
////                    }
////                    else
////                    {
////                        Debug.LogWarning("method not found: " + t.Name + "; funcName: " + funcName);
////                    }
////                }
////                catch (AmbiguousMatchException)
////                {
////                    Debug.LogWarning("multiple public overloads: " + t.Name + "; funcName: " + funcName);
////                }
////                catch (ArgumentNullException)
////                {
////                    Debug.LogWarning("name or types or (One of the elements in types) is null. " + funcName);
////                }
////                catch (ArgumentException)
////                {
////                    Debug.LogWarning("types or modifiers is multidimensional. " +  t.Name + "; funcName: " + funcName);
////                }
//            }
        }
    }
}
