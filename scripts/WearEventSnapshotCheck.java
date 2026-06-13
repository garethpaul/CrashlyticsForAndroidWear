import arno.di.loreto.crashlyticsforandroidwear.wearable.SerializableMessageEvent;
import arno.di.loreto.crashlyticsforandroidwear.wearable.SerializableNode;
import com.google.android.gms.wearable.MessageEvent;
import com.google.android.gms.wearable.Node;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;

public final class WearEventSnapshotCheck {
    private WearEventSnapshotCheck() {}

    public static void main(String[] args) {
        verifyMessageSnapshot();
        verifyNodeSnapshot();
        verifyImmutableShape(SerializableMessageEvent.class);
        verifyImmutableShape(SerializableNode.class);
        System.out.println("Wear event immutable snapshot checks passed.");
    }

    private static void verifyMessageSnapshot() {
        final byte[] sourceData = new byte[] {1, 2, 3};
        MessageEvent sourceEvent = new MessageEvent() {
            public byte[] getData() { return sourceData; }
            public String getPath() { return "/crashlytics"; }
            public int getRequestId() { return 41; }
            public String getSourceNodeId() { return "watch-node"; }
        };

        SerializableMessageEvent snapshot = new SerializableMessageEvent(sourceEvent);
        sourceData[0] = 9;
        require(Arrays.equals(snapshot.getData(), new byte[] {1, 2, 3}),
                "Constructor must copy message data.");

        byte[] returnedData = snapshot.getData();
        returnedData[1] = 8;
        require(Arrays.equals(snapshot.getData(), new byte[] {1, 2, 3}),
                "Getter must copy message data.");
        require("/crashlytics".equals(snapshot.getPath()), "Path changed.");
        require(snapshot.getRequestId() == 41, "Request id changed.");
        require("watch-node".equals(snapshot.getSourceNodeId()), "Source node changed.");

        SerializableMessageEvent nullPayload = new SerializableMessageEvent(
                null, "/dummy", 7, "other-node");
        require(nullPayload.getData() == null, "Null message data must remain null.");
    }

    private static void verifyNodeSnapshot() {
        Node sourceNode = new Node() {
            public String getDisplayName() { return "Workshop Watch"; }
            public String getId() { return "node-17"; }
        };
        SerializableNode snapshot = new SerializableNode(sourceNode);
        require("Workshop Watch".equals(snapshot.getDisplayName()), "Display name changed.");
        require("node-17".equals(snapshot.getId()), "Node id changed.");
    }

    private static void verifyImmutableShape(Class<?> type) {
        for (Field field : type.getDeclaredFields()) {
            int modifiers = field.getModifiers();
            require(Modifier.isPrivate(modifiers), type.getSimpleName() + " field must be private.");
            require(Modifier.isFinal(modifiers), type.getSimpleName() + " field must be final.");
        }
        for (Method method : type.getDeclaredMethods()) {
            require(!method.getName().startsWith("set"),
                    type.getSimpleName() + " must not expose setters.");
        }
    }

    private static void require(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
