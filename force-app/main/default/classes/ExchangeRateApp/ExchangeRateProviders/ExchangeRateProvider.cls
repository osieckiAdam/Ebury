public interface ExchangeRateProvider {
    Map<String, Map<String, Decimal>> getExchangeRates(Map<String, Set<String>> currencies);
}