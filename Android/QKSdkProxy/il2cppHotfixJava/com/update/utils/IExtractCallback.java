package com.update.utils;


public interface IExtractCallback {
    void onStart();

    void onGetFileNum(int fileNum);

    void onProgress(String name, long size);

    void onError(int errorCode, String message);

    void onSucceed();
}
