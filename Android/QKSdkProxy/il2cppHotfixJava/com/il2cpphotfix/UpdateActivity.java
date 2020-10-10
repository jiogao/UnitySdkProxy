package com.il2cpphotfix;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import qksdkproxy.SdkProxy.SdkSupport.QKUnityPlayerActivity;

import com.unity3d.player.BuildConfig;
import com.unity3d.player.R;
import com.update.utils.Boostrap;
import com.update.utils.UnzipCallback;
import com.update.utils.Z7Extractor;
import java.io.RandomAccessFile;
import android.Manifest;
import android.support.v4.app.ActivityCompat;
import java.util.LinkedList;
import java.util.List;
import android.support.v4.content.ContextCompat;
import android.content.pm.PackageManager;

public class UpdateActivity extends Activity {

    private String UpdateService= BuildConfig.UPDATE_SERVICE;
    private String cdnPath = "";
    private TextView labTip;
    private int errorNums = 0;//获取cdn地址错误次数
    private Runnable runnable;
    private static final String logTag = "HOTUPDATE_TAG";
    private static final String dllMD5FileName = "acdllhash.json"; //从CDN上要拉取的MD5文件名
    private static final String dllMD5SaveFileName = "hu.gMD5"; //更新完成后写入的MD5文件名
    private static final String huFlagFileName = "hu.gflag";  //热更文件解压完成后的标记文件
    private Button fixBtn = null;
    //private Boolean isSkipCDN = true;
    private String cachedPath = "";
    private Boolean isDllMode = false;
    private String cpu_abi="";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            finish();
            return;
        }


        cpu_abi=GetCPUABI();
        setContentView(R.layout.update_layout);
        hideBottomUIMenu();
        labTip = (TextView) findViewById(R.id.labTip);
        labTip.setText(R.string.update_init);
        //Typeface typeface = Typeface.createFromAsset(getAssets(),"font/simhei.ttf");
        //labTip.setTypeface(typeface);
        cachedPath = getApplication().getExternalFilesDir("").toString();
        // 23 动态获取权限
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && getApplicationInfo().targetSdkVersion >= 23)
        {
            checkPermissions();
        }
        else
        {
            getCDN();
        }
    }

    /**
     * 申请权限
     */
    int MY_PERMISSIONS_REQUEST_READ_EXTERNAL_STORAGE = 1;
    public void checkPermissions() {
        List<String> permissions = new LinkedList<>();

        addPermission(permissions, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        addPermission(permissions, Manifest.permission.CAMERA);
        addPermission(permissions, Manifest.permission.RECORD_AUDIO);
        addPermission(permissions, Manifest.permission.READ_PHONE_STATE);

        if (!permissions.isEmpty()) {
            ActivityCompat.requestPermissions(this, permissions.toArray(new String[permissions.size()]),
                    MY_PERMISSIONS_REQUEST_READ_EXTERNAL_STORAGE);
        }
        else
        {
            getCDN();
        }

    }

    private void addPermission(List<String> permissionList, String permission) {

        if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
            permissionList.add(permission);
        }
    }

    /**
     * 申请后的处理
     */
    @Override
    public void onRequestPermissionsResult(
            int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Log.i(logTag,"权限结果："+permissions);
        getCDN();
    }


    @Override
    public void onBackPressed()
    {
        super.onBackPressed();
        Log.i(logTag, "onBackPressed" );
        return;
    }

    /**
     * 隐藏导航栏
     */
    protected void hideBottomUIMenu() {
        //隐藏虚拟按键，并且全屏
        if (Build.VERSION.SDK_INT > 11 && Build.VERSION.SDK_INT < 19) { // lower api
            View v = this.getWindow().getDecorView();
            v.setSystemUiVisibility(View.GONE);
        } else if (Build.VERSION.SDK_INT >= 19) {
            View decorView = getWindow().getDecorView();
            int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN;
            decorView.setSystemUiVisibility(uiOptions);
        }
    }

    /**
     * 获取CDN地址
     */
    private void getCDN() {
        Log.i(logTag,"get cdn");
        boolean skipcdn = false;
        String skipFlagPath = cachedPath + "/skipcdn.flag";
        File file = new File(skipFlagPath);
        if (file.exists()) {
            skipcdn = true;
        }
       if(skipcdn){
           OnPreEnterGame();
           return;
       }
       try {
            String pkName = this.getPackageName();
            String versionName = this.getPackageManager().getPackageInfo(
                    pkName, 0).versionName;
            SendRequest(pkName, versionName);
        } catch (Exception e) {
        }
    }

    private void SendRequest(final String packageName, final String versionName) {
        //这里替换获取CDN的地址
        String strURL = UpdateService+"?appid=" + packageName + "&appver=" + versionName;
        Log.i(logTag, "开始获取CDN：" + strURL);
        OkHttpClient client = new OkHttpClient.Builder().connectTimeout(2, TimeUnit.SECONDS).readTimeout(2, TimeUnit.SECONDS)
                .writeTimeout(2, TimeUnit.SECONDS).build();
        Request request = new Request.Builder().get().url(strURL).build();
        Call call = client.newCall(request);
        call.enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        errorNums++;
                        if (errorNums < 3) {
                            SendRequest(packageName, versionName);
                        } else {
                            //弹出获取出错框
                            showCDNErrorMessage();
                        }
                    }
                });
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.code() == 404) {
                    Log.e(logTag, "获取CDN地址 Error 404 not found");
                    showCDNErrorMessage();
                } else {
                    final String responseStr = response.body().string();
                    Log.i(logTag, "CDN获取成功：" + responseStr);
                    parseCDN(responseStr);
                }
                response.close();
            }
        });
    }

    /**
     * 解析CDN地址
     *
     * @param strCallBack
     */
    private void parseCDN(String strCallBack) {
        try {
            JSONObject jd = new JSONObject(strCallBack);
            String errorCode = jd.getString("ErrorCode");
            if (errorCode.equals("1")) {
                JSONObject data = new JSONObject(jd.getString("Data"));
                String appstoreURL = data.getString("appstoreurl");
                if (null != appstoreURL && appstoreURL.length() > 0) {
                    //需要强制更新
                    Log.i(logTag,"强制更新：" + appstoreURL);
                    showAppStoreMessage(appstoreURL);
                } else {
                    //更新
                    cdnPath = data.getString("cdn");
                    Log.i(logTag, "CDN地址：" + cdnPath);

                    if(cdnPath.isEmpty())
                    {
                        showConfigCDNMessage();
                    }else
                    {
                        checkCodeUpdate();
                    }
                }
            } else {
                Log.e(logTag, "获取CDN地址失败：errocode=" + errorCode);
                showCDNErrorMessage();
            }
        } catch (JSONException e) {
            showCDNErrorMessage();
            Log.e(logTag,"获取CDN地址异常：返回结果->" + strCallBack + "   异常" + e.toString());
        }
    }

    private void showAppStoreMessage(final String appUrl)
    {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
                builder.setTitle(R.string.update_error_title);
                builder.setMessage("发现最新版本，需更新后才能继续使用");
                builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        openURL(appUrl);
                    }
                });
                builder.setCancelable(false);
                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
    }

    private String GetDownloadUrl(String file){
        return  cdnPath + "/Android/"+cpu_abi+"/" + file;

    }

    /**
     * 打开URL
     *
     * @param url
     */
    private void openURL(String url) {
        Intent intent = new Intent();
        intent.setAction("android.intent.action.VIEW");
        Uri content_url = Uri.parse(url);
        intent.setData(content_url);
        startActivity(intent);
    }

    /**
     * 检查代码更新
     */
    private void checkCodeUpdate() {

        String settingPath = GetDownloadUrl(dllMD5FileName);
        Log.i(logTag, "获取 补丁 版本文件" + settingPath + "...");
        try{
            OkHttpClient client = new OkHttpClient();
            Request request = new Request.Builder().get().url(settingPath).build();
            Call call = client.newCall(request);
            call.enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Log.e(logTag, "补丁 版本文件不存在,直接进入游戏1");
                            OnPreEnterGame();
                            //enterGame();
                        }
                    });
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    if (response.code() == 404) {
                        //没有配置文件直接进入游戏
                        Log.e(logTag, "补丁 版本文件不存在,直接进入游戏2");
                        //enterGameNoUpdate();
                        ClearOldPatch();
                        OnPreEnterGame();
                    } else {
                        final String responseStr = response.body().string();
                        Log.e(logTag, "补丁 版本文件获取成功：" + responseStr);

                        try
                        {
                            JSONArray jr=new JSONArray(responseStr);
                            if(jr.length()>0) {
                                for (int i = 0; i < jr.length(); i++) {
                                    JSONObject jo = jr.getJSONObject(i);
                                    if (!(jo.has("md5") && jo.has("size") && jo.has("name"))) {
                                        showSvrDllVersionErrorMessage();
                                    } else {
                                        parseSetting(jo);
                                    }

                                }
                            }else
                                showSvrDllVersionErrorMessage();

                        }catch (Exception e) {
                            e.printStackTrace();
                            Log.e(logTag, "解析 补丁 版本文件失败：" + e.toString());
                            showSvrDllVersionErrorMessage();
                        }
                    }
                }
            });
        }catch (Exception e)
        {
            showCustomedMessage(e.toString());
        }
    }

    private void showCustomedMessage(final String msg)
    {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
                builder.setTitle(R.string.update_error_title);
                builder.setMessage(msg);
                builder.setPositiveButton(getString(R.string.update_error_ok_text), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        System.exit(0);
                    }
                });
                builder.setCancelable(false);
                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
    }



    private  String getTextFileContent(File file)
    {
        String content = "";
        if (!file.isDirectory()) {  //检查此路径名的文件是否是一个目录(文件夹)
            try {
                InputStream instream = new FileInputStream(file);
                if (instream != null) {
                    InputStreamReader inputreader = new InputStreamReader(instream, "UTF-8");
                    BufferedReader buffreader = new BufferedReader(inputreader);
                    String line = "";
                    while ((line = buffreader.readLine()) != null) {
                        content += line;
                    }
                    instream.close();//关闭输入流
                }
            } catch (java.io.FileNotFoundException e) {
                Log.i(logTag,".gMD5文件不存在");
            } catch (IOException e) {
                Log.i(logTag,"读取 .gMD5 文件出现异常 " + e.getMessage());
            }
        }
        return content;
    }

    private void writeTextFile(String content,String filePath, String fileName)
    {
        makeFilePath(filePath, fileName);
        String strFilePath = filePath + fileName;
        String strContent = content + "\r\n";
        try {
            File file = new File(strFilePath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                file.createNewFile();
            }
            RandomAccessFile raf = new RandomAccessFile(file, "rwd");
            raf.seek(file.length());
            raf.write(strContent.getBytes());
            raf.close();
        } catch (Exception e) {
            Log.e(logTag, "写入" + fileName + "文件错误");
        }
    }

    private File makeFilePath(String filePath, String fileName) {
        File file = null;
        makeRootDirectory(filePath);
        try {
            file = new File(filePath + fileName);
            if (!file.exists()) {
                file.createNewFile();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return file;
    }

    private static void makeRootDirectory(String filePath) {
        File file = null;
        try {
            file = new File(filePath);
            if (!file.exists()) {
                file.mkdir();
            }
        } catch (Exception e) {
            Log.i("error:", e + "");
        }
    }

    /**
     * 检测是否需要热更
     * 1、如果是更新dll 则先检测dll文件是否存在
     *    如果是IL2CPP则先检测hu目录是否存在 ==> 检测.gflag文件是否存在 ==> 检测libil2cpp.so是否存在
     * 2、检测.gMD5文件是否存在
     * @param svrMD5Value
     * @return
     */
    private Boolean CheckNeedUpdate(String svrMD5Value) {
        String dllSavePath = cachedPath + "/";
        if(isDllMode){
            dllSavePath = "Bundles/Android/";
        }
        //以.作为名字

        if(isDllMode){
            File dllFile = new File(dllSavePath + "Assembly-CSharp.dll");
            if(dllFile.exists() == false){
                return true;
            }
        }else{
            //
            File huFile = new File(dllSavePath + "hu");
            if(!huFile.exists()){
                return true;
            }
            File flagFile = new File(dllSavePath + "hu/" + huFlagFileName);
            if(!flagFile.exists()){
                //标记文件不存在说明解压失败(玩家主动退出、异常等)
                deleteDir(dllSavePath + "hu");
                return true;
            }

//            huFile = new File(dllSavePath + "hu/assets_bin_Data");
//            if(!huFile.exists()){
//                return true;
//            }
            huFile = new File(dllSavePath + "hu/libil2cpp.so");
            if(!huFile.exists()){
                return true;
            }
        }

        String dllMD5Path = dllSavePath +  dllMD5SaveFileName;
        File MD5File = new File(dllMD5Path);
        if (MD5File.exists()) {
            //MD5校验
            //读取本地记录的MD5值
            String localMD5Str = getTextFileContent(MD5File);
            if (localMD5Str.isEmpty()) {
                return true;
            }
            if (!svrMD5Value.equals(localMD5Str)) {
                return true;
            }
        }
        return false;
    }


    /**
     * 解析配置文件
     *
     * @param Setting
     */
    private void parseSetting(JSONObject Setting) {
        try {
            JSONObject jo = Setting;
            String svrMD5Value = jo.getString("md5");
            int strSize=jo.getInt("size");
            String fileName = jo.getString("name");
            if(!fileName.equals("Assembly-CSharp.dll") && !fileName.equals("hu.bin")){
                showCDNErrorMessage();
                return;
            }

            String dllSavePath = cachedPath + "/";
            if(fileName.equals("Assembly-CSharp.dll")){
                isDllMode = true;
            }
            if(isDllMode){
                dllSavePath = "Bundles/Android/";
            }

            if(CheckNeedUpdate(svrMD5Value)){
                String url = GetDownloadUrl(fileName);
                Log.e(logTag, "下载 补丁 中...");
                downloadDLL(url, dllSavePath, fileName, svrMD5Value);
            }else{
                Log.e(logTag, "无需下载 补丁,直接进入游戏");
                OnPreEnterGame();
            }
//            //以.作为名字
//            String dllMD5Path = dllSavePath +  dllMD5FileName;
//            File MD5File = new File(dllMD5Path);
//            String url = cdnPath + "/" + fileName;
//            File f = new File(dllSavePath + fileName);
//            if (f.exists() && MD5File.exists()) {
//                //MD5校验
//                //读取本地记录的MD5值
//                String localMD5Str = getTextFileContent(MD5File);
//                Boolean isNeedDownDll = false;
//                if(localMD5Str.isEmpty())
//                {
//                    isNeedDownDll = true;
//                }
//                long localMD5Value = Long.parseLong(localMD5Str);
//                if(svrMD5Value != localMD5Value){
//                    isNeedDownDll = true;
//                }
//                if(isNeedDownDll)
//                {
//                    Log.e(logTag, "下载 补丁 中...");
//                    downloadDLL(url, dllSavePath, fileName, Long.toString(svrMD5Value));
//                }else
//                {
//                    Log.e(logTag, "无需下载 补丁,直接进入游戏");
//                    OnPreEnterGame();
//                    //enterGameNoUpdate();
//                }
//            } else {
//                //直接下载
//                Log.e(logTag, "下载 补丁 中...");
//                downloadDLL(url, dllSavePath, fileName,Long.toString(svrMD5Value));
//            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(logTag, "解析取 补丁 文件失败：" + e.toString());
            showParseErrorMessage();
        }
    }
    /**
     * 下载dll
     *
     * @param url
     * @param savedPath
     */
    private void downloadDLL(final String url, final String savedPath, final String fileName, final String MD5Str) {
        Log.i(logTag,"写入 补丁 文件 : " + savedPath + fileName+" from:"+url);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                labTip.setText(R.string.update_update);
            }
        });
        File f = new File(savedPath);
        if (f.exists()) {
            f.delete();
        }
        Boolean result = f.mkdirs();
        Log.i(logTag,"创建目录：" + f.getPath());
        if(result)
        {
            Log.i(logTag,"创建目录：" + savedPath);
        }
        OkHttpClient okHttpClient = new OkHttpClient();
        Request request = new Request.Builder().url(url).build();
        okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                OnDllDownloadFailed();
            }
            @Override
            public void onResponse(Call call, Response response) throws IOException {
                if (response.code() == 404) {
                    OnDllDownloadFailed();
                } else {
                    InputStream inputStream = null;
                    byte[] buf = new byte[2048];
                    int len;
                    long sum = 0;
                    long total = response.body().contentLength();
                    File file = new File(savedPath + fileName);
                    FileOutputStream fos = null;
                    try {
                        inputStream = response.body().byteStream();
                        fos = new FileOutputStream(file);
                        while ((len = inputStream.read(buf)) != -1) {
                            fos.write(buf, 0, len);
                            sum += len;
                            int progress = (int) (sum * 1.0f / total * 100);
                            OnDllDownloading(progress);
                        }
                        fos.flush();
                        OnDllDownloadSucess();
                        File MD5File = new File(savedPath + dllMD5SaveFileName);
                        if(MD5File.exists())
                        {
                            MD5File.delete();
                        }
                        writeTextFile(MD5Str,savedPath, dllMD5SaveFileName);
                        Log.e(logTag,"写入 补丁 版本文件成功");
                        inputStream.close();
                    } catch (Exception e) {
                        OnDllDownloadFailed();
                    } finally {
                        if (null != inputStream)
                            inputStream.close();
                        if (null != fos)
                            fos.close();
                        if (sum < total) {
                            if (file.exists()){
                                file.delete();
                            }
                        }
                    }
                }
                response.close();
            }
        });
    }

    private void OnDllDownloading(final int progress) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                labTip.setText("游戏校验中"+String.valueOf(progress)+"%");
            }
        });
    }

    private void OnDllDownloadSucess() {
        Log.e("下载进度", "下载成功进入游戏");
        OnPreEnterGame();
        //enterGame();
    }

    private boolean CopyFileFromTo(String fromPath,String toPath){
        try {
            InputStream fosfrom = new FileInputStream(fromPath);
            OutputStream fosto = new FileOutputStream(toPath);
            byte bt[] = new byte[1024];
            int c;
            while ((c = fosfrom.read(bt)) > 0) {
                fosto.write(bt, 0, c);
            }
            fosfrom.close();
            fosto.close();
            return true;

        } catch (Exception ex) {
            return false;
        }
    }



    //将旧的hu文件夹改名为tmp，等解压完成后再替换
    private void OnPreUnzipBinData() {
        final String ZipOutPath = cachedPath + "/hu";
        File huFile = new File(ZipOutPath);
        if(huFile.exists()){
            File flagFile = new File(ZipOutPath + "/" + huFlagFileName);
            if(!flagFile.exists()){//说明上次的解压缩没有成功
                Log.i(logTag,"存在hu文件夹但不存在标记文件，说明上次解压失败");
                deleteDir(ZipOutPath);
                return;
            }
            final String huTempPath = ZipOutPath + "_tmp";
            File tmpHuFile = new File(huTempPath);
            huFile.renameTo(tmpHuFile);
        }
    }

    private void OnPostUnzipBinData(){
        final String ZipOutPath = cachedPath + "/hu/assets_bin_Data";
        final String huTempBinPath = cachedPath + "/hu_tmp/assets_bin_Data";
        File tmpHuFile = new File(huTempBinPath);
        File huFile = new File(ZipOutPath);
        if(!huFile.exists()){
            huFile.mkdirs();
        }
        if(tmpHuFile.exists()){
            File[] tmpFiles = tmpHuFile.listFiles();
            File[] huFiles = null;
            if(huFile.exists()){
                huFiles = huFile.listFiles();
            }

            for (int i = 0; i < tmpFiles.length; i ++){
                boolean needCopy = true;
                String name = tmpFiles[i].getName();
                Log.i(logTag,"name ：" +  name);
                if(name.contains(".entries_header.data") || name.contains(".patch.data")){
                    continue;
                }

                if(huFiles != null){
                    for (int j = 0; j < huFiles.length; j ++){
                        if(huFiles[j].getName().equals(tmpFiles[i].getName())){
                            needCopy = false;
                            break;
                        }
                    }
                }

                if(needCopy){
                    String toPath = ZipOutPath + "/" + tmpFiles[i].getName();
                    Log.i(logTag,"移动 ：" +  toPath);
                    CopyFileFromTo(tmpFiles[i].getPath(),toPath);
                }
            }
        }
        deleteDir(cachedPath + "/hu_tmp");
    }

    private ExecutorService mExecutor;
    private void OnPreEnterGame() {
        ///如果有hu.bin文件则先进行解压缩,解压方式为7z
        final String ZipPath=  cachedPath + "/hu.bin";
        File file = new File(ZipPath);
        if(file.exists()){
            final String ZipOutPath = cachedPath + "/hu";
            OnPreUnzipBinData();
            mExecutor = Executors.newSingleThreadExecutor();
            mExecutor.submit(new Runnable() {
                @Override
                public void run() {
                    Z7Extractor.extractFile(ZipPath, ZipOutPath, new UnzipCallback() {
                        @Override
                        public void onProgress(String name, long size) {
                            //super.onProgress(name, size);
                        }

                        @Override
                        public void onSucceed() {
                            Log.i(logTag,"解压hu.bin成功");
                            //解压成功写入标记文件
                            String flagFilePath = cachedPath + "/hu/" + huFlagFileName;
                            File flagFile = new File(flagFilePath);
                            if(!flagFile.exists()){
                                try {
                                    Log.i(logTag,"写入flag文件：" + flagFilePath);
                                    flagFile.createNewFile();
                                    Log.i(logTag,flagFilePath + "写入成功");
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            }
                            //这一步要删除Unity的缓存目录il2cpp
                            final String unityCache = cachedPath + "/il2cpp";
                            deleteDir(unityCache);
                            OnPostUnzipBinData();
                            enterGame();
                        }

                        @Override
                        public void onError(int errorCode, String message) {
                            //这里如果失败了，也让它进游戏
                            enterGame();
                            //showParseErrorMessage();
                        }
                    });
                }
            });
        }else{
            enterGame();
        }
    }

    private void deleteDirWihtFile(File dir){
        if(dir != null && dir.isFile()){
            dir.delete();
            return;
        }
        if (dir == null || !dir.exists() || !dir.isDirectory())
            return;
        for (File file : dir.listFiles()) {
            if (file.isFile())
                file.delete(); // 删除所有文件
            else if (file.isDirectory())
                deleteDirWihtFile(file); // 递规的方式删除文件夹
        }
        dir.delete();// 删除目录本身
    }


    private void deleteDir(final String path){
        File dir = new File(path);
        deleteDirWihtFile(dir);
    }

    private void OnDllDownloadFailed() {
        showDownloadDLLErrorMessage();
    }

    public static int bytesToInt(byte[] src, int offset) {
        int value;
        value = ((src[offset] & 0xFF)
                | ((src[offset + 1] & 0xFF) << 8)
                | ((src[offset + 2] & 0xFF) << 16)
                | ((src[offset + 3] & 0xFF) << 24));
        return value;
    }

    private void enterGameNoUpdate() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //getApplication().getApplicationContext().getFilesDir().getPath()
                //getApplication().getExternalFilesDir("").toString()
                Boostrap.InitNativeLibBeforeUnityPlay(getApplication().getApplicationContext().getFilesDir().getPath(),getApplication().getExternalFilesDir("").toString());
                final Handler handler = new Handler();
                runnable = new Runnable() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        handler.removeCallbacks(runnable);
                        Intent intent = new Intent(UpdateActivity.this, QKUnityPlayerActivity.class);
                        startActivity(intent);
                        UpdateActivity.this.overridePendingTransition(0, 0);
                        finish();
                    }
                };
                handler.postDelayed(runnable, 1500);
            }
        });
    }

    /**
     * 进入Unity
     */
    private void enterGame() {
        Log.i(logTag ,"enterGame");

        //走到这里标识hu.bin已经解压完成,删除hu.bin
        final String huBinPath = cachedPath + "/hu.bin";
        deleteDir(huBinPath);

        //IL2cpp下传递hook目录
        if(isDllMode == false){
            Boostrap.InitNativeLibBeforeUnityPlay(getApplication().getApplicationContext().getFilesDir().getPath(),cachedPath);
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(UpdateActivity.this, QKUnityPlayerActivity.class);
                startActivity(intent);
                UpdateActivity.this.overridePendingTransition(0, 0);
                finish();
            }
        });
    }

    /**
     * 获取CDN地址失败提示
     */
    private void showCDNErrorMessage() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
                builder.setTitle(R.string.update_error_title);
                builder.setMessage(R.string.update_error_content);
                builder.setPositiveButton(getString(R.string.update_error_ok_text), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        System.exit(0);
                    }
                });
                builder.setCancelable(false);
                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
    }

    /**
     * dll下载失败提示
     */
    private void showDownloadDLLErrorMessage() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
                builder.setTitle(R.string.update_error_title);
                builder.setMessage(R.string.update_error_download_dll);
                builder.setPositiveButton(getString(R.string.update_error_ok_text), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        System.exit(0);
                    }
                });
                builder.setCancelable(false);
                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
    }

    private void showSvrDllVersionErrorMessage()
    {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
                builder.setTitle(R.string.update_error_title);
                builder.setMessage(R.string.svrDllVersionError);
                //点击退出游戏
                builder.setPositiveButton(getString(R.string.update_error_ok_text), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        System.exit(0);
                    }
                });
                builder.setCancelable(false);
                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
    }

