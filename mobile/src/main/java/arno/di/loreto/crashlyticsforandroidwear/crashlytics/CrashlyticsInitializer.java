package arno.di.loreto.crashlyticsforandroidwear.crashlytics;

import android.content.Context;

import com.crashlytics.android.Crashlytics;

import io.fabric.sdk.android.Fabric;

public final class CrashlyticsInitializer {

    private static boolean initialized;

    private CrashlyticsInitializer() {
    }

    public static synchronized void initialize(Context context) {
        if (initialized) {
            return;
        }

        Context applicationContext = context.getApplicationContext();
        Fabric.with(applicationContext, new Crashlytics());
        initialized = true;
    }
}
