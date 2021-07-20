@IsTest
public with sharing class ExchangeRateTradeNewRecordControllerTest {

    @IsTest
    static void test1() {
        //given
        ExchangeRateTradeNewRecordController.ExchangeRatesParams params = new ExchangeRateTradeNewRecordController.ExchangeRatesParams();
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        params.sellCurrency = 'EUR';
        params.buyCurrencies = new List<String>();
        //when
        Test.startTest();
        System.debug(LoggingLevel.DEBUG, '(ExchangeRateTradeNewRecordController.getExchangeRates(params)): ' + JSON.SerializePretty(ExchangeRateTradeNewRecordController.getExchangeRates(params)));
        // ExchangeRateTradeNewRecordController.getExchangeRates(params);
        Test.stopTest();

    }

}