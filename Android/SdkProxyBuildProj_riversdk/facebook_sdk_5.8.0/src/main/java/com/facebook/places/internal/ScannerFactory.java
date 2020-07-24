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

package com.facebook.places.internal;

import android.content.Context;
import android.os.Build;

/**
 * com.facebook.places.internal is solely for the use of other packages within the
 * Facebook SDK for Android. Use of any of the classes in this package is
 * unsupported, and they may be modified or removed without warning at any time.
 */
public class ScannerFactory {

    public static final int OS_VERSION_LOLLIPOP = 21;
    public static final int OS_VERSION_JELLY_BEAN_MR2 = 18;
    public static final int OS_VERSION_JELLY_BEAN_MR1 = 17;

    public static BleScanner newBleScanner(Context context, LocationPackageRequestParams params) {
        if (Build.VERSION.SDK_INT >= OS_VERSION_LOLLIPOP) {
            return new BleScannerImpl(context, params);
        }
        return new BleScannerLegacy();
    }

    public static WifiScanner newWifiScanner(Context context, LocationPackageRequestParams params) {
        return new WifiScannerImpl(context, params);
    }

    public static LocationScanner newLocationScanner(
            Context context,
            LocationPackageRequestParams params) {
        return new LocationScannerImpl(context, params);
    }
}
