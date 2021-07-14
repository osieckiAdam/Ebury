public with sharing class FixerIoService implements ExchangeRateProvider {

    private Map<String, Map<String, Decimal>> result = new Map<String, Map<String, Decimal>>(); 

    public Map<String, Map<String, Decimal>> getExchangeRates(Map<String, Set<String>> currencies) {

        for (String sellCurrency : currencies.keySet()) {
            String symbols = String.join((Iterable<String>)currencies.get(sellCurrency), ',');
            HttpCallout callout = new HttpCallout()
                .method('GET')
                .endpoint('http://data.fixer.io/api/latest')
                .addParameter('base', sellCurrency)
                .addParameter('symbols', symbols)
                .addParameter('access_key', 'eb841eb6f3a00d7745682ea3a0a96263')
                .builder();

            System.debug(LoggingLevel.DEBUG, '(BEFORE CALL): ');
            HttpResponse resp = callout.send();
            System.debug(LoggingLevel.DEBUG, '(after CALL): ');

            String jsonresp = resp.getBody();
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(jsonresp);
            System.debug(LoggingLevel.DEBUG, '(response): ' + JSON.SerializePretty(response));
            if ((Boolean) response.get('success')) {
                Map<String, Object> rates = (Map<String,Object>)response.get('rates');
                result.put(sellCurrency, castMapOfObjectToDecimal(rates));
            } else {

                throw new FixerIoException('Issue in FixerIo Service: ' + response.get('error') + '. Request data: 1.base: ' + sellCurrency + ' 2.symbols: ' + symbols );
            }
        }
        return result;
    }

    private Map<String, Decimal> castMapOfObjectToDecimal( Map<String, Object> sourceMap ) {
        Map<String, Decimal> mapToReturn = new Map<String, Decimal>();
        for(String key : sourceMap.keySet()){
            mapToReturn.put(key, (Decimal) sourceMap.get(key));
        }
        return mapToReturn;
    }

    public class FixerIoException extends Exception {
    }
}