private void showConfigCDNMessage()
{
    runOnUiThread(new Runnable() {
        @Override
        public void run() {
            AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
            builder.setTitle(R.string.update_error_title);
            builder.setMessage(R.string.cdnNotConfiged);
            //点击退出游戏
            builder.setPositiveButton(getString(R.string.update_error_ok_text), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    System.exit(0);
                }
            });
            builder.setCancelable(false);
            AlertDialog dlg = builder.create();
            dlg.show();
        }
    });
}

    /**
     *  配置文件解析失败提示
     */
    private void showParseErrorMessage() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AlertDialog.Builder builder = new AlertDialog.Builder(UpdateActivity.this);
                builder.setTitle(R.string.update_error_title);
                builder.setMessage(R.string.parseError);
                //点击退出游戏
                builder.setNegativeButton(getString(R.string.update_error_ok_text), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        System.exit(0);
                    }
                });

                //点击修复游戏
                builder.setPositiveButton(getString(R.string.fixgame_text), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        String dllSavePath = cachedPath + "/Bundles/Android/";
                        deleteFolder(dllSavePath);
                        if(isDllMode == false){
                            final String unityCache = cachedPath + "/il2cpp";
                            deleteDir(unityCache);
                            final String ZipOutPath = cachedPath + "/hu";
                            deleteDir(ZipOutPath);
                        }
                        //重置errorNums并再次请求cdn
                        errorNums = 0;
                        getCDN();
                    }
                });
                AlertDialog dlg = builder.create();
                dlg.show();
            }
        });
    }

    private void deleteFolder(String folderPath)
    {
        try {
            delAllFile(folderPath); // 删除完里面所有内容
            String filePath = folderPath;
            filePath = filePath.toString();
            java.io.File myFilePath = new java.io.File(filePath);
            myFilePath.delete(); // 删除空文件夹
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private boolean delAllFile(String path) {
        boolean flag = false;
        File file = new File(path);
        if (!file.exists()) {
            return flag;
        }
        if (!file.isDirectory()) {
            return flag;
        }
        String[] tempList = file.list();
        File temp = null;
        for (int i = 0; i < tempList.length; i++) {
            if (path.endsWith(File.separator)) {
                temp = new File(path + tempList[i]);
            } else {
                temp = new File(path + File.separator + tempList[i]);
            }
            if (temp.isFile()) {
                temp.delete();
            }
            if (temp.isDirectory()) {
                delAllFile(path + "/" + tempList[i]);// 先删除文件夹里面的文件
                deleteFolder(path + "/" + tempList[i]);// 再删除空文件夹
                flag = true;
            }
        }
        return flag;
    }

    // 上报日志文件
    private void reportOutLog()
    {

    }

    private String GetCPUABI(){
        String cpu_abi="";
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            cpu_abi = Build.CPU_ABI;
        } else {
            cpu_abi = Build.SUPPORTED_ABIS[0];
        }
        Log.i(logTag,cpu_abi);
        return cpu_abi;
    }

    private  void  ClearOldPatch(){
        if(isDllMode == false){
            final String unityCache = cachedPath + "/il2cpp";
            deleteDir(unityCache);
            final String ZipOutPath = cachedPath + "/hu";
            deleteDir(ZipOutPath);


            File md5= new File(cachedPath+"/hu.gMD5");
            if(md5.exists())
                md5.delete();
        }
    }
}
