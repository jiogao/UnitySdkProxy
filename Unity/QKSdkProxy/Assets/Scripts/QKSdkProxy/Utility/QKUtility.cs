using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.Serialization;
using System.Diagnostics;
using System;
using QKNativeBridge;

namespace QKSdkProxy
{
    static public class QKUtility
    {
        static public bool ToBoolean(string str)
        {
            bool ret = false;
            if (str == null || str.Equals("YES", StringComparison.OrdinalIgnoreCase))
            {
                ret = true;
            }
            else
            {
                try
                {
                    ret = Convert.ToBoolean(str);
                }
                catch (Exception e)
                {
                    StackTrace st = new StackTrace(new StackFrame(true));
                    StackFrame sf = st.GetFrame(0);

                    UnityEngine.Debug.LogWarning("Convert fail: " + sf.GetFileName() + "==>" + sf.GetMethod().Name + ": " + e.Message);
                }
            }
            return ret;
        }

        static public T JsonToObject<T>(string json)
        {
            try
            {
                return JsonMapper.ToObject<T>(json);
            }
            catch (Exception e)
            {
                StackTrace st = new StackTrace(new StackFrame(true));
                StackFrame sf = st.GetFrame(0);

                UnityEngine.Debug.LogWarning("Convert fail: " + sf.GetFileName() + "==>" + sf.GetMethod().Name + ": " + e.Message);
            }
            return default(T);
        }

        static public string ObjectToJson(object obj)
        {
            string ret = null;
            try
            {
                ret = JsonMapper.ToJson(obj);
            }
            catch (Exception e)
            {

                StackTrace st = new StackTrace(new StackFrame(true));
                StackFrame sf = st.GetFrame(0);

                UnityEngine.Debug.LogWarning("Convert fail: " + sf.GetFileName() + "==>" + sf.GetMethod().Name + ": " + e.Message);
            }
            return ret;
        }
    }
}
