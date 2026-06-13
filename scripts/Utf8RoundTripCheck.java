import java.nio.charset.Charset;
import java.util.Arrays;

public final class Utf8RoundTripCheck {
    private static final Charset UTF_8 = Charset.forName("UTF-8");
    private static final String MESSAGE = "caf\u00e9 \u6771\u4eac \ud83d\ude80";
    private static final byte[] EXPECTED_BYTES = {
            0x63, 0x61, 0x66, (byte) 0xc3, (byte) 0xa9, 0x20,
            (byte) 0xe6, (byte) 0x9d, (byte) 0xb1,
            (byte) 0xe4, (byte) 0xba, (byte) 0xac, 0x20,
            (byte) 0xf0, (byte) 0x9f, (byte) 0x9a, (byte) 0x80
    };

    private Utf8RoundTripCheck() {
    }

    public static void main(String[] args) {
        byte[] encoded = MESSAGE.getBytes(UTF_8);
        if (!Arrays.equals(EXPECTED_BYTES, encoded)) {
            throw new AssertionError("Dummy message did not encode as UTF-8");
        }

        String decoded = new String(encoded, UTF_8);
        if (!MESSAGE.equals(decoded)) {
            throw new AssertionError("Dummy message did not round-trip through UTF-8");
        }

        System.out.println("Dummy message UTF-8 round-trip passed.");
    }
}
