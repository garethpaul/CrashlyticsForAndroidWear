package arno.di.loreto.crashlyticsforandroidwear.crashlytics;

import android.content.Context;
import android.util.Log;

import com.crashlytics.android.Crashlytics;
import com.google.android.gms.wearable.DataMap;
import com.google.android.gms.wearable.MessageEvent;

import java.util.Iterator;

import arno.di.loreto.crashlyticsforandroidwear.wearable.WearableListenerReceiver;

/**
 * Receives message from the WearableListenerBroadcaster.
 * It will handle Crashlytics report (path PATH_CRASHLYTICS = /crashlytics).
 * Crash and Exception report are send using logException (I did not yet found a way
 * to send a real crash report)
 */
public class CrashlyticsWearableListenerReceiver extends WearableListenerReceiver {

    private static final String MYLOGGER = CrashlyticsWearableListenerReceiver.class.getName();

    /**
     * The path
     */
    public static final String PATH_CRASHLYTICS = "/crashlytics";
    public static final String DATA_MAP_ERROR = "ERROR";
    public static final String DATA_MAP_REPORT_TYPE = "REPORT_TYPE";
    public static final String CRASH_DATA_WEAR = "WEAR_REPORT";

    @Override
    public void onCreate(Context context) {
        super.onCreate(context);
        Log.d(MYLOGGER, "onCreate");
    }

    @Override
    public void onMessageReceived(Context context, MessageEvent messageEvent) {
        if (messageEvent == null || messageEvent.getPath() == null) {
            Log.e(MYLOGGER, "Ignoring crashlytics message without path");
            return;
        }

        if(PATH_CRASHLYTICS.equalsIgnoreCase(messageEvent.getPath())){
            byte[] messageData = messageEvent.getData();
            if (messageData == null || messageData.length == 0) {
                Log.e(MYLOGGER, "Ignoring crashlytics message without payload");
                return;
            }

            try {
                sendCrashlyticsReport(DataMap.fromByteArray(messageData));
            }
            catch (IllegalArgumentException e) {
                Log.e(MYLOGGER, "Ignoring malformed crashlytics payload", e);
            }
        }
        else {
            Log.d(MYLOGGER, "unknown path:"+ messageEvent.getPath());
            super.onMessageReceived(context, messageEvent);
        }
    }

    /**
     * Sending the report. For now a crash or an exception are logged as exception.
     * Does someone know how to report a crash?
     * @param dataMap The DataMap send by the wear device.
     */
    private void sendCrashlyticsReport(DataMap dataMap){
        if (dataMap == null) {
            Log.e(MYLOGGER, "Ignoring empty crashlytics report");
            return;
        }

        Log.d(MYLOGGER, "Trying to send crashlytics report");
        String reportType = dataMap.getString(DATA_MAP_REPORT_TYPE);
        String errorReport = dataMap.getString(DATA_MAP_ERROR);
        if(reportType == null || reportType.length() == 0) {
            Log.e(MYLOGGER, "Crashlytics report missing DATA_MAP_REPORT_TYPE");
            return;
        }
        if(errorReport == null || errorReport.length() == 0) {
            Log.e(MYLOGGER, "Crashlytics report missing DATA_MAP_ERROR");
            return;
        }

        RuntimeException wearReport = new RuntimeException(errorReport);
        Log.d(MYLOGGER, "Crash report received from wear device: type=" + reportType);
        Crashlytics.setBool(CRASH_DATA_WEAR, Boolean.TRUE);
        for(Iterator<String> i = dataMap.keySet().iterator(); i.hasNext();){
            String key = i.next();
            if(!key.equalsIgnoreCase(DATA_MAP_ERROR)){
                Log.d(MYLOGGER,"data_map."+key+"="+dataMap.getString(key));
                Crashlytics.setString(key, dataMap.getString(key));
            }
        }
        //Is there a way to send a real crash report instead of log exception?
        Crashlytics.logException(wearReport);
        Log.d(MYLOGGER, "Crashlytics report sent");
    }
}
