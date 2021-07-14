@IsTest
global with sharing class FixerIoServiceTest {


    private static final Map<String, Map<String, Decimal>> TEST_VAL_EXCHANGE_MAPPING = 
    new Map<String, Map<String, Decimal>> {
        'EUR' => new Map<String, Decimal> { 'USD' => 1.18902, 'PLN' => 4.58571, 'EUR' => 1 },
        'PLN' => new Map<String, Decimal> { 'USD' => 0.33290, 'PLN' => 1, 'EUR' => 0.18 }
    };
    private static final Integer TEST_VAL_ERROR_CODE = 105;
    private static final String TEST_VAL_ERROR_TYPE = 'base_currency_access_restricted';


    private static Integer mockCallsCounter = 0;

    @IsTest
    static void shouldDoSmth(){
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues =  new Map<String, Set<String>>{'EUR' => new Set<String>{'PLN'}};
        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(exchangeRates): ' + JSON.SerializePretty(exchangeRates));
    }

    @IsTest
    static void shouldDoSmth2(){
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues =  new Map<String, Set<String>>{'EUR' => new Set<String>{'PLN', 'USD', 'EUR'}};
        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(exchangeRates): ' + JSON.SerializePretty(exchangeRates));
    }

    @IsTest
    static void shouldDoSmth3() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues =  new Map<String, Set<String>>{'EUR' => new Set<String>{'PLN', 'USD', 'EUR'}, 'PLN' => new Set<String>{'PLN', 'USD', 'EUR'}};
        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(exchangeRates): ' + JSON.SerializePretty(exchangeRates));
        System.debug(LoggingLevel.DEBUG, '(mockCallsCounter): ' + mockCallsCounter);
    }

    @IsTest
    static void shouldReturnError() {
        //given
        Test.setMock(HttpCalloutMock.class, new HttpFixerIoServiceMock());
        Map<String, Set<String>> requestedValues =  new Map<String, Set<String>>{'BYN' => new Set<String>{'PLN', 'USD', 'EUR'}};
        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> exchangeRates = new FixerIoService().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.debug(LoggingLevel.DEBUG, '(exchangeRates): ' + JSON.SerializePretty(exchangeRates));
        System.debug(LoggingLevel.DEBUG, '(mockCallsCounter): ' + mockCallsCounter);
    }

    global class HttpFixerIoServiceSuccessMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            mockCallsCounter++;

            PageReference ref = new PageReference(req.getEndpoint());

            String baseCurrency = ref.getParameters().get('base');
            if(TEST_VAL_EXCHANGE_MAPPING.containsKey(baseCurrency)) {
                List<String> symbols =  ref.getParameters().get('symbols').split(',');
                Map<String, Decimal> rates = new Map<String, Decimal>(); 
                for(String currencySymbol : symbols) {
                    rates.put(currencySymbol, TEST_VAL_EXCHANGE_MAPPING.get(baseCurrency).get(currencySymbol));
                }
                FixerIoServiceMockResponseBody body = new FixerIoServiceMockResponseBody().setSuccess(true).setBase(baseCurrency).setRates(rates);
            } else {
                FixerIoServiceMockResponseBody body = new FixerIoServiceMockResponseBody().setSuccess(false).setError(new Error().setCode(TEST_VAL_ERROR_CODE).setType(TEST_VAL_ERROR_TYPE));
            }
     
            List<String> symbols =  ref.getParameters().get('symbols').split(',');
            
            Map<String, Decimal> rates = new Map<String, Decimal>(); 
            for(String currencySymbol : symbols) {
                rates.put(currencySymbol, TEST_VAL_EXCHANGE_MAPPING.get(baseCurrency).get(currencySymbol));
            }

            FixerIoServiceMockResponseBody body = new FixerIoServiceMockResponseBody().setSuccess(true).setBase(baseCurrency).setRates(rates);

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(body));
            res.setStatusCode(200);
            return res;
        }
    }


    private class FixerIoServiceMockResponseBody {
        Boolean success {get; private set;}
        String base {get; private set;}
        Map<String, Decimal> rates {get; private set;}

        Error error {get; private set;}

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