@IsTest
public with sharing class ExchangeRateTradeNewRecordControllerTest {

    @IsTest
    static void shouldReturnExchangeRates() {
        //given
        ExchangeRateTradeNewRecordController.ExchangeRatesParams params = new ExchangeRateTradeNewRecordController.ExchangeRatesParams();
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        params.sellCurrency = 'EUR';
        params.buyCurrencies = new List<String>();

        //when
        Test.startTest();
        String paramsString = JSON.serialize(params);
        Map<String, Map<String, Decimal>> exchangeRates = ExchangeRateTradeNewRecordController.getExchangeRates(paramsString);
        Test.stopTest();

        //then
        System.assertEquals(3, exchangeRates.get('EUR').keySet().size(), 'Expecting specific number of target currencies');
        System.assert(exchangeRates.get('EUR').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(exchangeRates.get('EUR').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assert(exchangeRates.get('EUR').containsKey('EUR'), 'Expecting result contains specific value of target currency');
    }

    @IsTest
    static void shouldReturnAvailableCurrencies() {
        //when
        Test.startTest();
        ExchangeRateTradeNewRecordController.AvailableCurrencies availableCurrencies = ExchangeRateTradeNewRecordController.getAvailableCurrencies();
        Test.stopTest();

        //then
        System.assert(availableCurrencies.sellCurrencies.size() > 0, 'Expecting result contains specific value of target currency');
        System.assert(availableCurrencies.buyCurrencies.size() > 0, 'Expecting result contains specific value of target currency');
    }

    @IsTest
    static void shouldInsertTrade() {
        //given
        String TEST_BUY_CURRENCY = 'AMD';
        String TEST_SELL_CURRENCY = 'EUR';
        Decimal TEST_SELL_AMOUNT = 1000;
        Decimal TEST_RATE = 575.1666;
        Decimal TEST_BUY_AMOUNT = 575166.6;
        String inputString = '{"buyAmount":'+ TEST_BUY_AMOUNT + ',"buyCurrency":"'+ TEST_BUY_CURRENCY + '","rate":'+ TEST_RATE + ',"sellAmount":'+ TEST_SELL_AMOUNT + ',"sellCurrency":"'+ TEST_SELL_CURRENCY + '"}';
        
        //when
        Test.startTest();
            Trade__c insertedTrade = ExchangeRateTradeNewRecordController.insertTrade(inputString);
            Test.stopTest();

            //then
            System.assert(insertedTrade.Id != null, 'Expecting trade record was inserted');
            System.assertEquals(insertedTrade.Buy_Amount__c, TEST_BUY_AMOUNT, 'Expecting specific value of Buy Amount');
            System.assertEquals(insertedTrade.Buy_Currency__c, TEST_BUY_CURRENCY, 'Expecting specific value of Buy Currency');
            System.assertEquals(insertedTrade.Rate__c, TEST_RATE, 'Expecting specific value of Test Rate');
            System.assertEquals(insertedTrade.Sell_Amount__c, TEST_SELL_AMOUNT, 'Expecting specific value of Sell Amount');
            System.assertEquals(insertedTrade.Sell_Currency__c, TEST_SELL_CURRENCY, 'Expecting specific value of Sell Currency');

    }

}