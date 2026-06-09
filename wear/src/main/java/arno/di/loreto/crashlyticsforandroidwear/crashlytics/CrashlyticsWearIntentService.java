package arno.di.loreto.crashlyticsforandroidwear.crashlytics;

import android.app.IntentService;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.wearable.DataMap;
import com.google.android.gms.wearable.MessageApi;
import com.google.android.gms.wearable.Node;
import com.google.android.gms.wearable.NodeApi;
import com.google.android.gms.wearable.Wearable;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * An IntentService to send Crashlytics reports to hosting device from wear device.
 * Do not forget to declare CrashlyticsIntentService in AndroidManifest.xml
 * <service android:name="com.crashlytics.android.wear.CrashlyticsIntentService" android:process=":error"></service>
 */
public class CrashlyticsWearIntentService extends IntentService {

    /**
     * The logger's name.
     */
    private static final String MYLOGGER = CrashlyticsWearIntentService.class.getName();
    /**
     * The Intent's name.
     */
    public static final String INTENT_NAME = "CrashlyticsWearIntentService";
    /**
     * Key to get the error (Throwable) from intent's extra data
     */
    public static final String EXTRA_DATA_ERROR = "ERROR";
    /**
     * Key to get the report_type (String) from intent's extra data
     */
    public static final String EXTRA_DATA_REPORT_TYPE = "REPORT_TYPE";

    public static final String REPORT_TYPE_CRASH = "CRASH";
    public static final String REPORT_TYPE_EXCEPTION = "EXCEPTION";

    /**
     * Path used to send the message.
     */
    public static final String PATH_CRASHLYTICS = "/crashlytics";

    public static final String DATA_MAP_ERROR = "ERROR";
    public static final String DATA_MAP_BOARD = "BOARD";
    public static final String DATA_MAP_BOOTLOADER = "BOOTLOADER";
    public static final String DATA_MAP_BRAND = "BRAND";
    public static final String DATA_MAP_DEVICE = "DEVICE";
    public static final String DATA_MAP_HARDWARE = "HARDWARE";
    public static final String DATA_MAP_MANUFACTURER = "MANUFACTURER";
    public static final String DATA_MAP_MODEL = "MODEL";
    public static final String DATA_MAP_DISPLAY = "DISPLAY";
    public static final String DATA_MAP_FINGERPRINT = "FINGERPRINT";
    public static final String DATA_MAP_HOST = "HOST";
    public static final String DATA_MAP_ID = "ID";
    public static final String DATA_MAP_PRODUCT = "PRODUCT";
    public static final String DATA_MAP_RADIOVERSION = "RADIOVERSION";
    public static final String DATA_MAP_SERIAL = "SERIAL";
    public static final String DATA_MAP_SUPPORTED_32_BIT_ABIS = "SUPPORTED_32_BIT_ABIS";
    public static final String DATA_MAP_SUPPORTED_64_BIT_ABIS = "SUPPORTED_64_BIT_ABIS";
    public static final String DATA_MAP_SUPPORTED_ABIS = "SUPPORTED_ABIS";
    public static final String DATA_MAP_TAGS = "TAGS";
    public static final String DATA_MAP_TIME = "TIME";
    public static final String DATA_MAP_UNKNOWN = "UNKNOWN";
    public static final String DATA_MAP_USER = "USER";
    public static final String DATA_MAP_VERSION_CODENAME = "VERSION.CODENAME";
    public static final String DATA_MAP_VERSION_INCREMENTAL = "VERSION.INCREMENTAL";
    public static final String DATA_MAP_VERSION_RELEASE = "VERSION.RELEASE";
    private static final String ARRAY_SEPARATOR = ",";
    public static final String DATA_MAP_REPORT_TYPE = "REPORT_TYPE";


    /**
     * Creates a new CrashlyticsIntentService (do nothing).
     */
    public CrashlyticsWearIntentService(){
        super(INTENT_NAME);
    }

