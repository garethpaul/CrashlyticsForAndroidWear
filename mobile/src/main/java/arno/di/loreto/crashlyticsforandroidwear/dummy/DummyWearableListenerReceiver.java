package arno.di.loreto.crashlyticsforandroidwear.dummy;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.wearable.MessageEvent;

import java.nio.charset.Charset;

import arno.di.loreto.crashlyticsforandroidwear.wearable.WearableListenerReceiver;

/**
 * A dummy receiver that will log the messages he received on path PATH_DUMMY = /dummy.
 * The purpose of this receiver is to show that when you create an Android Wear
 * application you need to send different type of message from the watch to the host device.
 */
public class DummyWearableListenerReceiver extends WearableListenerReceiver {

    private static final String MYLOGGER = DummyWearableListenerReceiver.class.getName();
    private static final Charset UTF_8 = Charset.forName("UTF-8");

    /**
     * The path handled by this receiver.
     */
    private static final String PATH_DUMMY = "/dummy";

    /**
     * A message is received, displaying it in the logs.
     * @param context
     * @param messageEvent
     */
    @Override
    public void onMessageReceived(Context context, MessageEvent messageEvent) {
        if (messageEvent == null || messageEvent.getPath() == null) {
            Log.e(MYLOGGER, "Ignoring dummy message without path");
            return;
        }

        if(PATH_DUMMY.equalsIgnoreCase(messageEvent.getPath())){
            byte[] messageData = messageEvent.getData();
            if (messageData == null || messageData.length == 0) {
                Log.e(MYLOGGER, "Ignoring dummy message without payload");
                return;
            }
            String decodedMessage = new String(messageData, UTF_8);
            Log.d(MYLOGGER, "Dummy message received");
        }
        else {
            Log.d(MYLOGGER, "Unknown dummy message path");
            super.onMessageReceived(context, messageEvent);
        }
    }

}
