package arno.di.loreto.crashlyticsforandroidwear.wearable;

import android.content.Intent;
import android.util.Log;

import com.google.android.gms.wearable.DataEventBuffer;
import com.google.android.gms.wearable.MessageEvent;
import com.google.android.gms.wearable.Node;
import com.google.android.gms.wearable.WearableListenerService;

/**
 * The (only) WearableListenerService which will received message from the watch.
 * He will broadcast all events to receivers (WearableListenerReceiver subclass)
 * declared in AndroidManifest with action intent filter = ACTION_NAME ("arno.di.loreto.wearmessage").
 * I tried to use localbroadcasting but did not manage to succeed, so for the moment I use standard broadcast.
 * The events can be
 * - onCreate
 * - onPeerDisconnected
 * - onPeerConnected
 * - onMessageReceived
 * - onDataChanged (TODO)
 * You can manage different type of message within a WearableListenerService but what about clean
 * third party library integration which need to send message or use dataLayer too?
 * Personnally I don't want to mix things that don't need to be mixed.
 * So this is why I do it like that, it would have been much simpler if we could register
 * more that one WearableListenerService
 */
public class WearableListenerBroadcaster extends WearableListenerService {

    private static final String MYLOGGER = WearableListenerBroadcaster.class.getName();

    public static final String ACTION_NAME = "arno.di.loreto.wearmessage";

    public static final String EXTRA_DATA_EVENT_TYPE = "EVENT_TYPE";
    public static final String EXTRA_DATA_PATH = "EVENT_PATH";
    public static final String EXTRA_MESSAGE_DATA = "MESSAGE_DATA";
    public static final String EXTRA_MESSAGE_REQUEST_ID = "MESSAGE_REQUEST_ID";
    public static final String EXTRA_MESSAGE_SOURCE_NODE_ID = "MESSAGE_SOURCE_NODE_ID";
    public static final String EXTRA_NODE_DISPLAY_NAME = "NODE_DISPLAY_NAME";
    public static final String EXTRA_NODE_ID = "NODE_ID";

    public static final String EVENT_TYPE_ON_MESSAGE_RECEIVED = "ON_MESSAGE_RECEIVED";
    public static final String EVENT_TYPE_ON_DATA_CHANGED = "ON_DATA_CHANGED";
    public static final String EVENT_TYPE_ON_PEER_DISCONNECTED = "ON_PEER_DISCONNECTED";
    public static final String EVENT_TYPE_ON_PEER_CONNECTED = "ON_PEER_CONNECTED";
    public static final String EVENT_TYPE_ON_CREATE = "ON_CREATE";


    /**
     * Broadcasts the WearableListenerService.onPeerDisconnected event.
     * @param peer
     */
    @Override
    public void onPeerDisconnected(Node peer) {
        if (peer == null) {
            Log.e(MYLOGGER, "Ignoring disconnected peer without node data");
            return;
        }
        Log.d(MYLOGGER, "Wear peer disconnected");
        Intent intent = newWearEventIntent();
        intent.putExtra(EXTRA_NODE_DISPLAY_NAME, peer.getDisplayName());
        intent.putExtra(EXTRA_NODE_ID, peer.getId());
        intent.putExtra(EXTRA_DATA_EVENT_TYPE, EVENT_TYPE_ON_PEER_DISCONNECTED);
        this.sendBroadcast(intent);
        super.onPeerDisconnected(peer);
    }

    /**
     * Broadcasts the WearableListenerService.onPeerConnected event.
     * @param peer
     */
    @Override
    public void onPeerConnected(Node peer) {
        if (peer == null) {
            Log.e(MYLOGGER, "Ignoring connected peer without node data");
            return;
        }
        Log.d(MYLOGGER, "Wear peer connected");
        Intent intent = newWearEventIntent();
        intent.putExtra(EXTRA_NODE_DISPLAY_NAME, peer.getDisplayName());
        intent.putExtra(EXTRA_NODE_ID, peer.getId());
        intent.putExtra(EXTRA_DATA_EVENT_TYPE, EVENT_TYPE_ON_PEER_CONNECTED);
        this.sendBroadcast(intent);
        super.onPeerConnected(peer);
    }

    /**
     * Broadcasts the WearableListenerService.onMessageReceivedEvent
     * @param messageEvent
     */
    @Override
    public void onMessageReceived(MessageEvent messageEvent) {
        if (messageEvent == null || messageEvent.getPath() == null) {
            Log.e(MYLOGGER, "Ignoring message event without path");
            return;
        }
        Log.d(MYLOGGER, "Wear message received");
        Intent intent = newWearEventIntent();
        intent.putExtra(EXTRA_DATA_EVENT_TYPE, EVENT_TYPE_ON_MESSAGE_RECEIVED);
        intent.putExtra(EXTRA_DATA_PATH, messageEvent.getPath());
        intent.putExtra(EXTRA_MESSAGE_DATA, messageEvent.getData());
        intent.putExtra(EXTRA_MESSAGE_REQUEST_ID, messageEvent.getRequestId());
        intent.putExtra(EXTRA_MESSAGE_SOURCE_NODE_ID, messageEvent.getSourceNodeId());
        Log.d(MYLOGGER, "Broadcasting to " + ACTION_NAME);
        this.sendBroadcast(intent);
        super.onMessageReceived(messageEvent);
    }

    /**
     * Broadcasts the WearableListenerService.onDataChangedEvent TO DO
     * @param dataEvents
     */
    @Override
    public void onDataChanged(DataEventBuffer dataEvents) {
        try {
            if (dataEvents == null || dataEvents.getStatus() == null) {
                Log.e(MYLOGGER, "Ignoring data change without status");
                return;
            }
            Log.d(MYLOGGER, "Wear data change received");
            /*
            Intent intent = new Intent(ACTION_NAME);
            intent.putExtra(EXTRA_DATA_EVENT_TYPE, EVENT_TYPE_ON_DATA_CHANGED);
            this.sendBroadcast(intent);
            */
            super.onDataChanged(dataEvents);
        }
        finally {
            releaseDataEvents(dataEvents);
        }
    }

    /**
     * Destroy is not broadcast. But it could using the same mecanism as for the other events.
     */
    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    /**
     * Broadcast the WearableListenerService.onCreate event.
     */
    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(MYLOGGER, "onCreate");
        Intent intent = newWearEventIntent();
        intent.putExtra(EXTRA_DATA_EVENT_TYPE, EVENT_TYPE_ON_CREATE);
        Log.d(MYLOGGER, "Broadcasting onCreate to " + ACTION_NAME);
        this.sendBroadcast(intent);
    }

    private Intent newWearEventIntent() {
        Intent intent = new Intent(ACTION_NAME);
        intent.setPackage(getPackageName());
        return intent;
    }

    private static void releaseDataEvents(DataEventBuffer dataEvents) {
        if (dataEvents != null) {
            dataEvents.release();
        }
    }
}
