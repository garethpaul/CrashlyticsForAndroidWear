package arno.di.loreto.crashlyticsforandroidwear.wearable;

import com.google.android.gms.wearable.MessageEvent;

/**
 * MessageEvent is not mutable, so this copies the fields needed by receivers.
 */
public class SerializableMessageEvent implements MessageEvent {

    private byte[] data;
    private String path;
    private int requestId;
    private String sourceNodeId;

    public SerializableMessageEvent(MessageEvent messageEvent){
        this(messageEvent.getData(), messageEvent.getPath(), messageEvent.getRequestId(), messageEvent.getSourceNodeId());
    }

    public SerializableMessageEvent(byte[] data, String path, int requestId, String sourceNodeId){
        this.data = data;
        this.path = path;
        this.requestId = requestId;
        this.sourceNodeId = sourceNodeId;
    }

    public byte[] getData() {
        return data;
    }

    public void setData(byte[] data) {
        this.data = data;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public String getSourceNodeId() {
        return sourceNodeId;
    }

    public void setSourceNodeId(String sourceNodeId) {
        this.sourceNodeId = sourceNodeId;
    }

}
