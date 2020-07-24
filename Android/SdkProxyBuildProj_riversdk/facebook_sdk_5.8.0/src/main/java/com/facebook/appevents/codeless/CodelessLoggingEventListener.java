/*
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

package com.facebook.appevents.codeless;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.RestrictTo;
import android.view.View;
import android.widget.AdapterView;

import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsConstants;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.appevents.codeless.internal.Constants;
import com.facebook.appevents.codeless.internal.EventBinding;
import com.facebook.appevents.codeless.internal.ViewHierarchy;
import com.facebook.appevents.internal.AppEventUtility;

import java.lang.ref.WeakReference;

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class CodelessLoggingEventListener {
    private static final String TAG = CodelessLoggingEventListener.class.getCanonicalName();

    public static AutoLoggingOnClickListener
    getOnClickListener(EventBinding mapping, View rootView, View hostView) {
        return new AutoLoggingOnClickListener(mapping, rootView, hostView);
    }

    public static AutoLoggingOnItemClickListener
    getOnItemClickListener(EventBinding mapping, View rootView, AdapterView hostView) {
        return new AutoLoggingOnItemClickListener(mapping, rootView, hostView);
    }

    private static void logEvent(final EventBinding mapping,
                                 final View rootView,
                                 final View hostView) {
        final String eventName = mapping.getEventName();
        final Bundle parameters = CodelessMatcher.getParameters(
                mapping,
                rootView,
                hostView);

        if (parameters.containsKey(AppEventsConstants.EVENT_PARAM_VALUE_TO_SUM)) {
            String value = parameters.getString(AppEventsConstants.EVENT_PARAM_VALUE_TO_SUM);
            parameters.putDouble(
                    AppEventsConstants.EVENT_PARAM_VALUE_TO_SUM,
                    AppEventUtility.normalizePrice(value));
        }

        parameters.putString(Constants.IS_CODELESS_EVENT_KEY, "1");

        FacebookSdk.getExecutor().execute(new Runnable() {
            @Override
            public void run() {
                final Context context = FacebookSdk.getApplicationContext();
                final AppEventsLogger appEventsLogger = AppEventsLogger.newLogger(context);
                appEventsLogger.logEvent(eventName, parameters);
            }
        });
    }

    public static class AutoLoggingOnClickListener implements View.OnClickListener {

        private AutoLoggingOnClickListener(final EventBinding mapping,
                                          final View rootView,
                                          final View hostView) {
            if (null == mapping || null == rootView || null == hostView) {
                return;
            }

            this.existingOnClickListener = ViewHierarchy.getExistingOnClickListener(hostView);

            this.mapping = mapping;
            this.hostView = new WeakReference<View>(hostView);
            this.rootView = new WeakReference<View>(rootView);
            supportCodelessLogging = true;
        }

        @Override
        public void onClick(View view) {
            // If there is an existing listener and its not the one of AutoLoggingOnClickListener
            // then call its onClick function
            if (this.existingOnClickListener != null) {
                this.existingOnClickListener.onClick(view);
            }
            if (rootView.get() != null && hostView.get() != null) {
                logEvent(mapping, rootView.get(), hostView.get());
            }
        }

        public boolean getSupportCodelessLogging() {
            return supportCodelessLogging;
        }

        private EventBinding mapping;
        private WeakReference<View> hostView;
        private WeakReference<View> rootView;
        @Nullable private View.OnClickListener existingOnClickListener;
        private boolean supportCodelessLogging = false;
    }

    public static class AutoLoggingOnItemClickListener implements AdapterView.OnItemClickListener {

        private AutoLoggingOnItemClickListener(final EventBinding mapping,
                                           final View rootView,
                                           final AdapterView hostView) {
            if (null == mapping || null == rootView || null == hostView) {
                return;
            }

            this.existingOnItemClickListener = hostView.getOnItemClickListener();

            this.mapping = mapping;
            this.hostView = new WeakReference<AdapterView>(hostView);
            this.rootView = new WeakReference<View>(rootView);
            supportCodelessLogging = true;
        }

        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            if (this.existingOnItemClickListener != null) {
                this.existingOnItemClickListener.onItemClick(parent, view, position, id);
            }
            if (rootView.get()!=null && hostView.get()!=null) {
                logEvent(mapping, rootView.get(), hostView.get());
            }
        }

        public boolean getSupportCodelessLogging() {
            return supportCodelessLogging;
        }

        private EventBinding mapping;
        private WeakReference<AdapterView> hostView;
        private WeakReference<View> rootView;
        @Nullable private AdapterView.OnItemClickListener existingOnItemClickListener;
        private boolean supportCodelessLogging = false;
    }
}
