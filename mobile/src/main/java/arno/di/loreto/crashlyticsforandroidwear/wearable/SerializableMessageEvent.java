package arno.di.loreto.crashlyticsforandroidwear.wearable;

import com.google.android.gms.wearable.MessageEvent;

/**
 * MessageEvent is not mutable, so this copies the fields needed by receivers.
 */
public class SerializableMessageEvent implements MessageEvent {

    private final byte[] data;
    private final String path;
    private final int requestId;
    private final String sourceNodeId;

    public SerializableMessageEvent(MessageEvent messageEvent){
        this(messageEvent.getData(), messageEvent.getPath(), messageEvent.getRequestId(), messageEvent.getSourceNodeId());
    }

    public SerializableMessageEvent(byte[] data, String path, int requestId, String sourceNodeId){
        this.data = copyData(data);
        this.path = path;
        this.requestId = requestId;
        this.sourceNodeId = sourceNodeId;
    }

    public byte[] getData() {
        return copyData(data);
    }

    public String getPath() {
        return path;
    }

    public int getRequestId() {
        return requestId;
    }

    public String getSourceNodeId() {
        return sourceNodeId;
    }

    private static byte[] copyData(byte[] data) {
        return data == null ? null : data.clone();
    }

}
