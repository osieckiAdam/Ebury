@IsTest
global with sharing class FixerIoServiceTest {
    private static Integer mockCallsCounter = 0;

    @TestSetup
    static void setup() {
        mockCallsCounter = 0;
    }

    @IsTest
    static void shouldReturnExchangeRatesForSingleTargetCurrency() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN' } };

        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assertEquals(1, exchangeRates.keySet().size(), 'Expecting specific number of records were returned');
        System.assert(exchangeRates.containsKey('EUR'), 'Expecting result contains specific key');
        System.assert(exchangeRates.get('EUR').containsKey('PLN'), 'Expecting result contains specific key');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            exchangeRates.get('EUR').get('PLN'),
            'Expecting result contains specific value of exchange rate'
        );
    }

    @IsTest
    static void shouldReturnExchangeRatesForMultipleTargetCurrencies() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN', 'USD', 'EUR' } };

        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assertEquals(1, exchangeRates.keySet().size(), 'Expecting specific number of records were returned');
        System.assert(exchangeRates.containsKey('EUR'), 'Expecting result contains specific key');
        System.assertEquals(3, exchangeRates.get('EUR').keySet().size(), 'Expecting result contains specific number of key');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            exchangeRates.get('EUR').get('PLN'),
            'Expecting result contains specific value of exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            exchangeRates.get('EUR').get('USD'),
            'Expecting result contains specific value of exchange rate'
        );
        System.assertEquals(1, exchangeRates.get('EUR').get('EUR'), 'Expecting result contains specific value of exchange rate');
    }

    @IsTest
    static void shouldReturnExchangeRatesForMultipleSourceAndTargetCurrencies() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{
            'EUR' => new Set<String>{ 'PLN', 'USD', 'EUR' },
            'PLN' => new Set<String>{ 'PLN', 'USD', 'EUR' }
        };

        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assertEquals(2, exchangeRates.keySet().size(), 'Expecting specific number of records were returned');
        System.assertEquals(3, exchangeRates.get('EUR').keySet().size(), 'Expecting result contains specific number of key');
        System.assertEquals(3, exchangeRates.get('PLN').keySet().size(), 'Expecting result contains specific number of key');
        System.assertEquals(2, mockCallsCounter, 'Expecting that there were two Http Calls created');
    }

    @IsTest
    static void shouldReturnError() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'BYN' => new Set<String>{ 'PLN', 'USD', 'EUR' } };
        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assertEquals(1, exchangeRates.keySet().size(), 'Expecting specific number of records were returned');
        System.assertEquals(1, exchangeRates.get('ERROR').keySet().size(), 'Expecting result contains specific number of key');
        for (String errorString : exchangeRates.get('ERROR').keySet()) {
            Map<String, Object> error = (Map<String, Object>) JSON.deserializeUntyped(errorString);
            System.assertEquals(ExchangeRateAppTestUtils.TEST_VAL_ERROR_TYPE, error.get('type'), 'Expecting specific value of error type');
            System.assertEquals(ExchangeRateAppTestUtils.TEST_VAL_ERROR_CODE, error.get('code'), 'Expecting specific value of error code');
            System.assertNotEquals(null, error.get('Uuid'), 'Expecting specific value of error code');
        }
        System.assertEquals(1, mockCallsCounter, 'Expecting that there was one Http Call created');
    }

    @IsTest
    static void shouldReturnMultipleErrors() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{
            'BYN' => new Set<String>{ 'PLN', 'USD', 'EUR' },
            'JPY' => new Set<String>{ 'PLN', 'USD', 'EUR' }
        };

        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assertEquals(1, exchangeRates.keySet().size(), 'Expecting specific number of records were returned');
        System.assertEquals(2, exchangeRates.get('ERROR').keySet().size(), 'Expecting result contains specific number of key');
        for (String errorString : exchangeRates.get('ERROR').keySet()) {
            Map<String, Object> error = (Map<String, Object>) JSON.deserializeUntyped(errorString);
            System.assertEquals(ExchangeRateAppTestUtils.TEST_VAL_ERROR_TYPE, error.get('type'), 'Expecting specific value of error type');
            System.assertEquals(ExchangeRateAppTestUtils.TEST_VAL_ERROR_CODE, error.get('code'), 'Expecting specific value of error code');
            System.assertNotEquals(null, error.get('Uuid'), 'Expecting specific value of error code');
        }
        System.assertEquals(2, mockCallsCounter, 'Expecting that there were two Http Calls created');
    }

    @IsTest
    static void shouldReturnErrorAndCorrectResponse() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{
            'BYN' => new Set<String>{ 'PLN', 'USD', 'EUR' },
            'EUR' => new Set<String>{ 'PLN', 'USD', 'EUR' }
        };

        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assertEquals(2, exchangeRates.keySet().size(), 'Expecting specific number of records were returned');
        System.assertEquals(3, exchangeRates.get('EUR').keySet().size(), 'Expecting result contains specific number of key');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            exchangeRates.get('EUR').get('PLN'),
            'Expecting result contains specific value of exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            exchangeRates.get('EUR').get('USD'),
            'Expecting result contains specific value of exchange rate'
        );
        System.assertEquals(1, exchangeRates.get('EUR').get('EUR'), 'Expecting result contains specific value of exchange rate');
        System.assertEquals(1, exchangeRates.get('ERROR').keySet().size(), 'Expecting result contains specific number of key');
        for (String errorString : exchangeRates.get('ERROR').keySet()) {
            Map<String, Object> error = (Map<String, Object>) JSON.deserializeUntyped(errorString);
            System.assertEquals(ExchangeRateAppTestUtils.TEST_VAL_ERROR_TYPE, error.get('type'), 'Expecting specific value of error type');
            System.assertEquals(ExchangeRateAppTestUtils.TEST_VAL_ERROR_CODE, error.get('code'), 'Expecting specific value of error code');
            System.assertNotEquals(null, error.get('Uuid'), 'Expecting specific value of error code');
        }
        System.assertEquals(2, mockCallsCounter, 'Expecting that there were two Http Calls created');
    }

    global class HttpFixerIoServiceMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            mockCallsCounter++;

            PageReference ref = new PageReference(req.getEndpoint());

            String baseCurrency = ref.getParameters().get('base');
            FixerIoServiceMockResponseBody body = new FixerIoServiceMockResponseBody();
            if (ExchangeRateAppTestUtils.TEST_VAL_EXCHANGE_MAPPING.containsKey(baseCurrency)) {
                List<String> symbols = ref.getParameters().get('symbols').split(',');
                Map<String, Decimal> rates = new Map<String, Decimal>();
                for (String currencySymbol : symbols) {
                    rates.put(currencySymbol, ExchangeRateAppTestUtils.TEST_VAL_EXCHANGE_MAPPING.get(baseCurrency).get(currencySymbol));
                }
                body.setSuccess(true).setBase(baseCurrency).setRates(rates);
            } else {
                body.setSuccess(false)
                    .setError(
                        new Error().setCode(ExchangeRateAppTestUtils.TEST_VAL_ERROR_CODE).setType(ExchangeRateAppTestUtils.TEST_VAL_ERROR_TYPE)
                    );
            }

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(body));
            res.setStatusCode(200);
            return res;
        }
    }

    private class FixerIoServiceMockResponseBody {
        Boolean success { get; private set; }
        String base { get; private set; }
        Map<String, Decimal> rates { get; private set; }

        Error error { get; private set; }

        public FixerIoServiceMockResponseBody setSuccess(Boolean success) {
            this.success = success;
            return this;
        }

        public FixerIoServiceMockResponseBody setBase(String base) {
            this.base = base;
            return this;
        }

        public FixerIoServiceMockResponseBody setRates(Map<String, Decimal> rates) {
            this.rates = rates;
            return this;
        }

        public FixerIoServiceMockResponseBody setError(Error err) {
            this.error = err;
            return this;
        }
    }

    private class Error {
        Integer code;
        String type;

        public Error setCode(Integer code) {
            this.code = code;
            return this;
        }

        public Error setType(String type) {
            this.type = type;
            return this;
        }
    }
}