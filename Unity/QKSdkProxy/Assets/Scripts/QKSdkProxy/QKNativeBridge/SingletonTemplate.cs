using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace QKNativeBridge
{
    public abstract class QKSingletonTemplate<T> : MonoBehaviour where T : QKSingletonTemplate<T>
    {

        private static volatile T instance;
        private static object syncRoot = new Object();
        public static T Instance
        {
            get
            {
                if (instance == null)
                {
                    lock (syncRoot)
                    {
                        if (instance == null)
                        {
                            T[] instances = FindObjectsOfType<T>();
                            if (instances != null)
                            {
                                for (var i = 0; i < instances.Length; i++)
                                {
                                    Destroy(instances[i].gameObject);
                                }
                            }
                            GameObject go = new GameObject(typeof(T).Name);
                            //go.name = typeof(T).Name;
                            instance = go.AddComponent<T>();
                            DontDestroyOnLoad(go);

                            instance.OnInit();
                        }
                    }
                }
                return instance;
            }
        }

        protected abstract void OnInit();
    }
}
