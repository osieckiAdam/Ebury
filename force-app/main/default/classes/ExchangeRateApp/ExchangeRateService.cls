public with sharing class ExchangeRateService {
    private static ExchangeRateService instance = null;

    private ExchangeRateProvider exchangeRateProvider;
    private Map<String, Map<String, Decimal>> cachedExchangeRates = new Map<String, Map<String, Decimal>>();
    @TestVisible
    private Map<String, Set<String>> ratesToRetrieve = new Map<String, Set<String>>();

    private ExchangeRateService() {
        this.exchangeRateProvider = (ExchangeRateProvider) di_Injector.Org.getInstance('ExchangeRateProvider');
    }

    public static ExchangeRateService getInstance() {
        if (instance == null) {
            instance = new ExchangeRateService();
        }
        return instance;
    }

    public Map<String, Map<String, Decimal>> getExchangeRates(Map<String, Set<String>> currencies) {
        Map<String, Map<String, Decimal>> ratesToReturn = new Map<String, Map<String, Decimal>>();
        this.ratesToRetrieve = new Map<String, Set<String>>();

        for (String sellCurrencyToGet : currencies.keySet()) {

            if (this.cachedExchangeRates.containsKey(sellCurrencyToGet)) {

                Map<String, Decimal> cachedBuyCurrencies = cachedExchangeRates.get(sellCurrencyToGet);
                for (String buyCurrencyToGet : currencies.get(sellCurrencyToGet)) {
                    if (cachedBuyCurrencies.keySet().contains(buyCurrencyToGet)) {
                        if (ratesToReturn.containsKey(sellCurrencyToGet)) {
                            for(String cachedBuyCurrencyKey : cachedBuyCurrencies.keySet()) {
                                ratesToReturn.get(sellCurrencyToGet).put(cachedBuyCurrencyKey, cachedBuyCurrencies.get(cachedBuyCurrencyKey));
                            }
                        } else {
                            ratesToReturn.put(sellCurrencyToGet, cachedExchangeRates.get(sellCurrencyToGet));
                        }
                    } else {
                        if (ratesToRetrieve.containsKey(sellCurrencyToGet)) {
                            ratesToRetrieve.get(sellCurrencyToGet).add(buyCurrencyToGet);
                        } else {
                            ratesToRetrieve.put(sellCurrencyToGet, new Set<String>{ buyCurrencyToGet });
                        }
                    }
                }
            } else {
                ratesToRetrieve.put(sellCurrencyToGet, currencies.get(sellCurrencyToGet));
            }
        }
        if(!ratesToRetrieve.isEmpty()) {
            Map<String, Map<String, Decimal>> currencyExchangeRates = this.exchangeRateProvider.getExchangeRates(ratesToRetrieve);
            cacheRetrievedValues(currencyExchangeRates);
        }
        return this.cachedExchangeRates;
    }

    private void cacheRetrievedValues(Map<String, Map<String, Decimal>> retrievedValues) {
        for (String retrievedSellCurrency : retrievedValues.keySet()) {
            if (this.cachedExchangeRates.containsKey(retrievedSellCurrency)) {
                this.cachedExchangeRates.get(retrievedSellCurrency).putAll(retrievedValues.get(retrievedSellCurrency));
            } else {
                this.cachedExchangeRates.put(retrievedSellCurrency, retrievedValues.get(retrievedSellCurrency));
            }
        }
    }
}