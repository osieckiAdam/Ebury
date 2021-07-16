public with sharing class FixerIoService implements ExchangeRateProvider {
    private Map<String, Map<String, Decimal>> result = new Map<String, Map<String, Decimal>>();

    public Map<String, Map<String, Decimal>> getExchangeRates(Map<String, Set<String>> currencies) {
        for (String sellCurrency : currencies.keySet()) {
            String symbols = String.join((Iterable<String>) currencies.get(sellCurrency), ',');
            HttpCallout callout = new HttpCallout()
                .method('GET')
                .endpoint('http://data.fixer.io/api/latest')
                .addParameter('base', sellCurrency)
                .addParameter('symbols', symbols)
                .addParameter('access_key', 'eb841eb6f3a00d7745682ea3a0a96263')
                .builder();

            HttpResponse resp = callout.send();

            String jsonresp = resp.getBody();
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(jsonresp);
            if ((Boolean) response.get('success')) {
                Map<String, Object> rates = (Map<String, Object>) response.get('rates');
                result.put(sellCurrency, castMapOfObjectToDecimal(rates));
            } else {
                Map<String, Object> error = (Map<String, Object>) response.get('error');
                error.put('Uuid', new Uuid().getValue());

                if (result.containsKey('ERROR')) {
                    result.get('ERROR').put(JSON.serialize(error), 0);
                } else {
                    result.put('ERROR', new Map<String, Decimal>{ JSON.serialize(error) => 0 });
                }
            }
        }
        return result;
    }

    private Map<String, Decimal> castMapOfObjectToDecimal(Map<String, Object> sourceMap) {
        Map<String, Decimal> mapToReturn = new Map<String, Decimal>();
        for (String key : sourceMap.keySet()) {
            mapToReturn.put(key, (Decimal) sourceMap.get(key));
        }
        return mapToReturn;
    }

    public class FixerIoException extends Exception {
    }
}