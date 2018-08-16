package qksdkproxy.Utility;

import android.util.Log;
import java.io.*;
import java.net.*;

/**
 * Created by wg on 2018/5/12.
 */
public class MyHttpURLConnect {

    public interface HttpHander {
        public void onResult(String result);
    }

    public static void doPost(final String urlstr, final String param, final HttpHander handler)
    {
        String result = "";
        new Thread() {
            @Override
            public void run() {
                PrintWriter out = null;
                BufferedReader in = null;
                String result = "";
                try {
                    Log.e("unitylog",".......param = " + param);
                    URL realUrl = new URL(urlstr);
                    // 打开和URL之间的连接
                    URLConnection conn = realUrl.openConnection();
                    HttpURLConnection httpUrlConnection = (HttpURLConnection) conn;

//                    // 设置通用的请求属性
//                    // httpUrlConnection.setRequestProperty("accept", "*/*");
//                    httpUrlConnection.setRequestProperty("connection", "Keep-Alive");
//                    httpUrlConnection.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
//                    httpUrlConnection.setRequestProperty("Content-Type","application/json;charset=UTF-8");
//                    httpUrlConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                    httpUrlConnection.setRequestMethod("POST");
                    // 发送POST请求必须设置如下两行
                    httpUrlConnection.setDoOutput(true);
                    httpUrlConnection.setDoInput(true);

                    // Post 请求不能使用缓存
                    httpUrlConnection.setUseCaches(false);

                    // 连接，从上述第2条中url.openConnection()至此的配置必须要在connect之前完成，
                    httpUrlConnection.connect();

                    OutputStream outStrm = httpUrlConnection.getOutputStream();
                    OutputStreamWriter writer = new OutputStreamWriter(outStrm,"UTF-8");
                    out = new PrintWriter(writer);
                    // 发送请求参数
                    out.print(param);
                    // flush输出流的缓冲
                    out.flush();

                    out.close();
                    int resultCode = httpUrlConnection.getResponseCode();
                    if (HttpURLConnection.HTTP_OK == resultCode)
                    {
                        StringBuffer sb = new StringBuffer();
                        String readLine = new String();
                        BufferedReader responseReader = new BufferedReader(new InputStreamReader(httpUrlConnection.getInputStream(), "UTF-8"));
                        while ((readLine = responseReader.readLine()) != null) {
                            sb.append(readLine);
                        }
                        responseReader.close();
                        result =  sb.toString();

                        handler.onResult(result);

                        Log.d("unitylog", "、、、、、、、、、、返回的数据为：" + sb.toString());
                    } else {
                        Log.e("unitylog", "55555555555555555555");
                    }
                } catch (Exception e) {
                    Log.e("unitylog", "=++++++++++++++++++++++" + e.getMessage());
                    e.printStackTrace();
                }
                //使用finally块来关闭输出流、输入流
                finally {
                    try {
                        if (out != null) {
                            out.close();
                        }
                        if (in != null) {
                            in.close();
                        }
                    } catch (IOException ex) {
                        ex.printStackTrace();
                    }
                }
            }
        }.start();
    }
}




