@IsTest
global with sharing class ExchangeRateAppTestUtils {
    public static final Decimal TEST_VAL_EUR_TO_USD_RATE = 1.18902;
    public static final Decimal TEST_VAL_EUR_TO_PLN_RATE = 4.58571;
    public static final Decimal TEST_VAL_PLN_TO_USD_RATE = 0.33290;
    public static final Decimal TEST_VAL_PLN_TO_EUR_RATE = 0.18;
    public static final Map<String, Map<String, Decimal>> TEST_VAL_EXCHANGE_MAPPING = new Map<String, Map<String, Decimal>>{
        'EUR' => new Map<String, Decimal>{ 'USD' => TEST_VAL_EUR_TO_USD_RATE, 'PLN' => TEST_VAL_EUR_TO_PLN_RATE, 'EUR' => 1 },
        'PLN' => new Map<String, Decimal>{ 'USD' => TEST_VAL_PLN_TO_USD_RATE, 'PLN' => 1, 'EUR' => TEST_VAL_PLN_TO_EUR_RATE }
    };

    public static final Integer TEST_VAL_ERROR_CODE = 105;
    public static final String TEST_VAL_ERROR_TYPE = 'base_currency_access_restricted';
    public static Integer mockCallsCounter = 0;

    global class HttpFixerIoServiceMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            mockCallsCounter++;

            PageReference ref = new PageReference(req.getEndpoint());

            String baseCurrency = ref.getParameters().get('base');
            FixerIoServiceMockResponseBody body = new FixerIoServiceMockResponseBody();
            if (TEST_VAL_EXCHANGE_MAPPING.containsKey(baseCurrency)) {
                List<String> symbols = ref.getParameters().get('symbols').split(',');
                Map<String, Decimal> rates = new Map<String, Decimal>();
                for (String currencySymbol : symbols) {
                    rates.put(currencySymbol, TEST_VAL_EXCHANGE_MAPPING.get(baseCurrency).get(currencySymbol));
                }
                body.setSuccess(true).setBase(baseCurrency).setRates(rates);
            } else {
                body.setSuccess(false).setError(new Error().setCode(TEST_VAL_ERROR_CODE).setType(TEST_VAL_ERROR_TYPE));
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

    public with sharing class ExchangeRateProviderMock implements System.StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<System.Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            mockCallsCounter++;

            if (stubbedMethodName == 'getExchangeRates') {
                Map<String, Map<String, Decimal>> result = new Map<String, Map<String, Decimal>>();

                for (Object arg : listOfArgs) {
                    Map<String, Set<String>> inputArg = (Map<String, Set<String>>) arg;
                    for (String sourceCurrency : inputArg.keySet()) {
                        if (result.containsKey(sourceCurrency)) {
                            Map<String, Decimal> targetCurrencies = result.get(sourceCurrency);
                            for (String targetCurrency : targetCurrencies.keySet()) {
                                if (!result.get(sourceCurrency).containsKey(targetCurrency)) {
                                    result.get(sourceCurrency).put(targetCurrency, TEST_VAL_EXCHANGE_MAPPING.get(sourceCurrency).get(targetCurrency));
                                }
                            }
                        } else {
                            for (String targetCurrency : inputArg.get(sourceCurrency)) {
                                if (result.containsKey(sourceCurrency)) {
                                    result.get(sourceCurrency).put(targetCurrency, TEST_VAL_EXCHANGE_MAPPING.get(sourceCurrency).get(targetCurrency));
                                } else {
                                    result.put(
                                        sourceCurrency,
                                        new Map<String, Decimal>{
                                            targetCurrency => TEST_VAL_EXCHANGE_MAPPING.get(sourceCurrency).get(targetCurrency)
                                        }
                                    );
                                }
                            }
                        }
                        //handle the case when no target currencies were specified so we expect that all available 
                        //currencies will be returned
                        if(result.get(sourceCurrency) == null) {
                            result.put(sourceCurrency,
                                        TEST_VAL_EXCHANGE_MAPPING.get(sourceCurrency)
                                    );
                        }
                    }
                }
                return result;
            }
            return null;
        }
    }
}