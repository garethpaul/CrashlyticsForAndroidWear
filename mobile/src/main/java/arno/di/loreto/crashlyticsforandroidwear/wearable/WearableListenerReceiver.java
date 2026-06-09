package arno.di.loreto.crashlyticsforandroidwear.wearable;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.google.android.gms.wearable.DataEventBuffer;
import com.google.android.gms.wearable.MessageEvent;
import com.google.android.gms.wearable.Node;

/**
 * A "Wear event" receiver.
 * Subclass it to create your own receiver, don't forget to declare it in the manifest like this:
 * <receiver android:name="your.packages.YourWearableListenerReceiver" >
 *  <intent-filter>
 *      <action android:name="arno.di.loreto.wearmessage" />
 *  </intent-filter>
 * </receiver>
 *
 * It will received event with onReceive and dispatchh this event on the right method.
 * As you can see, this class maps WearableListenerService methods.
 */
public class WearableListenerReceiver extends BroadcastReceiver {

    private static final String MYLOGGER = WearableListenerReceiver.class.getName();

    public void onCreate(Context context){}

    public void onPeerDisconnected(Context context, Node peer){}

    public void onPeerConnected(Context context, Node peer) {}

    public void onMessageReceived(Context context, MessageEvent messageEvent){}

    public void onDataChanged(Context context, DataEventBuffer dataEvents) {}

    /**
     * Do not override this: it receives the broadcasted wear event and dispatch it to the right method.
     * @param context
     * @param intent
     */
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(MYLOGGER, "onReceive");
        if (intent == null) {
            Log.e(MYLOGGER, "Ignoring wear event without an intent");
            return;
        }
        if (!WearableListenerBroadcaster.ACTION_NAME.equals(intent.getAction())) {
            Log.e(MYLOGGER, "Ignoring unexpected wear event action: " + intent.getAction());
            return;
        }

        String eventType = intent.getStringExtra(WearableListenerBroadcaster.EXTRA_DATA_EVENT_TYPE);
        if(eventType != null && eventType.equalsIgnoreCase(WearableListenerBroadcaster.EVENT_TYPE_ON_CREATE)){
            onCreate(context);
            return;
        }

        if(eventType != null && eventType.equalsIgnoreCase(WearableListenerBroadcaster.EVENT_TYPE_ON_MESSAGE_RECEIVED)){
            MessageEvent messageEvent = getMessageEvent(intent, eventType);
            if (messageEvent != null) {
                onMessageReceived(context, messageEvent);
            }
        }
        else if(eventType != null && eventType.equalsIgnoreCase(WearableListenerBroadcaster.EVENT_TYPE_ON_DATA_CHANGED)){
            Log.e(MYLOGGER, "Ignoring wear event without payload: " + eventType);
        }
        else if(eventType != null && eventType.equalsIgnoreCase(WearableListenerBroadcaster.EVENT_TYPE_ON_PEER_CONNECTED)){
            Node peer = getNode(intent, eventType);
            if (peer != null) {
                onPeerConnected(context, peer);
            }
        }
        else if(eventType != null && eventType.equalsIgnoreCase(WearableListenerBroadcaster.EVENT_TYPE_ON_PEER_DISCONNECTED)){
            Node peer = getNode(intent, eventType);
            if (peer != null) {
                onPeerDisconnected(context, peer);
            }
        }
        else{
            Log.e(MYLOGGER, "Unexpected eventType:"+eventType);
        }

    }

    private MessageEvent getMessageEvent(Intent intent, String eventType){
        String path = intent.getStringExtra(WearableListenerBroadcaster.EXTRA_DATA_PATH);
        if (path == null) {
            Log.e(MYLOGGER, "Ignoring wear event without payload: " + eventType);
            return null;
        }
        return new SerializableMessageEvent(
                intent.getByteArrayExtra(WearableListenerBroadcaster.EXTRA_MESSAGE_DATA),
                path,
                intent.getIntExtra(WearableListenerBroadcaster.EXTRA_MESSAGE_REQUEST_ID, 0),
                intent.getStringExtra(WearableListenerBroadcaster.EXTRA_MESSAGE_SOURCE_NODE_ID));
    }

    private Node getNode(Intent intent, String eventType){
        String nodeId = intent.getStringExtra(WearableListenerBroadcaster.EXTRA_NODE_ID);
        if (nodeId == null) {
            Log.e(MYLOGGER, "Ignoring wear event without payload: " + eventType);
            return null;
        }
        return new SerializableNode(
                intent.getStringExtra(WearableListenerBroadcaster.EXTRA_NODE_DISPLAY_NAME),
                nodeId);
    }
}
