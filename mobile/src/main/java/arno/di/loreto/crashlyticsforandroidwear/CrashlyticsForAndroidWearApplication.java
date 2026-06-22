package arno.di.loreto.crashlyticsforandroidwear;

import android.app.Application;

import arno.di.loreto.crashlyticsforandroidwear.crashlytics.CrashlyticsInitializer;

public class CrashlyticsForAndroidWearApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        CrashlyticsInitializer.initialize(this);
    }
}
