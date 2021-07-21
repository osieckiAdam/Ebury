import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import labelService from './labels';

import getAvailableCurrencies from '@salesforce/apex/ExchangeRateTradeNewRecordController.getAvailableCurrencies';
import getExchangeRates from '@salesforce/apex/ExchangeRateTradeNewRecordController.getExchangeRates';
import insertTrade from '@salesforce/apex/ExchangeRateTradeNewRecordController.insertTrade';



const DEFAULT_SELL_CURRENCY = 'EUR';
const DEFAULT_SELL_AMOUNT = 1000;
const DEFAULT_CURRENCY_REFRESH_INTERVAL = 20000;
export default class ExchangeRatesNewTradeRecord extends NavigationMixin(LightningElement) {
  @track exchangeRates = new Map();
  @track buyCurrencyOptions = [];
  @track sellCurrencyOptions = [];

  selectedSellCurrency;
  selectedBuyCurrency;
  sellAmount = DEFAULT_SELL_AMOUNT;

  isModalOpen = false;
  label = labelService._labels;

  connectedCallback() {
    this.isModalOpen = true;

    let exchangeRatesMap = {
      sellCurrency: DEFAULT_SELL_CURRENCY,
      buyCurrencies: []
    };

    getExchangeRates({ currencies: JSON.stringify(exchangeRatesMap) })
      .then((result) => {
        this.handleExchangeRatesResult(result);
      })
      .catch((error) => {
        this.showErrorNotification(reduceErrors(error));
      });

    getAvailableCurrencies()
      .then((result) => {
        let buyCurrencies = { ...result.buyCurrencies };
        let sellCurrencies = { ...result.sellCurrencies };

        Object.values(buyCurrencies).forEach((element) => {
          this.buyCurrencyOptions = [...this.buyCurrencyOptions, { label: element, value: element }];
        });
        Object.values(sellCurrencies).forEach((element) => {
          this.sellCurrencyOptions = [...this.sellCurrencyOptions, { label: element, value: element }];
        });
      })
      .catch((error) => {
        this.showErrorNotification(reduceErrors(error));
      });
  }

  retrieveFreshData(sellCurrency, buyCurrencies) {
    let exchangeRatesMap = {
      sellCurrency: sellCurrency,
      buyCurrencies: buyCurrencies
    };

    getExchangeRates({ currencies: JSON.stringify(exchangeRatesMap) })
      .then((result) => {
        this.handleExchangeRatesResult(result);
      })
      .catch((error) => {
        this.showErrorNotification(reduceErrors(error));
      });
  }

  handleExchangeRatesResult(result) {
    const timestamp = new Date().getTime();
    let exchangeRatesResult = { ...result };
    Object.keys(exchangeRatesResult).forEach((sellCurrency) => {
      let buyCurrenciesRates = exchangeRatesResult[sellCurrency];

      Object.keys(buyCurrenciesRates).forEach((buyCurrency) => {
        if (!this.exchangeRates.has(sellCurrency)) {
          this.exchangeRates.set(sellCurrency, {});
        }
        this.exchangeRates.get(sellCurrency)[buyCurrency] = {
          currencyCode: buyCurrency,
          exchangeRate: buyCurrenciesRates[buyCurrency],
          timestamp: timestamp
        };
      });
    });
  }

  handleClickCreateButton() {
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);
    if (isInputsCorrect) {
      this.isModalOpen = false;

      this.navigateToExchangeRateAppPage();
      let trade = {
        buyAmount: this.buyAmount,
        buyCurrency: this.selectedBuyCurrency,
        rate: this.exchangeRate,
        sellAmount: this.sellAmount,
        sellCurrency: this.selectedSellCurrency
      };
      insertTrade({ currencies: JSON.stringify(trade) })
        .then(() => {
          this.showSuccessNotification('Record was inserted succesfully');
        })
        .catch((error) => {
          this.showErrorNotification(reduceErrors(error));
        });
    }
  }

  handleSellCurrencyChange(event) {
    this.selectedSellCurrency = event.currentTarget.value;
  }

  handleBuyCurrencyChange(event) {
    this.selectedBuyCurrency = event.currentTarget.value;
  }

  handleChangeSellAmount(event) {
    this.sellAmount = event.currentTarget.value;
  }

  closeModal() {
    this.isModalOpen = false;
    this.navigateToExchangeRateAppPage();
  }

  navigateToExchangeRateAppPage() {
    this[NavigationMixin.Navigate]({
      type: 'standard__app',
      attributes: {
        appTarget: 'c__Exchange_Rates'
      }
    });
  }

  showSuccessNotification(message) {
    const evt = new ShowToastEvent({
      title: 'Success',
      message: message,
      variant: 'success'
    });
    this.dispatchEvent(evt);
  }

  showErrorNotification(errorMessage) {
    const evt = new ShowToastEvent({
      title: 'Error',
      message: 'Something unexpected happened, please contact with administrator. Error message: ' + errorMessage,
      variant: 'error',
      mode: 'sticky'
    });
    this.dispatchEvent(evt);
  }

  get exchangeRate() {
    if (this.selectedSellCurrency && this.selectedBuyCurrency) {
      if (this.exchangeRates.has(this.selectedSellCurrency) && this.exchangeRates.get(this.selectedSellCurrency)[this.selectedBuyCurrency]) {
        let rate = this.exchangeRates.get(this.selectedSellCurrency)[this.selectedBuyCurrency];
        if (new Date().getTime() - DEFAULT_CURRENCY_REFRESH_INTERVAL > rate.timestamp) {
          this.retrieveFreshData(this.selectedSellCurrency, [this.selectedBuyCurrency]);
        }
        return this.exchangeRates.get(this.selectedSellCurrency)[this.selectedBuyCurrency].exchangeRate;
      }
    }
    return '';
  }

  get buyAmount() {
    if (this.sellAmount && this.exchangeRate) {
      return this.sellAmount * this.exchangeRate;
    }
    return '';
  }

  get isButtonDisabled() {
    return !(this.selectedBuyCurrency && this.selectedSellCurrency && this.sellAmount > 0);
  }


}
