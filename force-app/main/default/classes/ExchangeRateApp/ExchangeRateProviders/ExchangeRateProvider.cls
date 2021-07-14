public Interface ExchangeRateProvider {
    Map<String, Map<String, Decimal>> getExchangeRates(Map<String, Set<String>> currencies);
}
