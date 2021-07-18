import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class ExchangeRatesNewTradeRecord extends NavigationMixin(LightningElement) {
  @api recordId;

  renderedCallback() {
    this.template.querySelector('c-modal').toggleModal();
  }

  handleClick(event) {
    event.preventDefault();
    event.stopPropagation();
    this.template.querySelector('c-modal').toggleModal();
  }

  modalSaveHandler = (event) => {
    event.stopPropagation();
    this.handleClick(event);
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        variant: 'success',
        message: 'Record successfully updated!'
      })
    );
  };

  modalCloseHandler = (event) => {
    event.stopPropagation();
    console.log('MODAl IS CLOSED');
    this.navigateToExchangeRateAppPage();
  };

  navigateToExchangeRateAppPage() {
    this[NavigationMixin.Navigate]({
      type: 'standard__app',
      attributes: {
        appTarget: 'c__Exchange_Rates'
      }
    });
  }
}
