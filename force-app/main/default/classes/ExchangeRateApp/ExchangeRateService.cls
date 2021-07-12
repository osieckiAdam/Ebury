public with sharing class ExchangeRateService {

    private ExchangeRateProvider provider;

    public ExchangeRateService(ExchangeRateProvider provider) {
        this.provider = provider;
    }

    public Map<String, Map<String, Decimal>> ExchangeRateService(Map<String,List<String>> currencies) {
        return this.provider.getExchangeRates(currencies);
    }
}
