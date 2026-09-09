import { LightningElement } from 'lwc';
import createProperty from '@salesforce/apex/PropertyController.createProperty';
export default class PropertyCreate extends LightningElement {

    name = '';
    rent = 0;
    files = [];
    availability = '';
    furnishing = '';
    type = '';
    description = '';
    address = '';
    city = '';
    state = '';
    postalcode = '';
    country = '';
    errorMessage = '';

    handleFileChange(event) {
        this.files = event.detail.files;
    }

    handleRentInput(event) {
        this.rent = Number(event.detail.value);
    }

    handleNameInput(event) {
        this.name = event.detail.value;
    }

    handleAddressInput(event) {
        this.address = event.detail.value;
    }

    handleCityInput(event) {
        this.city = event.detail.value;
    }

    handleStateInput(event) {
        this.state = event.detail.value;
    }

    handlePostalCodeInput(event) {
        this.postalcode = event.detail.value;
    }

    handleCountryInput(event) {
        this.country = event.detail.value;
    }

    get statusOptions() {
        return [
            { label: 'Available', value: 'Available' },
            { label: 'Occupied', value: 'Occupied' }
        ];
    }

    handleStatusChange(event) {
        this.availability = event.detail.value;
    }

    get furnishingStatusOptions() {
        return [
            { label: 'Furnished', value: 'Furnished'},
            { label: 'Semi-Furnished', value: 'Semi-Furnished'},
            { label: 'Unfurnished', value: 'Unfurnished'}
        ];
    }

    handleFurnishingStatusChange(event) {
        this.furnishing = event.detail.value;
    }

    get typeOptions() {
        return [
            { label: 'Residential', value: 'Residential' },
            { label: 'Commercial', value: 'Commercial' }
        ];
    }

    handleTypeChange(event) {
        this.type = event.detail.value;
    }

    handleDescriptionInput(event) {
        this.description = event.detail.value;
    }

    async handleSave(event) {
        if (this.files.length === 0) {
            this.errorMessage = 'Please upload at least one image';
        } 
        else {this.errorMessage = 'uploaded';

            const fileNames = [];
            const fileBodies = [];

            for (const file of this.files) {
                const base64 = await this.readFileAsBase64(file);
                fileNames.push(file.name);
                fileBodies.push(base64);
            }

            this.createPropertyDetails(fileNames, fileBodies);
        }
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const result = reader.result; // looks like "data:image/png;base64,iVBORw0KG..."
                const base64 = result.split(',')[1]; // strip the "data:image/png;base64," prefix
                resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    createPropertyDetails(fileNames, fileBodies) {
        createProperty({name: this.name, rent: this.rent, address: this.address, city: this.city, state: this.state, 
            postalCode: this.postalcode, country: this.country, type: this.type, furnishingStatus: this.furnishing, 
            status: this.availability, description: this.description, fileNames: fileNames, fileBodies: fileBodies})
            .then((newPropertyId) => {
                this.errorMessage = 'Created ' + newPropertyId;
                console.log('Created Property with Id:', newPropertyId);
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                console.error('Error we got here:',error);})
        
    }
}