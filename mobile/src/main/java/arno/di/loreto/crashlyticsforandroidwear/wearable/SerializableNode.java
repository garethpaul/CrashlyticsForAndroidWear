package arno.di.loreto.crashlyticsforandroidwear.wearable;

import com.google.android.gms.wearable.Node;

/**
 * Node is not mutable, so this copies the fields needed by receivers.
 */
public class SerializableNode implements Node {

    private final String displayName;
    private final String id;

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

    public String getId() {
        return id;
    }

}
