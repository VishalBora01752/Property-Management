import {LightningElement} from 'lwc';
import getProperties from  '@salesforce/apex/PropertyController.getProperties';
export default class PropertyList extends LightningElement {
    properties = [];
    pageNumber = 1;
    maxRent = 0;
    availability = '';
    furnishing = '';

    connectedCallback() {
        this.fetchingPropDetails();
    }

    fetchingPropDetails() {
        getProperties({pageNumber: this.pageNumber, maxRent: this.maxRent, status: this.availability, furnishing: this.furnishing})
            .then(result => {this.properties = result;})
            .catch(error => {console.error('Error we got here:',error);})
    }

    handleNext() {
        this.pageNumber += 1;
        this.fetchingPropDetails();
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.fetchingPropDetails();
        }
    }

    handlePriceChange(event) {
        if (event.detail.value === '' || event.detail.value === null || event.detail.value === undefined) {
            this.maxRent = null;
        }
        else {
            this.maxRent = Number(event.detail.value);
        }
        this.pageNumber = 1;
        this.fetchingPropDetails();
    }

    get statusOptions() {
        return [
            { label: 'Available', value: 'Available' },
            { label: 'Occupied', value: 'Occupied' },
            { label: 'Any', value: '' }
        ];
    }

    handleStatusChange(event) {
        this.availability = event.detail.value;
        this.pageNumber = 1;
        this.fetchingPropDetails();
    }

    get furnishingStatusOptions() {
        return [
            { label: 'Furnished', value: 'Furnished'},
            { label: 'Semi-Furnished', value: 'Semi-Furnished'},
            { label: 'Unfurnished', value: 'Unfurnished'},
            { label: 'Any', value: '' }
        ];
    }

    handleFurnishingStatusChange(event) {
        this.furnishing = event.detail.value;
        this.pageNumber = 1;
        this.fetchingPropDetails();
    }

    get columns() { 
        return [
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'Rent', fieldName: 'Rent__c', type: 'currency' },
            { label: 'Status', fieldName: 'Status__c', type: 'text' },
            { label: 'Furnishing', fieldName: 'Furnishing_Status__c', type: 'text' }
        ];
    }
}