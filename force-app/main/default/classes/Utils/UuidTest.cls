@IsTest
public with sharing class UuidTest {
    @isTest
    static void should_CreateSeveralValidUuids() {
        //given
        String generatedUuid = new Uuid().getValue();
        System.assertEquals(36, generatedUuid.length(), 'Expecting the length of generated UUID equals 36 characters');

        Pattern pattern = Pattern.compile('[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}');

        //when
        Test.startTest();
        for (Integer i = 0; i < 10; i++) {
            Uuid uuid = new Uuid();
            Matcher matcher = pattern.matcher(uuid.getValue());

            //then
            System.assert(matcher.matches(), 'Expecting generated UUID matches the pattern');
        }
        Test.stopTest();
    }

    @isTest
    static void should_ReuseUuidOnSubsequentCalls() {
        //given
        Uuid uuid = new Uuid();

        //when
        Test.startTest();
        String originalValue = uuid.getValue();
        Test.stopTest();

        //then
        System.assertEquals(originalValue, uuid.getValue(), 'Expecting that returned value is the same as original');
    }

    @isTest
    static void should_ThrowAnErrorWhenUuidIsNotValid() {
        //given
        String invalidUuidValue = 'this-is-not-a-valid-uuid';

        try {
            //when
            Test.startTest();
            String convertedUuid = Uuid.formatValue(invalidUuidValue);
            Test.stopTest();

            System.assert(false, 'Error expected here');
        } catch (Exception ex) {
            String expectedError = invalidUuidValue + ' is not a valid UUID';
            //then
            System.assert(ex.getMessage().contains(expectedError), 'Expecting exception is thrown');
        }
    }

    @isTest
    static void should_ThrowAnErrorWhenUuidIsNotValid2() {
        //given
        String invalidUuidValue = 'its-not-a-valid-uuid-but-the-length-is-ok';

        try {
            //when
            Test.startTest();
            String convertedUuid = Uuid.formatValue(invalidUuidValue);
            Test.stopTest();

            System.assert(false, 'Error expected here');
        } catch (Exception ex) {
            String expectedError = invalidUuidValue + ' is not a valid UUID';
            //then
            System.assert(ex.getMessage().contains(expectedError));
        }
    }

    @isTest
    static void shouldReturnFalseWhenUuidIsEmptyString() {
        Test.startTest();
        System.assertEquals(false, UUID.isValid(''), 'Expecting empty string is not valid UUID');
        Test.stopTest();
    }

    @isTest
    static void shouldReturnFalseWhenUuidIsNull() {
        Test.startTest();
        System.assertEquals(false, UUID.isValid(null), 'Expecting null is not valid UUID');
        Test.stopTest();
    }
}