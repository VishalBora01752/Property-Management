import {LightningElement} from 'lwc';
import getProperties from  '@salesforce/apex/PropertyController.getProperties';
export default class PropertyList extends LightningElement {
    properties = [];
    connectedCallback() {
        getProperties({pageNumber: 1})
            .then(result => {this.properties = result;})
            .catch(error => {console.error('Error we got here:',error);})
    }

}