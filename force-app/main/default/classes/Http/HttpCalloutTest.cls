@IsTest
public with sharing class HttpCalloutTest {
    private static final String TEST_VAL_ENDPOINT = 'http://test.com';
    private static final String TEST_VAL_HEADER_KEY_1 = 'testHeader1';
    private static final String TEST_VAL_HEADER_KEY_2 = 'testHeader2';
    private static final String TEST_VAL_HEADER_VALUE_1 = 'testKey1';
    private static final String TEST_VAL_HEADER_VALUE_2 = 'testKey2';
    private static final String TEST_VAL_HEADER_VALUE_3 = 'testKey3';
    private static final Map<String, String> TEST_VAL_HEADERS_MAP = new Map<String, String>{
        TEST_VAL_HEADER_KEY_1 => TEST_VAL_HEADER_VALUE_1,
        TEST_VAL_HEADER_KEY_2 => TEST_VAL_HEADER_VALUE_2
    };
    private static final Map<String, List<String>> TEST_VAL_HEADERS_MAP_2 = new Map<String, List<String>>{
        TEST_VAL_HEADER_KEY_1 => new List<String> {TEST_VAL_HEADER_VALUE_1},
        TEST_VAL_HEADER_KEY_2 => new List<String> {TEST_VAL_HEADER_VALUE_2, TEST_VAL_HEADER_VALUE_3}
    };

    @isTest
    public static void shouldSetEndpoint() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        System.Test.startTest();
        HttpCallout callout = getBasicHttpCallout().endPoint(TEST_VAL_ENDPOINT);
        System.Test.stopTest();

        //then
        System.assertEquals(TEST_VAL_ENDPOINT, callout.endpoint, 'Expecting specific value of request endpoint');
    }

    @isTest
    public static void shouldAddHeader() {
        // final String TEST_VAL_ENDPOINT = 'http://test.com';
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        System.Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addHeader(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1);
        System.Test.stopTest();

        //then

        System.assertEquals(false, callout.headers.isEmpty(), 'Expecting header map is not empty');
        System.assertEquals(TEST_VAL_HEADER_VALUE_1, callout.headers.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of header');
    }

    @isTest
    public static void shouldAddMultipleHeaders() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        System.Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addHeader(TEST_VAL_HEADERS_MAP);
        System.Test.stopTest();

        //then
        System.assertEquals(false, callout.headers.isEmpty(), 'Expecting header map is not empty');
        System.assertEquals(TEST_VAL_HEADER_VALUE_1, callout.headers.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of header');
        System.assertEquals(TEST_VAL_HEADER_VALUE_2, callout.headers.get(TEST_VAL_HEADER_KEY_2), 'Expecting specific value of header');
    }

    @isTest
    public static void shouldAddParameter() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        System.Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameter(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1);
        System.Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(callout.parameters): ' + JSON.SerializePretty(callout.parameters));
        System.debug(LoggingLevel.DEBUG, 'callout.headers.get(TEST_VAL_HEADER_KEY_1): ' + callout.parameters.get(TEST_VAL_HEADER_KEY_1));
        System.assertEquals(false, callout.parameters.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(new List<String>{TEST_VAL_HEADER_VALUE_1}, callout.parameters.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of body parameter');
    }

    @isTest
    public static void shouldAddParameterBody() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        System.Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameterBody(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1);
        System.Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(callout.parametersBody): ' + JSON.SerializePretty(callout.parametersBody));
        System.debug(LoggingLevel.DEBUG, 'callout.parametersBody.get(TEST_VAL_HEADER_KEY_1): ' + callout.parametersBody.get(TEST_VAL_HEADER_KEY_1));
        System.assertEquals(false, callout.parametersBody.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(new List<String>{ TEST_VAL_HEADER_VALUE_1 }, callout.parametersBody.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of body parameter');
    }

    @isTest
    public static void shouldAddMultipleParameterBody() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        System.Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameterBody(TEST_VAL_HEADERS_MAP_2);
        System.Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(callout.parametersBody): ' + JSON.SerializePretty(callout.parametersBody));
        System.debug(LoggingLevel.DEBUG, 'callout.parametersBody.get(TEST_VAL_HEADER_KEY_1): ' + callout.parametersBody.get(TEST_VAL_HEADER_KEY_1));
        System.assertEquals(false, callout.parametersBody.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(new List<String>{ TEST_VAL_HEADER_VALUE_1 }, callout.parametersBody.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of body parameter');
        System.assertEquals(new List<String>{ TEST_VAL_HEADER_VALUE_2, TEST_VAL_HEADER_VALUE_3 }, callout.parametersBody.get(TEST_VAL_HEADER_KEY_2), 'Expecting specific value of body parameter');
    }


    private static HttpCallout getBasicHttpCallout() {
        return new HttpCallout().method('GET').endpoint('https://test.endpoint.com').builder();
    }
}