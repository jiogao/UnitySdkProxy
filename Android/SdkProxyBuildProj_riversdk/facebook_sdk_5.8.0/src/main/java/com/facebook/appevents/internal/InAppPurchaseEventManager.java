/**
 * Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
 *
 * You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 * copy, modify, and distribute this software in source code or binary form for use
 * in connection with the web services and APIs provided by Facebook.
 *
 * As with any software that integrates with the Facebook platform, your use of
 * this software is subject to the Facebook Developer Principles and Policies
 * [http://developers.facebook.com/policy/]. This copyright notice shall be
 * included in all copies or substantial portions of the software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package com.facebook.appevents.internal;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.FacebookSdk;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

class InAppPurchaseEventManager {
    private static final String TAG =
            InAppPurchaseEventManager.class.getCanonicalName();

    private static final HashMap<String, Method> methodMap =
            new HashMap<>();
    private static final HashMap<String, Class<?>> classMap =
            new HashMap<>();

    private static final int CACHE_CLEAR_TIME_LIMIT_SEC = 7 * 24 * 60 * 60; // 7 days

    // Sku detail cache setting
    private static final int SKU_DETAIL_EXPIRE_TIME_SEC = 12 * 60 * 60; // 12 h

    // Purchase types
    private static final String SUBSCRIPTION = "subs";
    private static final String INAPP = "inapp";

    // Purchase setting
    private static final int PURCHASE_EXPIRE_TIME_SEC = 24 * 60 * 60; // 24 h
    private static final int PURCHASE_STOP_QUERY_TIME_SEC = 20 * 60; // 20 min
    private static final int MAX_QUERY_PURCHASE_NUM = 30;

    // Class names
    private static final String IN_APP_BILLING_SERVICE_STUB =
            "com.android.vending.billing.IInAppBillingService$Stub";
    private static final String IN_APP_BILLING_SERVICE =
            "com.android.vending.billing.IInAppBillingService";

    // Method names
    private static final String AS_INTERFACE = "asInterface";
    private static final String GET_SKU_DETAILS = "getSkuDetails";
    private static final String GET_PURCHASES = "getPurchases";
    private static final String GET_PURCHASE_HISTORY = "getPurchaseHistory";
    private static final String IS_BILLING_SUPPORTED = "isBillingSupported";

    // Other names
    private static final String ITEM_ID_LIST = "ITEM_ID_LIST";
    private static final String RESPONSE_CODE = "RESPONSE_CODE";
    private static final String DETAILS_LIST = "DETAILS_LIST";
    private static final String INAPP_PURCHASE_DATA_LIST = "INAPP_PURCHASE_DATA_LIST";
    private static final String INAPP_CONTINUATION_TOKEN = "INAPP_CONTINUATION_TOKEN";
    private static final String LAST_CLEARED_TIME = "LAST_CLEARED_TIME";
    private static final String PACKAGE_NAME =
            FacebookSdk.getApplicationContext().getPackageName();

    private static final String SKU_DETAILS_STORE =
            "com.facebook.internal.SKU_DETAILS";
    private static final String PURCHASE_INAPP_STORE =
            "com.facebook.internal.PURCHASE";
    private static final SharedPreferences skuDetailSharedPrefs =
            FacebookSdk.getApplicationContext().getSharedPreferences(
                    SKU_DETAILS_STORE,
                    Context.MODE_PRIVATE);
    private static final SharedPreferences purchaseInappSharedPrefs =
            FacebookSdk.getApplicationContext().getSharedPreferences(
                    PURCHASE_INAPP_STORE,
                    Context.MODE_PRIVATE);

    @Nullable
    static Object asInterface(Context context, IBinder service) {
        Object[] args = new Object[] {service};
        return invokeMethod(context, IN_APP_BILLING_SERVICE_STUB,
                AS_INTERFACE, null, args);
    }

    static Map<String, String> getSkuDetails(
            Context context, ArrayList<String> skuList,
            Object inAppBillingObj, boolean isSubscription) {

        Map<String, String> skuDetailsMap = readSkuDetailsFromCache(skuList);

        ArrayList<String> unresolvedSkuList = new ArrayList<>();
        for (String sku : skuList) {
            if (!skuDetailsMap.containsKey(sku)) {
                unresolvedSkuList.add(sku);
            }
        }

        skuDetailsMap.putAll(getSkuDetailsFromGoogle(
                context, unresolvedSkuList, inAppBillingObj, isSubscription));

        return skuDetailsMap;
    }

    private static Map<String, String> getSkuDetailsFromGoogle(
            Context context, ArrayList<String> skuList,
            Object inAppBillingObj, boolean isSubscription) {

        Map<String, String> skuDetailsMap = new HashMap<>();

        if (inAppBillingObj == null || skuList.isEmpty()) {
            return skuDetailsMap;
        }

        Bundle querySkus = new Bundle();
        querySkus.putStringArrayList(ITEM_ID_LIST, skuList);
        Object[] args = new Object[] {
                3, PACKAGE_NAME, isSubscription ? SUBSCRIPTION : INAPP, querySkus};

        Object result = invokeMethod(context, IN_APP_BILLING_SERVICE,
                GET_SKU_DETAILS, inAppBillingObj, args);

        if (result != null) {
            Bundle bundle = (Bundle) result;
            int response = bundle.getInt(RESPONSE_CODE);
            if (response == 0) {
                ArrayList<String> skuDetailsList = bundle.getStringArrayList(DETAILS_LIST);
                if (skuDetailsList != null && skuList.size() == skuDetailsList.size()) {
                    for (int i = 0; i < skuList.size(); i++) {
                        skuDetailsMap.put(skuList.get(i), skuDetailsList.get(i));
                    }
                }

                writeSkuDetailsToCache(skuDetailsMap);
            }
        }

        return skuDetailsMap;
    }

    private static Map<String, String> readSkuDetailsFromCache(
            ArrayList<String> skuList) {

        Map<String, String> skuDetailsMap = new HashMap<>();
        long nowSec = System.currentTimeMillis() / 1000L;

        for (String sku : skuList) {
            String rawString = skuDetailSharedPrefs.getString(sku, null);
            if (rawString != null) {
                String[] splitted = rawString.split(";", 2);
                long timeSec = Long.parseLong(splitted[0]);
                if (nowSec - timeSec < SKU_DETAIL_EXPIRE_TIME_SEC) {
                    skuDetailsMap.put(sku, splitted[1]);
                }
            }
        }

        return skuDetailsMap;
    }

    private static void writeSkuDetailsToCache(Map<String, String> skuDetailsMap) {
        long nowSec = System.currentTimeMillis() / 1000L;

        SharedPreferences.Editor editor = skuDetailSharedPrefs.edit();
        for (Map.Entry<String, String> pair : skuDetailsMap.entrySet()) {
            editor.putString(pair.getKey(), nowSec + ";" + pair.getValue());
        }

        editor.apply();
    }

    private static Boolean isBillingSupported(Context context,
                                             Object inAppBillingObj, String type) {

        if (inAppBillingObj == null) {
            return false;
        }

        Object[] args = new Object[] {3, PACKAGE_NAME, type};
        Object result = invokeMethod(context, IN_APP_BILLING_SERVICE,
                IS_BILLING_SUPPORTED, inAppBillingObj, args);

        return result != null && ((int) result) == 0;
    }

    static ArrayList<String> getPurchasesInapp(Context context, Object inAppBillingObj) {
        return filterPurchases(getPurchases(context, inAppBillingObj, INAPP));
    }

    static ArrayList<String> getPurchasesSubs(Context context, Object inAppBillingObj) {
        return filterPurchases(getPurchases(context, inAppBillingObj, SUBSCRIPTION));
    }

    private static ArrayList<String> getPurchases(Context context,
                                                  Object inAppBillingObj,
                                                  String type) {
        ArrayList<String> purchases = new ArrayList<>();

        if (inAppBillingObj == null) {
            return purchases;
        }

        if (isBillingSupported(context, inAppBillingObj, type)) {

            String continuationToken = null;
            int queriedPurchaseNum = 0;

            do {
                Object[] args = new Object[] {3, PACKAGE_NAME, type, continuationToken};
                Object result = invokeMethod(context, IN_APP_BILLING_SERVICE,
                        GET_PURCHASES, inAppBillingObj, args);

                continuationToken = null;

                if (result != null) {
                    Bundle purchaseDetails = (Bundle) result;
                    int response = purchaseDetails.getInt(RESPONSE_CODE);
                    if (response == 0) {
                        ArrayList<String> details =
                                purchaseDetails.getStringArrayList(INAPP_PURCHASE_DATA_LIST);
                        if (details != null) {
                            queriedPurchaseNum += details.size();
                            purchases.addAll(details);
                            continuationToken = purchaseDetails.getString(INAPP_CONTINUATION_TOKEN);
                        } else {
                            break;
                        }
                    }
                }
            } while (queriedPurchaseNum < MAX_QUERY_PURCHASE_NUM
                    && continuationToken != null);
        }

        return purchases;
    }

    static boolean hasFreeTrialPeirod(String skuDetail) {
        try {
            JSONObject skuDetailsJSON = new JSONObject(skuDetail);
            String freeTrialPeriod = skuDetailsJSON.optString("freeTrialPeriod");
            return freeTrialPeriod != null && !freeTrialPeriod.isEmpty();
        } catch (JSONException e) {/*no op*/}
        return false;
    }

    static ArrayList<String> getPurchaseHistoryInapp(Context context,
                                                            Object inAppBillingObj) {
        ArrayList<String> purchases = new ArrayList<>();

        if (inAppBillingObj == null) {
            return purchases;
        }

        Class<?> iapClass = getClass(context, IN_APP_BILLING_SERVICE);
        if (iapClass == null) {
            return purchases;
        }

        Method method = getMethod(iapClass, GET_PURCHASE_HISTORY);
        if (method == null) {
            return purchases;
        }

        purchases = getPurchaseHistory(context, inAppBillingObj, INAPP);

        return filterPurchases(purchases);
    }

    private static ArrayList<String> getPurchaseHistory(Context context,
                                                        Object inAppBillingObj,
                                                        String type) {

        ArrayList<String> purchases = new ArrayList<>();

        if (isBillingSupported(context, inAppBillingObj, type)) {
            String continuationToken = null;
            int queriedPurchaseNum = 0;
            boolean reachTimeLimit = false;

            do {
                Object[] args = new Object[] {
                        6, PACKAGE_NAME, type, continuationToken, new Bundle()};
                continuationToken = null;

                Object result = invokeMethod(context, IN_APP_BILLING_SERVICE,
                        GET_PURCHASE_HISTORY, inAppBillingObj, args);
                if (result != null) {
                    long nowSec = System.currentTimeMillis() / 1000L;
                    Bundle purchaseDetails = (Bundle) result;
                    int response = purchaseDetails.getInt(RESPONSE_CODE);
                    if (response == 0) {
                        ArrayList<String> details =
                                purchaseDetails.getStringArrayList(INAPP_PURCHASE_DATA_LIST);
                        if (details == null) {
                            continue;
                        }

                        for (String detail : details) {
                            try {
                                JSONObject detailJSON = new JSONObject(detail);
                                long purchaseTimeSec =
                                        detailJSON.getLong("purchaseTime") / 1000L;

                                if (nowSec - purchaseTimeSec > PURCHASE_STOP_QUERY_TIME_SEC) {
                                    reachTimeLimit = true;
                                    break;
                                } else {
                                    purchases.add(detail);
                                    queriedPurchaseNum++;
                                }
                            } catch (JSONException e) {/*no op*/}
                        }

                        continuationToken = purchaseDetails.getString(INAPP_CONTINUATION_TOKEN);
                    }
                }
            } while (queriedPurchaseNum < MAX_QUERY_PURCHASE_NUM
                    && continuationToken != null
                    && !reachTimeLimit);
        }

        return purchases;
    }

    private static ArrayList<String> filterPurchases(ArrayList<String> purchases) {
        ArrayList<String> filteredPurchase = new ArrayList<>();
        SharedPreferences.Editor editor = purchaseInappSharedPrefs.edit();
        long nowSec = System.currentTimeMillis() / 1000L;
        for (String purchase : purchases) {
            try {
                JSONObject purchaseJson = new JSONObject(purchase);
                String sku = purchaseJson.getString("productId");
                long purchaseTimeMillis = purchaseJson.getLong("purchaseTime");
                String purchaseToken = purchaseJson.getString("purchaseToken");
                if (nowSec - purchaseTimeMillis / 1000L > PURCHASE_EXPIRE_TIME_SEC) {
                    continue;
                }

                String historyPurchaseToken = purchaseInappSharedPrefs.getString(sku, "");

                if (historyPurchaseToken.equals(purchaseToken)) {
                    continue;
                }

                editor.putString(sku, purchaseToken); // write new purchase into cache
                filteredPurchase.add(purchase);
            } catch (JSONException e) {/*no op*/}
        }

        editor.apply();

        return filteredPurchase;
    }

    @Nullable
    private static Method getMethod(Class<?> classObj, String methodName) {
        Method method = methodMap.get(methodName);
        if (method != null) {
            return method;
        }

        try {
            Class<?>[] paramTypes = null;
            switch (methodName) {
                case AS_INTERFACE:
                    paramTypes = new Class[] {IBinder.class};
                    break;
                case GET_SKU_DETAILS:
                    paramTypes = new Class[] {
                            Integer.TYPE, String.class, String.class, Bundle.class};
                    break;
                case IS_BILLING_SUPPORTED:
                    paramTypes = new Class[] {
                            Integer.TYPE, String.class, String.class};
                    break;
                case GET_PURCHASES:
                    paramTypes = new Class[] {
                            Integer.TYPE, String.class, String.class, String.class};
                    break;
                case GET_PURCHASE_HISTORY:
                    paramTypes = new Class[] {
                            Integer.TYPE, String.class, String.class, String.class, Bundle.class};
                    break;
            }

            method = classObj.getDeclaredMethod(methodName, paramTypes);
            methodMap.put(methodName, method);
        } catch (NoSuchMethodException e) {/*no op*/}

            return method;
    }

    @Nullable
    private static Class<?> getClass(Context context, String className) {
        Class<?> classObj = classMap.get(className);
        if (classObj != null) {
            return classObj;
        }

        try {
            classObj = context.getClassLoader().loadClass(className);
            classMap.put(className, classObj);
        } catch (ClassNotFoundException e) {/*no op*/}

        return classObj;
    }

    @Nullable
    private static Object invokeMethod(Context context, String className,
                                       String methodName, Object obj, Object[] args) {
        Class<?> classObj = getClass(context, className);
        if (classObj == null) {
            return null;
        }

        Method methodObj = getMethod(classObj, methodName);
        if (methodObj == null) {
            return null;
        }

        if (obj != null) {
            obj = classObj.cast(obj);
        }

        try {
            return methodObj.invoke(obj, args);
        } catch (IllegalAccessException e) {
        } catch (InvocationTargetException e) {
        }

        return null;
    }

    static void clearSkuDetailsCache() {
        long nowSec = System.currentTimeMillis() / 1000L;

        // Sku details cache
        long lastClearedTimeSec = skuDetailSharedPrefs.getLong(LAST_CLEARED_TIME, 0);
        if (lastClearedTimeSec == 0) {
            skuDetailSharedPrefs.edit()
                    .putLong(LAST_CLEARED_TIME, nowSec)
                    .apply();
        } else if ((nowSec - lastClearedTimeSec) > CACHE_CLEAR_TIME_LIMIT_SEC) {
            skuDetailSharedPrefs.edit()
                    .clear()
                    .putLong(LAST_CLEARED_TIME, nowSec)
                    .apply();
        }
    }
}