    /**
     * Doing the job: creating a DataMap containing the exception and other useful data then send it
     * via a message on path PATH_CRASHLYTICS.
     * @param intent The intent containing the serialized exception in extra data (EXTRA_DATA_ERROR)
     */
    @Override
    protected void onHandleIntent(Intent intent) {
        Log.d(MYLOGGER, "onHandleIntent called.");
        if (intent == null) {
            Log.e(MYLOGGER, "Ignoring crashlytics report without intent");
            return;
        }

        Object errorExtra = intent.getSerializableExtra(EXTRA_DATA_ERROR);
        String report_type = (String)intent.getStringExtra(EXTRA_DATA_REPORT_TYPE);
        if (!(errorExtra instanceof Throwable)) {
            Log.e(MYLOGGER, "Ignoring crashlytics report without throwable");
            return;
        }
        if (report_type == null || report_type.length() == 0) {
            Log.e(MYLOGGER, "Ignoring crashlytics report without report type");
            return;
        }
        if (!isSupportedReportType(report_type)) {
            Log.e(MYLOGGER, "Ignoring crashlytics report with unsupported report type");
            return;
        }

        Throwable ex = (Throwable) errorExtra;
        Log.d(MYLOGGER, "Received crashlytics report");

        DataMap dataMap = new DataMap();

        try {

            dataMap.putString(DATA_MAP_ERROR, throwableToString(ex));
            dataMap.putString(DATA_MAP_REPORT_TYPE, report_type);

            //Some OS and hardware data, maybe we can send more informations or do it a better way...
            dataMap.putString(DATA_MAP_BOARD, Build.BOARD);
            dataMap.putString(DATA_MAP_BOOTLOADER, Build.BOOTLOADER);
            dataMap.putString(DATA_MAP_BRAND, Build.BRAND);
            dataMap.putString(DATA_MAP_DEVICE, Build.DEVICE);
            dataMap.putString(DATA_MAP_HARDWARE, Build.HARDWARE);
            dataMap.putString(DATA_MAP_MANUFACTURER, Build.MANUFACTURER);
            dataMap.putString(DATA_MAP_MODEL, Build.MODEL);
            dataMap.putString(DATA_MAP_DISPLAY,Build.DISPLAY);
            dataMap.putString(DATA_MAP_FINGERPRINT,Build.FINGERPRINT);
            dataMap.putString(DATA_MAP_HOST,Build.HOST);
            dataMap.putString(DATA_MAP_ID,Build.ID);
            dataMap.putString(DATA_MAP_PRODUCT,Build.PRODUCT);
            dataMap.putString(DATA_MAP_RADIOVERSION,Build.getRadioVersion());
            dataMap.putString(DATA_MAP_SERIAL,Build.SERIAL);

            /* for API level 21 only
            StringBuffer thirtyTwoBitAbis = new StringBuffer();
            for(int i = 0; i<Build.SUPPORTED_32_BIT_ABIS.length;i++){
                thirtyTwoBitAbis.append(Build.SUPPORTED_32_BIT_ABIS[i]);
                if(i < Build.SUPPORTED_32_BIT_ABIS.length)
                    thirtyTwoBitAbis.append(ARRAY_SEPARATOR);
            }
            dataMap.putString(DATA_MAP_SUPPORTED_32_BIT_ABIS, thirtyTwoBitAbis.toString());

            StringBuffer sixtyFourBitAbis = new StringBuffer();
            for(int i = 0; i<Build.SUPPORTED_64_BIT_ABIS.length;i++){
                sixtyFourBitAbis.append(Build.SUPPORTED_64_BIT_ABIS[i]);
                if(i < Build.SUPPORTED_64_BIT_ABIS.length)
                    sixtyFourBitAbis.append(ARRAY_SEPARATOR);
            }
            dataMap.putString(DATA_MAP_SUPPORTED_64_BIT_ABIS,sixtyFourBitAbis.toString());

            StringBuffer abis = new StringBuffer();
            for(int i = 0; i<Build.SUPPORTED_ABIS.length;i++){
                abis.append(Build.SUPPORTED_ABIS[i]);
                if(i < Build.SUPPORTED_ABIS.length)
                    abis.append(ARRAY_SEPARATOR);
            }
            dataMap.putString(DATA_MAP_SUPPORTED_ABIS, abis.toString());
            */
            dataMap.putString(DATA_MAP_TAGS,Build.TAGS);
            dataMap.putString(DATA_MAP_TIME,Long.valueOf(Build.TIME).toString());
            dataMap.putString(DATA_MAP_UNKNOWN,Build.UNKNOWN);
            dataMap.putString(DATA_MAP_USER,Build.USER);
            dataMap.putString(DATA_MAP_VERSION_CODENAME,Build.VERSION.CODENAME);
            dataMap.putString(DATA_MAP_VERSION_INCREMENTAL,Build.VERSION.INCREMENTAL);
            dataMap.putString(DATA_MAP_VERSION_RELEASE,Build.VERSION.RELEASE);

            //sending the message to the host device
            sendMessage(PATH_CRASHLYTICS, dataMap);
        }
        catch(IOException _ex){
            Log.e(MYLOGGER, "Crashlytics report failed", _ex);
        }
    }

