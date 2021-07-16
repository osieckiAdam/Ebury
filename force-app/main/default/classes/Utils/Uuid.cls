public without sharing class Uuid {
    private static final Integer HEX_BASE = HEX_CHARACTERS.length();
    private static final List<String> HEX_CHARACTER_LIST = HEX_CHARACTERS.split('');
    private static final String HEX_CHARACTERS = '0123456789abcdef';
    private static final String HEX_PREFIX = '0x';
    private static final Integer UUID_V4_LENGTH = 36;
    private static final String UUID_V4_REGEX = '[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}';

    public Uuid() {
        this.value = this.generateValue();
    }

    public String getValue() {
        return this.value;
    }

    private final String value;

    private String generateValue() {
        String hexValue = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String versionShiftedHexBits = this.getShiftedHexBits(
            hexValue.substring(14, 16),
            this.convertHexToInteger('0x0f'),
            this.convertHexToInteger('0x40')
        );
        String variantShiftedHexBits = this.getShiftedHexBits(
            hexValue.substring(18, 20),
            this.convertHexToInteger('0x3f'),
            this.convertHexToInteger('0x80')
        );

        String uuidValue =
            hexValue.substring(0, 8) +
            hexValue.substring(8, 12) +
            versionShiftedHexBits +
            hexValue.substring(14, 16) +
            variantShiftedHexBits +
            hexValue.substring(18, 20) +
            hexValue.substring(20);

        return Uuid.formatValue(uuidValue);
    }

    @TestVisible
    private static String formatValue(String unformattedValue) {
        final String invalidValueError = unformattedValue + ' is not a valid UUID value';

        unformattedValue = unformattedValue.replaceAll('[^a-zA-Z0-9]', '');

        if (unformattedValue.length() != (UUID_V4_LENGTH - 4)) {
            throw new UuidException(invalidValueError);
        }
        String formattedValue =
            unformattedValue.substring(0, 8) +
            '-' +
            unformattedValue.substring(8, 12) +
            '-' +
            unformattedValue.substring(12, 16) +
            '-' +
            unformattedValue.substring(16, 20) +
            '-' +
            unformattedValue.substring(20);

        formattedValue = formattedValue.toLowerCase();

        if (!Uuid.isValid(formattedValue)) {
            throw new UuidException(invalidValueError);
        }

        return formattedValue;
    }

    private String getShiftedHexBits(String hexSubstring, Integer lowerThreshold, Integer upperThreshold) {
        Integer shiftedIntegerBits = (this.convertHexToInteger(hexSubstring) & lowerThreshold) | upperThreshold;
        return this.convertIntegerToHex(shiftedIntegerBits);
    }

    private Integer convertHexToInteger(String hexValue) {
        hexValue = hexValue.toLowerCase();

        if (hexValue.startsWith(HEX_PREFIX)) {
            hexValue = hexValue.substringAfter(HEX_PREFIX);
        }
        Integer integerValue = 0;
        for (String hexCharacter : hexValue.split('')) {
            Integer hexCharacterIndex = HEX_CHARACTERS.indexOf(hexCharacter);

            integerValue = HEX_BASE * integerValue + hexCharacterIndex;
        }
        return integerValue;
    }

    private String convertIntegerToHex(Integer integerValue) {
        String hexValue = '';
        while (integerValue > 0) {
            Integer hexCharacterIndex = Math.mod(integerValue, HEX_BASE);

            hexValue = HEX_CHARACTER_LIST[hexCharacterIndex] + hexValue;
            integerValue = integerValue / HEX_BASE;
        }
        return hexValue;
    }

    @TestVisible
    private static Boolean isValid(String uuidValue) {
        if (String.isBlank(uuidValue) || uuidValue.length() != UUID_V4_LENGTH) {
            return false;
        }

        Pattern uuidPattern = Pattern.compile(UUID_V4_REGEX.toLowerCase());
        Matcher uuidMatcher = uuidPattern.matcher(uuidValue.toLowerCase());

        return uuidMatcher.matches();
    }

    private class UuidException extends Exception {
    }
}