package qksdkproxy.Utility;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;

/**
 * Created by wg on 2018/5/13.
 */
public class QKWebActivity extends Activity
{
    public static void showWeb(Context context, String url, boolean isLandscape) {
        Log.e("unitylog","QKWebActivity.showWeb()....url=" + url);
        Intent intent = new Intent(context,QKWebActivity.class);
        intent.putExtra("url",url);
        intent.putExtra("isLandscape",isLandscape);
        context.startActivity(intent);
    }

    RelativeLayout container;
    private WebView webView;
    //private Button btnClose;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        container = new RelativeLayout(this);
        webView = new WebView(this);
        container.addView(webView);

        WebSettings s = webView.getSettings();
        s.setUserAgentString("shangjin_okwan_android");
        s.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
        //        s.setUseWideViewPort(true);
        s.setLoadWithOverviewMode(true);
        s.setJavaScriptEnabled(true);
//        s.setSupportZoom(true); // 支持缩放


//        btnClose = new Button(this);
//        btnClose.setText("退出");
        //container.addView(btnClose);
        this.setContentView(container);

//        btnClose.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                QKWebActivity.this.finish();
//            }
//        });

        SetData();
    }

    public void SetData()
    {
        String urlstr = getIntent().getStringExtra("url");
        boolean isLandscape = getIntent().getBooleanExtra("isLandscape", true);
        if(isLandscape)
        {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }
        else
        {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
        webView.loadUrl(urlstr);
//        webView.loadUrl("http://www.baidu.com");
        Log.e("unitylog","获取的URL为：" + urlstr);
        webView.setWebViewClient(new WebViewClient()
        {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                webView.loadUrl(url);
                return true;
            }
        });
    }






}