package com.update.utils;

public class Boostrap {
    public static native void init(String filePath,String updateFilePath);
    public static void InitNativeLibBeforeUnityPlay(String filePath,String updateFilePath)
    {
        System.loadLibrary("main");
        System.loadLibrary("unity");
        System.loadLibrary("bootstrap");
        init(filePath,updateFilePath);
    }
}
