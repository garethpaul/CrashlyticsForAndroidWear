package arno.di.loreto.crashlyticsforandroidwear.crashlytics;

import android.app.Application;
import android.content.Intent;
import android.util.Log;

/**
 * An UncaughtExceptinHandler to handle crash report transmission between wear watch and host device.
 * Initialize it on your main activity with CrashlyticsWear.init(this.getApplication());
 */
public class CrachlyticsWearUncaughtExceptionHandler implements Thread.UncaughtExceptionHandler {

    /**
     * The logger's name.
     */
    private static final String MYLOGGER = CrachlyticsWearUncaughtExceptionHandler.class.getName();

    /**
     * The previous default uncaught exception handler.
     */
    private Thread.UncaughtExceptionHandler mDefaultUncaughtExceptionHandler;

    /**
     * The application we're dealing with.
     */
    private Application mApplication;

    /**
     * Creates a new CrachlyticsUncaughtExceptionHandler, it sets the default uncaught exception
     * handler of the application and store the previous one.
     * @param application The application.
     */
    public CrachlyticsWearUncaughtExceptionHandler(Application application){
        mApplication = application;
        mDefaultUncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();
        if (mApplication != null) {
            Thread.setDefaultUncaughtExceptionHandler(this);
        }
    }

    /**
     * Handles uncaught exceptions. Create a CrashlyticsIntentService to send the report then call
     * the same method on the previous uncaughtExceptionHandler.
     * @param thread
     * @param ex
     */
    @Override
    public void uncaughtException(Thread thread, Throwable ex) {
        Log.e(MYLOGGER, "uncaughtException", ex);
        if (mApplication != null && ex != null) {
            //Do not forget to declare CrashlyticsWearIntentService in AndroidManifest.xml
            Intent errorIntent = new Intent(mApplication, CrashlyticsWearIntentService.class);
            errorIntent.putExtra(CrashlyticsWearIntentService.EXTRA_DATA_ERROR, ex);
            errorIntent.putExtra(CrashlyticsWearIntentService.EXTRA_DATA_REPORT_TYPE,
                    CrashlyticsWearIntentService.REPORT_TYPE_CRASH);

            mApplication.startService(errorIntent);
        }
        else {
            Log.e(MYLOGGER, "Skipping CrashlyticsWearIntentService without application and throwable");
        }
        //We call the original default uncaught exception handler
        //If we do not do that, the user won't see classic error screen
        //but you may handle this differently (to show a personalized screeen for example)
        if (mDefaultUncaughtExceptionHandler != null) {
            mDefaultUncaughtExceptionHandler.uncaughtException(thread, ex);
        }
        else {
            Log.e(MYLOGGER, "No default uncaught exception handler is available");
        }
    }

}
