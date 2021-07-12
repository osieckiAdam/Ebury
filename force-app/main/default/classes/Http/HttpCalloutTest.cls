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
        TEST_VAL_HEADER_KEY_1 => new List<String>{ TEST_VAL_HEADER_VALUE_1 },
        TEST_VAL_HEADER_KEY_2 => new List<String>{ TEST_VAL_HEADER_VALUE_2, TEST_VAL_HEADER_VALUE_3 }
    };
    private static final String TEST_VAL_BODY_AS_STRING = '{"testParam1":"testValue1"}';

    @isTest
    public static void should_SetEndpoint() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().endPoint(TEST_VAL_ENDPOINT);
        Test.stopTest();

        //then
        System.assertEquals(TEST_VAL_ENDPOINT, callout.endpoint, 'Expecting specific value of request endpoint');
    }

    @isTest
    public static void should_SetMethod() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().method('POST');
        Test.stopTest();

        //then
        System.assertEquals('POST', callout.method, 'Expecting specific value of Http Method');
    }

    @isTest
    public static void should_AddHeader() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addHeader(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1);
        Test.stopTest();

        //then
        System.assertEquals(false, callout.headers.isEmpty(), 'Expecting header map is not empty');
        System.assertEquals(TEST_VAL_HEADER_VALUE_1, callout.headers.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of header');
    }

    @isTest
    public static void should_AddMultipleHeaders() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addHeader(TEST_VAL_HEADERS_MAP);
        Test.stopTest();

        //then
        System.assertEquals(false, callout.headers.isEmpty(), 'Expecting header map is not empty');
        System.assertEquals(TEST_VAL_HEADER_VALUE_1, callout.headers.get(TEST_VAL_HEADER_KEY_1), 'Expecting specific value of header');
        System.assertEquals(TEST_VAL_HEADER_VALUE_2, callout.headers.get(TEST_VAL_HEADER_KEY_2), 'Expecting specific value of header');
    }

    @isTest
    public static void should_AddParameter() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameter(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1);
        Test.stopTest();

        //then
        System.assertEquals(false, callout.parameters.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(
            new List<String>{ TEST_VAL_HEADER_VALUE_1 },
            callout.parameters.get(TEST_VAL_HEADER_KEY_1),
            'Expecting specific value of body parameter'
        );
    }

    @isTest
    public static void should_AddMultipleParameters() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameter(TEST_VAL_HEADERS_MAP_2);
        Test.stopTest();

        //then
        System.assertEquals(false, callout.parameters.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(
            new List<String>{ TEST_VAL_HEADER_VALUE_2, TEST_VAL_HEADER_VALUE_3 },
            callout.parameters.get(TEST_VAL_HEADER_KEY_2),
            'Expecting specific value of parameter'
        );
    }

    @isTest
    public static void should_AddParameterBody() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameterBody(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1);
        Test.stopTest();

        //then
        System.assertEquals(false, callout.parametersBody.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(
            new List<String>{ TEST_VAL_HEADER_VALUE_1 },
            callout.parametersBody.get(TEST_VAL_HEADER_KEY_1),
            'Expecting specific value of body parameter'
        );
    }

    @isTest
    public static void should_AddMultipleParameterBody() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().addParameterBody(TEST_VAL_HEADERS_MAP_2);
        Test.stopTest();

        //then
        System.assertEquals(false, callout.parametersBody.isEmpty(), 'Expecting body parameter map is not empty');
        System.assertEquals(
            new List<String>{ TEST_VAL_HEADER_VALUE_1 },
            callout.parametersBody.get(TEST_VAL_HEADER_KEY_1),
            'Expecting specific value of body parameter'
        );
        System.assertEquals(
            new List<String>{ TEST_VAL_HEADER_VALUE_2, TEST_VAL_HEADER_VALUE_3 },
            callout.parametersBody.get(TEST_VAL_HEADER_KEY_2),
            'Expecting specific value of body parameter'
        );
    }

    @isTest
    public static void should_AddRequestBodyAsString() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().body(TEST_VAL_BODY_AS_STRING);
        Test.stopTest();

        //then
        System.assertEquals(TEST_VAL_BODY_AS_STRING, callout.body, 'Expecting specific value of body');
    }

    @isTest
    public static void should_AddRequestBodyAsObject() {
        //given
        Account acc = new Account();

        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().bodyToJson(acc);
        Test.stopTest();

        //then
        System.assertEquals('{"attributes":{"type":"Account"}}', callout.body, 'Expecting specific value of body');
    }

    @isTest
    public static void should_BuildHttpRequest() {
        //given
        Integer testTimeout = 120000;
        Account acc = new Account();

        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout()
            .body(TEST_VAL_BODY_AS_STRING)
            .timeout(testTimeout)
            .addHeader(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1)
            .addParameterBody(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1)
            .addParameter(TEST_VAL_HEADER_KEY_2, TEST_VAL_HEADER_VALUE_2)
            .addParameter(TEST_VAL_HEADER_KEY_1, TEST_VAL_HEADER_VALUE_1)
            .builder();
        Test.stopTest();

        //then
        System.assertNotEquals(null, callout.request, 'Callout should not be null');
        System.assertEquals(
            'https://test.endpoint.com?' +
            TEST_VAL_HEADER_KEY_2 +
            '=' +
            TEST_VAL_HEADER_VALUE_2,
            callout.request.getEndpoint(),
            'Expecting specific value of endpoint'
        );
        System.assertEquals('GET', callout.request.getMethod(), 'Expecting specific value of Http method');
        System.assertNotEquals(null, callout.request.getBody(), 'Expecting body is not empty');
        System.assertEquals(TEST_VAL_HEADER_VALUE_1, callout.request.getHeader(TEST_VAL_HEADER_KEY_1), 'Expecting header is not empty');
    }

    @isTest
    public static void when_MethodIsNotProvided_expect_ExceptionIsThrown() {
        //when
        Test.startTest();
        try {
            HttpCallout callout = getBasicHttpCallout().method('').builder();
            System.assert(false, 'Expecting HttpCalloutException to be thrown');
        } catch (Exception e) {
            System.assertEquals(
                'Http Method was not provided to HttpCallout',
                e.getMessage(),
                'Expecting that proper HttpCalloutException was thrown'
            );
        }
        Test.stopTest();
    }

    @isTest
    public static void when_EndpointIsNotProvided_expect_ExceptionIsThrown() {
        //when
        Test.startTest();
        try {
            HttpCallout callout = getBasicHttpCallout().endpoint('').builder();
            System.assert(false, 'Expecting HttpCalloutException to be thrown');
        } catch (Exception e) {
            System.assertEquals('Endpoint was not provided to HttpCallout', e.getMessage(), 'Expecting that proper HttpCalloutException was thrown');
        }
        Test.stopTest();
    }

    @isTest
    public static void when_TimeoutValueIsTooHigh_expect_ExceptionIsThrown() {
        //when
        Test.startTest();
        try {
            HttpCallout callout = getBasicHttpCallout().timeout(120001).builder();
            System.assert(false, 'Expecting HttpCalloutException to be thrown');
        } catch (Exception e) {
            System.assertEquals(
                'Timeout value provided to HttpCallout is above the maximum value',
                e.getMessage(),
                'Expecting that proper HttpCalloutException was thrown'
            );
        }
        Test.stopTest();
    }

    @isTest
    public static void should_SendRequest() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpCalloutModuleMock());

        //when
        Test.startTest();
        HttpResponse response = getBasicHttpCallout().builder().send();
        Test.stopTest();

        //then
        System.assertNotEquals(null, response, 'Expecting response is returned');
    }

    @isTest
    public static void should_SetTimeout() {
        //when
        Test.startTest();
        HttpCallout callout = getBasicHttpCallout().timeout(120000);
        Test.stopTest();

        //then
        System.assertEquals(120000, callout.timeout, 'Expecting specific value of timeout');
    }

    private static HttpCallout getBasicHttpCallout() {
        return new HttpCallout().method('GET').endpoint('https://test.endpoint.com').builder();
    }
}