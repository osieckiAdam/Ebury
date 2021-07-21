public with sharing class ExchangeRateTradeNewRecordController {
    @AuraEnabled(cacheable=true)
    public static AvailableCurrencies getAvailableCurrencies() {
        try {
            AvailableCurrencies ac = new AvailableCurrencies();
            ac.sellCurrencies.addAll(getPicklistLabels(Trade__c.Sell_Currency__c));
            ac.buyCurrencies.addAll(getPicklistLabels(Trade__c.Buy_Currency__c));
            return ac;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, Decimal>> getExchangeRates(String currencies) {
        try {
            ExchangeRatesParams erp = (ExchangeRatesParams) JSON.deserialize(currencies, ExchangeRatesParams.class);
            Set<String> buyCurrencies = new Set<String>();
            buyCurrencies.addAll(erp.buyCurrencies);
            Map<String, Set<String>> currenciesMap = new Map<String, Set<String>>{ erp.sellCurrency => buyCurrencies };
            return ExchangeRateService.getInstance().getExchangeRates(currenciesMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Trade__c insertTrade(String currencies) {
        try {
            System.debug(LoggingLevel.DEBUG, '(currencies): ' + currencies);
            Trade t = (Trade) JSON.deserialize(currencies, Trade.class);
            System.debug(LoggingLevel.DEBUG, '(t): ' + JSON.SerializePretty(t));
            Trade__c newTradeRecord = new Trade__c(
                Buy_Amount__c = t.sellAmount * t.Rate,
                Buy_Currency__c = t.buyCurrency,
                Rate__c = t.rate,
                Sell_Amount__c = t.sellAmount,
                Sell_Currency__c = t.sellCurrency
            );
            insert newTradeRecord;
            return newTradeRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> getPicklistLabels(Schema.SObjectField field) {
        List<String> labelsToReturn = new List<String>();
        Schema.DescribeFieldResult dfr = field.getDescribe();
        Schema.sObjectField T = dfr.getSObjectField();
        List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        for (PicklistEntry pe : entries) {
            labelsToReturn.add(pe.getLabel());
        }
        return labelsToReturn;
    }


    public class AvailableCurrencies {
        @AuraEnabled
        public List<String> buyCurrencies;
        @AuraEnabled
        public List<String> sellCurrencies;

        public AvailableCurrencies() {
            this.buyCurrencies = new List<String>();
            this.sellCurrencies = new List<String>();
        }
    }

    public class ExchangeRatesParams {
        @AuraEnabled
        public String sellCurrency;
        @AuraEnabled
        public List<String> buyCurrencies;
    }

    public class Trade {
        @AuraEnabled
        public Double buyAmount;
        @AuraEnabled
        public String buyCurrency;
        @AuraEnabled
        public Double rate;
        @AuraEnabled
        public Double sellAmount;
        @AuraEnabled
        public String sellCurrency;
    }
}