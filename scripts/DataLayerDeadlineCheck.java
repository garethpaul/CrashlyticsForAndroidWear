package arno.di.loreto.crashlyticsforandroidwear.wearable;

public final class DataLayerDeadlineCheck {
    private int cases;

    public static void main(String[] args) {
        DataLayerDeadlineCheck check = new DataLayerDeadlineCheck();
        check.run();
        System.out.println("Data Layer deadline checks passed: " + check.cases + " cases.");
    }

    private void run() {
        keepsFullBudgetAtStart();
        subtractsElapsedBudget();
        expiresAtDeadline();
        rejectsInvalidBudget();
    }

    private void keepsFullBudgetAtStart() {
        expectEquals(5000L, DataLayerDeadline.remainingNanos(100L, 100L, 5000L));
        cases++;
    }

    private void subtractsElapsedBudget() {
        expectEquals(3500L, DataLayerDeadline.remainingNanos(100L, 1600L, 5000L));
        cases++;
    }

    private void expiresAtDeadline() {
        expectEquals(0L, DataLayerDeadline.remainingNanos(100L, 5100L, 5000L));
        expectEquals(0L, DataLayerDeadline.remainingNanos(100L, 6000L, 5000L));
        cases++;
    }

    private void rejectsInvalidBudget() {
        expectEquals(0L, DataLayerDeadline.remainingNanos(100L, 100L, 0L));
        expectEquals(0L, DataLayerDeadline.remainingNanos(100L, 100L, -1L));
        cases++;
    }

    private static void expectEquals(long expected, long actual) {
        if (expected != actual) {
            throw new AssertionError("Expected " + expected + " but was " + actual);
        }
    }
}
