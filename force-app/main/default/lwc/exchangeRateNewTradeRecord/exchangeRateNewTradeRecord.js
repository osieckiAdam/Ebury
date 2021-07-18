import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExchangeRatesNewTradeRecord extends LightningElement {

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
}