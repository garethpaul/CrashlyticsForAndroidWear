package arno.di.loreto.crashlyticsforandroidwear.wearable;

import com.google.android.gms.wearable.Node;

/**
 * Node is not mutable, so this copies the fields needed by receivers.
 */
public class SerializableNode implements Node {

    private String displayName;
    private String id;

    public SerializableNode(Node peer){
        this(peer.getDisplayName(), peer.getId());
    }

    public SerializableNode(String displayName, String id){
        this.displayName = displayName;
        this.id = id;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
}
