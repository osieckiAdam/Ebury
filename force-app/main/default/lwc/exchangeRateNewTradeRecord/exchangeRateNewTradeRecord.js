import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableCurrencies from '@salesforce/apex/ExchangeRateTradeNewRecordController.getAvailableCurrencies';
import getExchangeRates from '@salesforce/apex/ExchangeRateTradeNewRecordController.getExchangeRates';

const DEFAULT_SELL_CURRENCY = 'EUR';
const DEFAULT_BUY_CURRENCY = 'PLN';
export default class ExchangeRatesNewTradeRecord extends NavigationMixin(LightningElement) {
  @track isModalOpen = false;

  selectedSellCurrency = DEFAULT_SELL_CURRENCY;
  selectedBuyCurrency = DEFAULT_BUY_CURRENCY;

  @track buyCurrencyOptions = [];
  @track sellCurrencyOptions = [];

  connectedCallback() {
    this.isModalOpen = true;

    let exchangeRatesMap = {
      'sellCurrency': 'EUR',
      'buyCurrencies': []
    };

    getExchangeRates({ currencies: JSON.stringify(exchangeRatesMap) })
      .then((result) => {
        console.log('exchange rates: ' + result);
        console.log({ ...result });
      })
      .catch((error) => {
        this.error = error;
        console.log(error);
      });

    getAvailableCurrencies()
      .then((result) => {
        let buyCurrencies = { ...result.buyCurrencies };
        let sellCurrencies = { ...result.sellCurrencies };

        Object.values(buyCurrencies).forEach((element) => {
          this.buyCurrencyOptions = [...this.buyCurrencyOptions, { label: element, value: element }];
        });
        Object.values(sellCurrencies).forEach((element) => {
          console.log(element);
          this.sellCurrencyOptions = [...this.sellCurrencyOptions, { label: element, value: element }];
        });
      })
      .catch((error) => {
        this.error = error;
        console.log('ERROR', error);
      });
  }

  openModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
    this.navigateToExchangeRateAppPage();
  }
  submitDetails() {
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);
    if (isInputsCorrect) {
      this.isModalOpen = false;

      this.navigateToExchangeRateAppPage();
      this.showNotification();
    } else {
      const evt = new ShowToastEvent({
        title: 'Error',
        message: 'Error',
        variant: 'error'
      });
      this.dispatchEvent(evt);
    }
  }

  handleSellCurrencyChange() {
    console.log('handleSellCurrencyChange');
  }

  handleBuyCurrencyChange() {
    console.log('handleSellCurrencyChange');
  }

  navigateToExchangeRateAppPage() {
    this[NavigationMixin.Navigate]({
      type: 'standard__app',
      attributes: {
        appTarget: 'c__Exchange_Rates'
      }
    });
  }

  showNotification() {
    const evt = new ShowToastEvent({
      title: 'Success',
      message: 'New Record is created',
      variant: 'success'
    });
    this.dispatchEvent(evt);
  }
}