    private static boolean isSupportedReportType(String reportType) {
        return REPORT_TYPE_CRASH.equals(reportType) || REPORT_TYPE_EXCEPTION.equals(reportType);
    }

    private static String throwableToString(Throwable ex) throws IOException {
        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        try {
            if(ex == null) {
                printWriter.print("No Throwable supplied.");
            }
            else {
                ex.printStackTrace(printWriter);
            }
            printWriter.flush();
            return stringWriter.toString();
        }
        finally {
            printWriter.close();
            stringWriter.close();
        }
    }

    /**
     * Connecting to Google API and sending a datamap to all connected devices.
     * @param path The path
     * @param dataMap The dataMap containing the crash or exception data
     */
    private void sendMessage(String path, DataMap dataMap) {
        if (path == null || path.length() == 0 || dataMap == null) {
            Log.e(MYLOGGER, "Ignoring crashlytics report without send target");
            return;
        }

        GoogleApiClient mApiClient = new GoogleApiClient.Builder(CrashlyticsWearIntentService.this)
                .addApi( Wearable.API )
                .build();
        try {
            Log.d(MYLOGGER, "Connecting to Google API");
            if (!mApiClient.blockingConnect().isSuccess()) {
                Log.e(MYLOGGER, "Connecting to Google API failed");
                return;
            }
            Log.d(MYLOGGER, "Connected to Google API");

            NodeApi.GetConnectedNodesResult nodes = Wearable.NodeApi.getConnectedNodes( mApiClient ).await();
            if (nodes == null || nodes.getNodes() == null) {
                Log.e(MYLOGGER, "No connected nodes available for crashlytics report");
                return;
            }
            Log.d(MYLOGGER, "Connected nodes size "+nodes.getNodes().size());
            for(Node node : nodes.getNodes()) {
                if (node == null || node.getId() == null || node.getId().length() == 0) {
                    Log.e(MYLOGGER, "Skipping connected node without id");
                    continue;
                }

                MessageApi.SendMessageResult result = Wearable.MessageApi.sendMessage(
                        mApiClient, node.getId(), path, dataMap.toByteArray() ).await();
                if(result.getStatus().isSuccess()) {
                    Log.d(MYLOGGER, "Message sent on node:"+node.getDisplayName());
                }
                else{
                    Log.e(MYLOGGER, "Sending message failed: " + result.getStatus().getStatusMessage() + ", Node:" + node.getDisplayName());
                }
            }
        }
        finally {
            if (mApiClient.isConnected() || mApiClient.isConnecting()) {
                mApiClient.disconnect();
            }
        }
    }
}
