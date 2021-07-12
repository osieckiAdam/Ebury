public with sharing class ExchangeRateProviderMock implements System.StubProvider {

    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType, List<System.Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        if(stubbedMethodName == 'getExchangeRates') {
            return new Map<String, Map<String, Decimal>>{
                'EUR' => new Map<String, Decimal>{
                    'PLN' => 4.554327,
                    'USD' => 1.186185
                }
            };
        }
    }

}
