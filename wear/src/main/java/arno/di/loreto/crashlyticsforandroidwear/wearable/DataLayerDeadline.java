package arno.di.loreto.crashlyticsforandroidwear.wearable;

public final class DataLayerDeadline {

    private DataLayerDeadline() {
    }

    public static long remainingNanos(long startedAtNanos, long currentNanos, long timeoutNanos) {
        if (timeoutNanos <= 0) {
            return 0;
        }

        long elapsedNanos = currentNanos - startedAtNanos;
        if (elapsedNanos <= 0) {
            return timeoutNanos;
        }
        if (elapsedNanos >= timeoutNanos) {
            return 0;
        }
        return timeoutNanos - elapsedNanos;
    }
}
