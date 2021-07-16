@IsTest
global with sharing class ExchangeRateServiceTest {
    @IsTest
    static void shouldReturnExchangeRates() {
        //given
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN', 'USD', 'EUR' } };
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        //when
        Test.startTest();
        Map<String, Map<String, Decimal>> result = ExchangeRateService.getInstance().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assert(result.containsKey('EUR'), 'Expecting result contains specific key');
        System.assertEquals(3, result.get('EUR').keySet().size(), 'Expecting specific number of target currencies');
        System.assert(result.get('EUR').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('EUR'), 'Expecting result contains specific value of target currency');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            result.get('EUR').get('PLN'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            result.get('EUR').get('USD'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(1, result.get('EUR').get('EUR'), 'Expecting result contains specific value of target currency exchange rate');
        System.assertEquals(1, ExchangeRateAppTestUtils.mockCallsCounter, 'Expecting specific number of calls were performed');
    }

    @IsTest
    static void shouldReturnExchangeRatesAndOnlyOneHttpCallShouldBePerformed() {
        //given
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN', 'USD', 'EUR' } };
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        //when
        Test.startTest();
        ExchangeRateService.getInstance().getExchangeRates(requestedValues);
        Map<String, Map<String, Decimal>> result = ExchangeRateService.getInstance().getExchangeRates(requestedValues);
        Test.stopTest();

        //then
        System.assert(result.containsKey('EUR'), 'Expecting result contains specific key');

        System.assertEquals(3, result.get('EUR').keySet().size(), 'Expecting specific number of target currencies');
        System.assert(result.get('EUR').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('EUR'), 'Expecting result contains specific value of target currency');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            result.get('EUR').get('PLN'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            result.get('EUR').get('USD'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(1, result.get('EUR').get('EUR'), 'Expecting result contains specific value of target currency exchange rate');
        System.assertEquals(1, ExchangeRateAppTestUtils.mockCallsCounter, 'Expecting specific number of calls were performed');
    }

    @IsTest
    static void shouldProperlyHandleCacheWhenGetNewSellCurrency() {
        //given
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN' } };
        Map<String, Set<String>> requestedValues2 = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN', 'USD' } };
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        //when
        Test.startTest();
        ExchangeRateService.getInstance().getExchangeRates(requestedValues);
        Map<String, Map<String, Decimal>> result = ExchangeRateService.getInstance().getExchangeRates(requestedValues2);
        Test.stopTest();

        //then
        System.assertEquals(2, result.get('EUR').keySet().size(), 'Expecting specific number of target currencies');
        System.assert(result.get('EUR').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            result.get('EUR').get('PLN'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            result.get('EUR').get('USD'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(2, ExchangeRateAppTestUtils.mockCallsCounter, 'Expecting specific number of calls were performed');
    }

    @IsTest
    static void shouldProperlyHandleCacheWhenNewCurrencyIsRequested() {
        //given
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN', 'USD', 'EUR' } };
        Map<String, Set<String>> requestedValues2 = new Map<String, Set<String>>{ 'PLN' => new Set<String>{ 'PLN', 'USD', 'EUR' } };
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        //when
        Test.startTest();
        ExchangeRateService.getInstance().getExchangeRates(requestedValues);
        Map<String, Map<String, Decimal>> result = ExchangeRateService.getInstance().getExchangeRates(requestedValues2);
        Test.stopTest();

        //then
        System.assertEquals(3, result.get('EUR').keySet().size(), 'Expecting specific number of target currencies');
        System.assertEquals(3, result.get('PLN').keySet().size(), 'Expecting specific number of target currencies');
        System.assert(result.get('EUR').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('EUR'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('PLN').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('PLN').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('PLN').containsKey('EUR'), 'Expecting result contains specific value of target currency');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            result.get('EUR').get('PLN'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            result.get('EUR').get('USD'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_PLN_TO_USD_RATE,
            result.get('PLN').get('USD'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_PLN_TO_EUR_RATE,
            result.get('PLN').get('EUR'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(2, ExchangeRateAppTestUtils.mockCallsCounter, 'Expecting specific number of calls were performed');
    }

    @IsTest
    static void test5() {
        //given
        Map<String, Set<String>> requestedValues = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN' } };
        Map<String, Set<String>> requestedValues2 = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'USD' } };
        Map<String, Set<String>> requestedValues3 = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'EUR' } };
        Map<String, Set<String>> requestedValues4 = new Map<String, Set<String>>{ 'EUR' => new Set<String>{ 'PLN' } };
        ExchangeRateAppTestUtils.ExchangeRateProviderMock erpm = new ExchangeRateAppTestUtils.ExchangeRateProviderMock();
        di_Injector.Org.Bindings.set(new di_Module().bind(ExchangeRateProvider.class).toObject(Test.createStub(ExchangeRateProvider.class, erpm)));

        //when
        Test.startTest();
        ExchangeRateService.getInstance().getExchangeRates(requestedValues);
        ExchangeRateService.getInstance().getExchangeRates(requestedValues2);
        ExchangeRateService.getInstance().getExchangeRates(requestedValues3);
        Map<String, Map<String, Decimal>> result = ExchangeRateService.getInstance().getExchangeRates(requestedValues4);
        Test.stopTest();

        //then
        System.assertEquals(3, result.get('EUR').keySet().size(), 'Expecting specific number of target currencies');
        System.assert(result.get('EUR').containsKey('PLN'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('USD'), 'Expecting result contains specific value of target currency');
        System.assert(result.get('EUR').containsKey('EUR'), 'Expecting result contains specific value of target currency');
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_PLN_RATE,
            result.get('EUR').get('PLN'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(
            ExchangeRateAppTestUtils.TEST_VAL_EUR_TO_USD_RATE,
            result.get('EUR').get('USD'),
            'Expecting result contains specific value of target currency exchange rate'
        );
        System.assertEquals(3, ExchangeRateAppTestUtils.mockCallsCounter, 'Expecting specific number of calls were performed');
    }
}