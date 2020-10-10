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

package com.facebook.login;

import android.content.Context;
import android.os.Bundle;

import com.facebook.internal.NativeProtocol;
import com.facebook.internal.PlatformServiceClient;

final class LoginStatusClient extends PlatformServiceClient {

    static final long DEFAULT_TOAST_DURATION_MS = 5000L;
    private final String loggerRef;
    private final String graphApiVersion;
    private final long toastDurationMs;

    LoginStatusClient(final Context context,
                      final String applicationId,
                      final String loggerRef,
                      final String graphApiVersion,
                      final long toastDurationMs) {
        super(
                context,
                NativeProtocol.MESSAGE_GET_LOGIN_STATUS_REQUEST,
                NativeProtocol.MESSAGE_GET_LOGIN_STATUS_REPLY,
                NativeProtocol.PROTOCOL_VERSION_20170411,
                applicationId);
        this.loggerRef = loggerRef;
        this.graphApiVersion = graphApiVersion;
        this.toastDurationMs = toastDurationMs;
    }

    @Override
    protected void populateRequestBundle(Bundle data) {
        data.putString(NativeProtocol.EXTRA_LOGGER_REF, loggerRef);
        data.putString(NativeProtocol.EXTRA_GRAPH_API_VERSION, graphApiVersion);
        data.putLong(NativeProtocol.EXTRA_TOAST_DURATION_MS, toastDurationMs);
    }
}
